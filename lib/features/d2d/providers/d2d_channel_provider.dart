import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cts/app/session_invalidation.dart';
import 'package:cts/core/lifecycle/app_lifecycle_phase.dart';
import 'package:cts/core/network/network_action_guard.dart';
import 'package:cts/appManager/app_class.dart';
import 'package:cts/appManager/session_manager.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/models/d2d_commuter_model.dart';
import 'package:cts/features/d2d/models/d2d_channel_role_policy.dart';
import 'package:cts/features/d2d/repositories/d2d_repository.dart';
import 'package:cts/features/drivers/models/driver_model.dart';
import 'package:cts/features/drivers/repositories/driver_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// STOP snapshot from the live group: `{ "isActive": false }` (snake_case allowed).
bool d2dResultMarksTripEnded(Map<String, dynamic> result) {
  final active = result['isActive'] ?? result['is_active'];
  return active == false;
}

/// Parses confirmed riders from WS `already_in` / `alreadyIn` / legacy `CList` hydrate.
List<D2dCommuterModel>? parseAlreadyInFromResult(Map<String, dynamic> result) {
  final raw = result['already_in'] ?? result['alreadyIn'] ?? result['CList'];
  if (raw == null) return null;
  return _parseCommutersFromPayloadData(raw);
}

List<D2dCommuterModel>? _parseCommutersFromPayloadData(dynamic data) {
  if (data == null) return null;

  if (data is List) {
    final commuters = <D2dCommuterModel>[];
    for (final item in data) {
      final commuterJson = _unwrapCommuterEntryStatic(item);
      if (commuterJson != null) {
        commuters.add(D2dCommuterModel.fromJson(commuterJson));
      }
    }
    return commuters;
  }

  if (data is Map) {
    final commuters = <D2dCommuterModel>[];
    for (final entry in data.entries) {
      final commuterJson = _unwrapCommuterEntryStatic({entry.key: entry.value});
      if (commuterJson != null) {
        commuters.add(D2dCommuterModel.fromJson(commuterJson));
      }
    }
    return commuters;
  }

  return null;
}

Map<String, dynamic>? _unwrapCommuterEntryStatic(dynamic item) {
  if (item is! Map) return null;

  final map = Map<String, dynamic>.from(item);

  if (map.length == 1) {
    final entry = map.entries.first;
    final inner = entry.value;

    if (inner is Map) {
      final commuter = Map<String, dynamic>.from(inner);
      final id = int.tryParse(entry.key.toString());
      commuter.putIfAbsent('id', () => id ?? entry.key);
      return commuter;
    }

    if (inner is String) {
      try {
        final decoded = json.decode(inner);
        return _unwrapCommuterEntryStatic({entry.key: decoded});
      } catch (_) {
        final id = int.tryParse(entry.key.toString());
        return {
          'id': id ?? entry.key,
          'username': inner,
        };
      }
    }
  }

  if (_looksLikeCommuterStatic(map)) return map;

  return null;
}

bool _looksLikeCommuterStatic(Map<String, dynamic> json) {
  return json.containsKey('userId') ||
      json.containsKey('username') ||
      json.containsKey('mobile_number') ||
      json.containsKey('mobileNumber') ||
      json.containsKey('pickUpPoint') ||
      json.containsKey('popId') ||
      json.containsKey('inLine');
}

class D2dChannelProvider with ChangeNotifier {
  D2dChannelProvider(
    this._driverRepository,
    this._d2dRepository, {
    NetworkActionGuard? networkGuard,
    this._onSessionInvalidated,
    @visibleForTesting this.sessionRoleOverride,
  }) : _networkGuard = networkGuard;

  static const int _endedTripCloseCode = 4001;
  static const int _unauthorizedCloseCode = 4401;
  static const int _forbiddenCloseCode = 4403;
  static const String _tripEndedMessage =
      'This trip has already ended. A new trip can be started tomorrow.';
  static const String _unauthorizedMessage =
      'You are not allowed to join this live trip. Please sign in again.';
  static const String _connectionLostMessage =
      'Live connection lost. Reconnecting…';
  static const String _offlineMessage =
      'No network connection. Live updates will resume when you are back online.';

  final DriverRepository _driverRepository;
  final D2dRepository _d2dRepository;
  final NetworkActionGuard? _networkGuard;
  final SessionInvalidatedCallback? _onSessionInvalidated;

  /// Test hook — when set, overrides [SessionRole.userType] for action gating.
  @visibleForTesting
  final String? sessionRoleOverride;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  int _connectGeneration = 0;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 8;
  DriverModel? _driver;
  List<D2dCommuterModel> _commuters = [];
  List<D2dCommuterModel> _alreadyInCommuters = [];
  bool _isAscending = true;
  bool _isConnected = false;
  bool _isDisposed = false;
  bool _lifecyclePaused = false;
  bool _connectionLost = false;
  String? _connectedBatchId;

  ViewState _state = ViewState.idle;
  String? _errorMessage;
  String? _actionErrorMessage;
  bool _tripEnded = false;
  D2dTripStatus _tripStatus = D2dTripStatus.unknown;

  ViewState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get actionErrorMessage => _actionErrorMessage;
  bool get isTripEnded => _tripEnded;
  D2dTripStatus get tripStatus => _tripStatus;
  DriverModel? get driver => _driver;
  List<D2dCommuterModel> get commuters => _commuters;
  List<D2dCommuterModel> get alreadyInCommuters => _alreadyInCommuters;
  bool get isAscending => _isAscending;
  bool get connectionLost => _connectionLost;
  String? get connectedBatchId => _connectedBatchId;

  /// Binds an active batch for lifecycle resume tests without opening a socket.
  @visibleForTesting
  void bindActiveBatchForLifecycle(String batchId) {
    _connectedBatchId = batchId;
  }

  String? get driverMobile {
    final mobile = _driver?.userId?.mobileNumber?.trim();
    if (mobile != null && mobile.isNotEmpty) return mobile;
    return null;
  }

  String? get driverName => _driver?.userId?.username;

  void clearActionError() {
    if (_actionErrorMessage == null) return;
    _actionErrorMessage = null;
    _safeNotifyListeners();
  }

  Future<void> fetchTripStatus(String batchId) async {
    final result = await _d2dRepository.getLogStatus(batchId);
    if (_isDisposed) return;

    if (result.isSuccess && result.data != null) {
      _tripStatus = result.data!;
    } else {
      _tripStatus = D2dTripStatus.none;
    }
    _safeNotifyListeners();
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  void connect(String batchId) {
    unawaited(_connectGuarded(batchId));
  }

  Future<void> _connectGuarded(String batchId) async {
    final networkGuard = _networkGuard;
    if (networkGuard != null) {
      final guard = await networkGuard.check(refresh: true);
      if (!guard.isOnline) {
        _connectedBatchId = batchId;
        _connectionLost = true;
        _state = ViewState.error;
        _errorMessage =
            guard.message ?? NetworkActionGuard.actionBlockedMessage;
        _safeNotifyListeners();
        return;
      }
    }

    disconnect(notify: false);

    _connectedBatchId = batchId;
    _connectionLost = false;
    _reconnectAttempts = 0;
    _state = ViewState.loading;
    _errorMessage = null;
    _actionErrorMessage = null;
    _tripEnded = false;
    _driver = null;
    _safeNotifyListeners();

    unawaited(_loadDriverForBatch(batchId));
    unawaited(_openSocket(batchId, _connectGeneration));
  }

  Future<void> _openSocket(String batchId, int generation) async {
    try {
      final wsBaseUrl = AppConfig.instance.webSocketUrl;
      final uri = Uri.parse('$wsBaseUrl$batchId/');
      final cookies = await SessionManager().buildCookieHeader();
      final cookieHeader = cookies.entries
          .where((entry) => entry.value.isNotEmpty)
          .map((entry) => '${entry.key}=${entry.value}')
          .join('; ');

      if (_isDisposed || generation != _connectGeneration) return;

      if (kDebugMode) {
        debugPrint('D2D: Connecting to WebSocket: $uri');
      }

      _channel = IOWebSocketChannel.connect(
        uri,
        headers: {
          if (cookieHeader.isNotEmpty) HttpHeaders.cookieHeader: cookieHeader,
        },
      );
      _isConnected = true;

      _subscription = _channel!.stream.listen(
        _handleWebSocketMessage,
        onError: (error) {
          if (!_isConnected || _isDisposed) return;
          if (_isEndedTripClose(error)) {
            _handleTripEndedClose();
            return;
          }
          if (_isAuthClose(error)) {
            _handleAuthClose();
            return;
          }
          if (kDebugMode) {
            debugPrint('D2D: WebSocket error: $error');
          }
          _handleUnexpectedDisconnect(
            message:
                'Live connection failed. Please check your internet and try again.',
          );
        },
        onDone: () {
          unawaited(_handleSocketDone());
        },
      );

      _safeNotifyListeners();
    } catch (e) {
      if (_isDisposed || generation != _connectGeneration) return;
      if (kDebugMode) {
        debugPrint('D2D: Connection exception: $e');
      }
      _isConnected = false;
      _state = ViewState.error;
      _errorMessage = "Failed to connect to the live channel. ${e.toString()}";
      _safeNotifyListeners();
    }
  }

  Future<void> _handleSocketDone() async {
    if (!_isConnected || _isDisposed) return;

    // closeCode may not be populated synchronously on some platforms.
    await Future<void>.delayed(Duration.zero);
    final closeCode = _channel?.closeCode;
    if (kDebugMode) {
      debugPrint(
        'D2D: WebSocket closed (code: $closeCode, reason: ${_channel?.closeReason})',
      );
    }

    if (_tripEnded || _isEndedTripClose(null)) {
      _markTripEnded();
      return;
    }
    if (_isAuthClose(null)) {
      _handleAuthClose();
      return;
    }
    _handleUnexpectedDisconnect();
  }

  bool _isEndedTripClose(Object? error) {
    if (_channel?.closeCode == _endedTripCloseCode) return true;
    final errorText = error?.toString() ?? '';
    return errorText.contains('4001');
  }

  bool _isAuthClose(Object? error) {
    final code = _channel?.closeCode;
    if (code == _unauthorizedCloseCode || code == _forbiddenCloseCode) {
      return true;
    }
    final errorText = error?.toString() ?? '';
    return errorText.contains('4401') || errorText.contains('4403');
  }

  void _handleAuthClose() {
    if (!_isConnected || _isDisposed) return;

    if (kDebugMode) {
      debugPrint('D2D: Auth rejected (close code ${_channel?.closeCode})');
    }

    _isConnected = false;
    _subscription?.cancel();
    _subscription = null;
    _channel = null;
    _state = ViewState.error;
    _errorMessage = _unauthorizedMessage;
    _safeNotifyListeners();

    final callback = _onSessionInvalidated;
    if (callback != null) {
      unawaited(callback());
    }
  }

  void _handleTripEndedClose() {
    _markTripEnded();
  }

  void _handleUnexpectedDisconnect({String? message}) {
    if (_tripEnded || _isDisposed) return;

    _isConnected = false;
    _subscription?.cancel();
    _subscription = null;
    _channel = null;
    _connectionLost = true;

    final keepUiUsable = _commuters.isNotEmpty ||
        _tripStatus == D2dTripStatus.active ||
        (_connectedBatchId != null && !_tripEnded);

    if (keepUiUsable) {
      _state = ViewState.success;
      _errorMessage = message ?? _connectionLostMessage;
    } else {
      _state = ViewState.error;
      _errorMessage = message ?? _connectionLostMessage;
    }
    _safeNotifyListeners();

    if (!_lifecyclePaused && _connectedBatchId != null) {
      unawaited(_reconnectAfterDrop(_connectedBatchId!));
    }
  }

  /// Called when the OS moves the app to background or foreground.
  void onLifecyclePhase(AppLifecyclePhase phase) {
    _lifecyclePaused = isBackgroundPhase(phase);
  }

  /// Refreshes live state after resume from background / sleep-wake.
  Future<void> onAppResumed({required bool isOnline}) async {
    final batchId = _connectedBatchId;
    if (batchId == null || _isDisposed || _tripEnded) return;

    if (!isOnline) {
      _connectionLost = true;
      if (_commuters.isNotEmpty) {
        _state = ViewState.success;
      } else {
        _state = ViewState.error;
      }
      _errorMessage = _offlineMessage;
      _safeNotifyListeners();
      return;
    }

    await fetchTripStatus(batchId);
    if (_isDisposed || _tripEnded) return;

    if (!_isConnected || _connectionLost) {
      await _reconnectAfterDrop(batchId);
    }
  }

  Future<void> _reconnectAfterDrop(String batchId) async {
    if (_isDisposed || _tripEnded) return;
    if (_isConnected && _channel != null) return;

    if (_reconnectAttempts >= _maxReconnectAttempts) {
      if (kDebugMode) {
        debugPrint(
          'D2D: Reconnect stopped after $_reconnectAttempts attempts',
        );
      }
      _connectionLost = true;
      if (_connectedBatchId != null && !_tripEnded) {
        _state = ViewState.success;
        _errorMessage =
            'Live connection unavailable. KM and QR still work — tap Retry on the banner.';
      }
      _safeNotifyListeners();
      return;
    }

    _reconnectAttempts++;
    final backoffMs = 400 * _reconnectAttempts.clamp(1, 6);
    await Future<void>.delayed(Duration(milliseconds: backoffMs));
    if (_isDisposed || _tripEnded) return;

    _connectionLost = false;
    _errorMessage = null;
    if (_commuters.isEmpty) {
      _state = ViewState.loading;
    }
    _safeNotifyListeners();

    final generation = ++_connectGeneration;
    await _openSocket(batchId, generation);
  }

  void _markTripEnded() {
    if (_isDisposed) return;
    if (_tripEnded && _state == ViewState.error) {
      _isConnected = false;
      return;
    }

    if (kDebugMode) {
      debugPrint(
        'D2D: Trip already ended (close code ${_channel?.closeCode})',
      );
    }

    _isConnected = false;
    _subscription?.cancel();
    _subscription = null;
    try {
      _channel?.sink.close();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('D2D: Error closing ended-trip socket: $e');
      }
    }
    _channel = null;
    _commuters = [];
    _alreadyInCommuters = [];
    _tripEnded = true;
    _tripStatus = D2dTripStatus.ended;
    _state = ViewState.error;
    _errorMessage = _tripEndedMessage;
    _safeNotifyListeners();
  }

  void _handleWebSocketMessage(dynamic rawData) {
    if (!_isConnected || _isDisposed) return;

    try {
      final decodedData = _decodePayload(rawData);
      if (decodedData == null) return;

      final errorCode = decodedData['error'];
      if (errorCode != null) {
        _actionErrorMessage = _resolveActionErrorMessage(
          errorCode.toString(),
          decodedData['message']?.toString(),
        );
        if (kDebugMode) {
          debugPrint('D2D: Action error: $_actionErrorMessage');
        }
        _safeNotifyListeners();
        return;
      }

      final result = decodedData['result'];
      if (result is! Map) return;

      _actionErrorMessage = null;

      final resultMap = Map<String, dynamic>.from(result);

      if (d2dResultMarksTripEnded(resultMap)) {
        _markTripEnded();
        return;
      }

      _connectionLost = false;
      _errorMessage = null;
      _reconnectAttempts = 0;

      if (resultMap['driver'] is Map) {
        try {
          _driver = DriverModel.fromJson(
            Map<String, dynamic>.from(resultMap['driver'] as Map),
          );
        } catch (e) {
          if (kDebugMode) {
            debugPrint('D2D: Skipping invalid driver payload: $e');
          }
        }
      }

      final parsedCommuters = _parseCommutersFromData(resultMap['data']);
      if (parsedCommuters != null) {
        _commuters = parsedCommuters;
        _sortCommuters();
      }

      final parsedAlreadyIn = parseAlreadyInFromResult(resultMap);
      if (parsedAlreadyIn != null) {
        _alreadyInCommuters = parsedAlreadyIn;
      }

      _state = ViewState.success;
      _safeNotifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('D2D: Error parsing WebSocket data: $e');
        debugPrint('D2D: Raw payload: $rawData');
      }
    }
  }

  Map<String, dynamic>? _decodePayload(dynamic rawData) {
    if (rawData is Map<String, dynamic>) return rawData;
    if (rawData is Map) return Map<String, dynamic>.from(rawData);

    if (rawData is String) {
      final decoded = json.decode(rawData);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      if (decoded is String) {
        final nested = json.decode(decoded);
        if (nested is Map<String, dynamic>) return nested;
        if (nested is Map) return Map<String, dynamic>.from(nested);
      }
    }

    return null;
  }

  String _resolveActionErrorMessage(String errorCode, String? serverMessage) {
    final trimmed = serverMessage?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    return _fallbackLabelForErrorCode(errorCode);
  }

  String _fallbackLabelForErrorCode(String errorCode) {
    switch (errorCode) {
      case 'capacity_full':
        return 'Cab is at capacity';
      case 'no_live_state':
        return 'Trip is not active';
      case 'invalid_commuter':
        return 'Commuter not found or has no pick-up point';
      case 'no_driver':
      case 'no_cab':
        return 'Batch missing driver or cab';
      case 'unknown_action':
        return 'Unsupported action';
      case 'forbidden':
        return 'You are not allowed to change this live trip.';
      default:
        return 'Action failed';
    }
  }

  List<D2dCommuterModel>? _parseCommutersFromData(dynamic data) {
    if (data == null) return null;

    if (data is List) {
      final commuters = <D2dCommuterModel>[];
      for (final item in data) {
        final commuterJson = _unwrapCommuterEntry(item);
        if (commuterJson != null) {
          commuters.add(D2dCommuterModel.fromJson(commuterJson));
        }
      }
      return commuters;
    }

    if (data is Map) {
      final commuters = <D2dCommuterModel>[];
      for (final entry in data.entries) {
        final commuterJson = _unwrapCommuterEntry({entry.key: entry.value});
        if (commuterJson != null) {
          commuters.add(D2dCommuterModel.fromJson(commuterJson));
        }
      }
      return commuters;
    }

    return null;
  }

  /// Unwraps `{ "4": { ...fields } }` and merges the outer key as commuter id.
  Map<String, dynamic>? _unwrapCommuterEntry(dynamic item) {
    if (item is! Map) return null;

    final map = Map<String, dynamic>.from(item);

    if (map.length == 1) {
      final entry = map.entries.first;
      final inner = entry.value;

      if (inner is Map) {
        final commuter = Map<String, dynamic>.from(inner);
        final id = int.tryParse(entry.key.toString());
        commuter.putIfAbsent('id', () => id ?? entry.key);
        return commuter;
      }

      if (inner is String) {
        try {
          final decoded = json.decode(inner);
          return _unwrapCommuterEntry({entry.key: decoded});
        } catch (_) {
          final id = int.tryParse(entry.key.toString());
          return {
            'id': id ?? entry.key,
            'username': inner,
          };
        }
      }
    }

    if (_looksLikeCommuter(map)) return map;

    return null;
  }

  Future<void> _loadDriverForBatch(String batchId) async {
    final result = await _driverRepository.getDriverByBatch(batchId);
    if (_isDisposed || !_isConnected) return;

    if (result.isSuccess && result.data != null) {
      _driver = result.data;
      _safeNotifyListeners();
      return;
    }

    if (kDebugMode) {
      debugPrint(
        'D2D: Could not load driver for batch $batchId: '
        '${result.failure?.message}',
      );
    }
  }

  bool _looksLikeCommuter(Map<String, dynamic> json) {
    return json.containsKey('userId') ||
        json.containsKey('username') ||
        json.containsKey('mobile_number') ||
        json.containsKey('mobileNumber') ||
        json.containsKey('pickUpPoint') ||
        json.containsKey('popId') ||
        json.containsKey('inLine');
  }

  void disconnect({bool notify = true}) {
    _connectGeneration++;
    if (!_isConnected && _channel == null && _subscription == null) {
      if (_connectedBatchId == null) return;
    }

    if (kDebugMode) {
      debugPrint('D2D: Disconnecting WebSocket');
    }

    _isConnected = false;
    _subscription?.cancel();
    _subscription = null;
    try {
      _channel?.sink.close();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('D2D: Error closing WebSocket: $e');
      }
    }
    _channel = null;
    _commuters = [];
    _alreadyInCommuters = [];
    _driver = null;
    _actionErrorMessage = null;
    _connectionLost = false;
    _connectedBatchId = null;
    _reconnectAttempts = 0;
    _state = ViewState.idle;

    if (notify) {
      _safeNotifyListeners();
    }
  }

  void toggleSortOrder() {
    _isAscending = !_isAscending;
    _sortCommuters();
    _safeNotifyListeners();
  }

  void _sortCommuters() {
    _commuters.sort((a, b) {
      final sortKeyA = a.inLine ?? 0;
      final sortKeyB = b.inLine ?? 0;
      return _isAscending
          ? sortKeyA.compareTo(sortKeyB)
          : sortKeyB.compareTo(sortKeyA);
    });
  }

  String? get _sessionRole => sessionRoleOverride ?? SessionRole.userType;

  bool _guardAction(D2dChannelAction action) {
    final role = _sessionRole;
    if (D2dChannelRolePolicy.can(role, action)) return true;
    _actionErrorMessage = D2dChannelRolePolicy.denialMessage(action);
    _safeNotifyListeners();
    return false;
  }

  /// Add commuter to the live fly list (admin or driver).
  bool addCommuter(String commuterId) {
    if (!_guardNetwork()) return false;
    if (!_guardAction(D2dChannelAction.addCommuter)) return false;

    final id = _parseCommuterId(commuterId);
    if (id == 0) {
      if (kDebugMode) {
        debugPrint('D2D: Skipping ADD — invalid commuter id');
      }
      return false;
    }

    if (!_isConnected || _channel == null) {
      _actionErrorMessage = _tripEnded
          ? _tripEndedMessage
          : _connectionLost
              ? _connectionLostMessage
              : 'Live channel is not connected.';
      _safeNotifyListeners();
      return false;
    }

    // Backend expects a scalar CLIST for ADD (not an array).
    _sendPayload({
      'ACTION': 'ADD',
      'CLIST': id,
    });
    return true;
  }

  /// Remove commuter from live queue (admin or driver).
  bool removeCommuter(String commuterId) {
    if (!_guardNetwork()) return false;
    if (!_guardAction(D2dChannelAction.removeFromQueue)) return false;
    return _sendAction('DELETE', _parseCommuterId(commuterId));
  }

  /// Driver confirms pickup — moves rider to Already IN (REMOVE on wire).
  bool confirmCommuter(String commuterId) {
    if (!_guardNetwork()) return false;
    if (!_guardAction(D2dChannelAction.confirmPickup)) return false;
    return _sendAction('REMOVE', _parseCommuterId(commuterId));
  }

  /// Remove commuter from live queue (driver swipe red).
  bool denyCommuter(String commuterId) {
    if (!_guardNetwork()) return false;
    if (!_guardAction(D2dChannelAction.removeFromQueue)) return false;
    return _sendAction('DELETE', _parseCommuterId(commuterId));
  }

  /// End the trip for the day — driver only. Admin Close channel must not call this.
  bool stopTrip() {
    if (!_guardNetwork()) return false;
    if (!_guardAction(D2dChannelAction.stopTrip)) return false;
    _sendStopAction();
    disconnect(notify: false);
    return true;
  }

  bool _guardNetwork() {
    final networkGuard = _networkGuard;
    if (networkGuard == null || networkGuard.appearsOnline) return true;
    _actionErrorMessage = NetworkActionGuard.actionBlockedMessage;
    _safeNotifyListeners();
    return false;
  }

  int _parseCommuterId(String commuterId) => int.tryParse(commuterId) ?? 0;

  bool _sendAction(String action, int commuterId) {
    if (commuterId == 0) {
      if (kDebugMode) {
        debugPrint('D2D: Skipping $action — invalid commuter id');
      }
      return false;
    }

    if (!_isConnected || _channel == null) {
      _actionErrorMessage = _tripEnded
          ? _tripEndedMessage
          : _connectionLost
              ? _connectionLostMessage
              : 'Live channel is not connected.';
      _safeNotifyListeners();
      return false;
    }

    _sendPayload({
      'ACTION': action,
      'CLIST': [commuterId],
    });
    return true;
  }

  void _sendStopAction() {
    _sendPayload({'ACTION': 'STOP'});
  }

  void _sendPayload(Map<String, dynamic> payload) {
    if (_channel == null) {
      if (kDebugMode) {
        debugPrint('D2D: Cannot send $payload — WebSocket not connected');
      }
      return;
    }

    final message = json.encode(payload);
    if (kDebugMode) {
      debugPrint('D2D: Sending $message');
    }
    _channel!.sink.add(message);
  }

  @override
  void dispose() {
    _isDisposed = true;
    disconnect(notify: false);
    super.dispose();
  }
}
