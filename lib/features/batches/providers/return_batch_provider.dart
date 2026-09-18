import 'package:cts/api/api_result.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/core/concurrency/batched_runner.dart';
import 'package:cts/core/network/network_action_guard.dart';
import 'package:cts/features/batches/models/return_available_model.dart';
import 'package:cts/features/batches/models/return_batch_status_model.dart';
import 'package:cts/features/batches/repositories/return_batch_repository.dart';
import 'package:cts/features/commuters/models/commuter_model.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cts/appManager/app_class.dart';
import 'package:cts/appManager/session_manager.dart';
import 'package:cts/features/batches/helpers/return_live_ws.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ReturnBatchProvider with ChangeNotifier {
  ReturnBatchProvider(
    this._repository, {
    NetworkActionGuard? networkGuard,
    int statusFetchConcurrency = defaultStatusFetchConcurrency,
  })  : _networkGuard = networkGuard,
        _statusFetchConcurrency = statusFetchConcurrency;

  static const int defaultStatusFetchConcurrency = 10;

  final ReturnBatchRepository _repository;
  final NetworkActionGuard? _networkGuard;
  final int _statusFetchConcurrency;

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _activeBatchId;
  String? get activeBatchId => _activeBatchId;

  List<CommuterModel> _homeCommuters = [];
  List<CommuterModel> get homeCommuters => _homeCommuters;

  List<CommuterModel> _overflowCommuters = [];
  List<CommuterModel> get overflowCommuters => _overflowCommuters;

  List<CommuterModel> _waitingCommuters = [];
  List<CommuterModel> get waitingCommuters => _waitingCommuters;

  List<CommuterModel> get availableCommuters => [
    ..._homeCommuters,
    ..._overflowCommuters,
  ];

  List<CommuterModel> _confirmedCommuters = [];
  List<CommuterModel> get confirmedCommuters => _confirmedCommuters;

  ReturnBatchCapacityModel? _capacity;
  ReturnBatchCapacityModel? get capacity => _capacity;

  final Map<String, ReturnBatchStatusModel> _statusByBatchId = {};
  Map<String, ReturnBatchStatusModel> get statusByBatchId => _statusByBatchId;

  bool _actionInProgress = false;
  bool get actionInProgress => _actionInProgress;

  int _loadGeneration = 0;

  WebSocketChannel? _liveChannel;
  StreamSubscription? _liveSubscription;
  int _liveGeneration = 0;
  bool _liveConnected = false;
  bool _liveEnded = false;
  String? _liveBatchId;
  String? _lastLiveEvent;

  bool get liveConnected => _liveConnected;
  bool get liveEnded => _liveEnded;
  String? get lastLiveEvent => _lastLiveEvent;

  bool get hasTripData =>
      _homeCommuters.isNotEmpty ||
      _overflowCommuters.isNotEmpty ||
      _waitingCommuters.isNotEmpty ||
      _confirmedCommuters.isNotEmpty ||
      _capacity != null;

  bool isDisplayingBatch(String batchId) => _activeBatchId == batchId;

  @visibleForTesting
  void bindActiveBatchForTesting(String batchId) {
    _activeBatchId = batchId;
  }

  /// Clears trip lists immediately when opening a different batch (before async load).
  void beginReturnTripLoad(String batchId, {bool keepExistingData = false}) {
    _activeBatchId = batchId;
    _state = ViewState.loading;
    _errorMessage = null;
    if (!keepExistingData) {
      _clearTripLists();
    }
    notifyListeners();
  }

  Future<void> fetchStatusesForBatches(List<String> batchIds) async {
    if (batchIds.isEmpty) return;

    await runWithConcurrency(
      batchIds,
      concurrency: _statusFetchConcurrency,
      task: (batchId) async {
        final result = await _repository.getReturnBatchStatus(batchId);
        if (result.isSuccess && result.data != null) {
          _statusByBatchId[batchId] = result.data!;
          notifyListeners();
        }
        return result;
      },
    );
  }

  ReturnBatchStatusModel? statusForBatch(String batchId) =>
      _statusByBatchId[batchId];

  Future<void> loadReturnTrip(
    String batchId, {
    bool keepExistingData = false,
  }) async {
    final generation = ++_loadGeneration;
    beginReturnTripLoad(batchId, keepExistingData: keepExistingData);

    final results = await Future.wait([
      _repository.getAvailableCommuters(batchId),
      _repository.getConfirmedCommuters(batchId),
      _repository.getReturnBatchStatus(batchId),
    ]);

    if (generation != _loadGeneration) return;

    final availableResult = results[0] as ApiResult<ReturnAvailableResult>;
    final confirmedResult = results[1] as ApiResult<ReturnBatchConfirmedResult>;
    final statusResult = results[2] as ApiResult<ReturnBatchStatusModel>;

    if (availableResult.isFailure) {
      _errorMessage = availableResult.failure?.message;
      _state = ViewState.error;
      notifyListeners();
      return;
    }

    if (confirmedResult.isFailure) {
      _errorMessage = confirmedResult.failure?.message;
      _state = ViewState.error;
      notifyListeners();
      return;
    }

    final confirmed = confirmedResult.data?.commuters ?? [];
    final confirmedIds = {
      ...?confirmedResult.data?.confirmedUserIds,
      for (final commuter in confirmed)
        if (commuter.userId?.id != null) commuter.userId!.id.toString(),
    };
    _confirmedCommuters = confirmed;
    bool isOpen(CommuterModel commuter) {
      final id = commuter.userId?.id?.toString();
      return id != null && !confirmedIds.contains(id);
    }

    final split = availableResult.data ??
        const ReturnAvailableResult(home: [], overflow: []);
    _waitingCommuters = split.waiting;
    final waitingIds = {
      for (final commuter in _waitingCommuters)
        if (commuter.userId?.id != null) commuter.userId!.id.toString(),
    };
    _homeCommuters =
        split.home.where(isOpen).where((c) {
          final id = c.userId?.id?.toString();
          return id == null || !waitingIds.contains(id);
        }).toList();
    _overflowCommuters =
        split.overflow.where(isOpen).where((c) {
          final id = c.userId?.id?.toString();
          return id == null || !waitingIds.contains(id);
        }).toList();
    _capacity = confirmedResult.data?.capacity;
    if (statusResult.isSuccess && statusResult.data != null) {
      _statusByBatchId[batchId] = statusResult.data!;
    }
    _state = ViewState.success;
    notifyListeners();
  }

  Future<String?> confirmCommuter(String userId, String batchId) async {
    return _runAction(
      () => _repository.addCommuterToConfirmList(userId, batchId),
    );
  }

  Future<String?> removeCommuter(String userId, String batchId) async {
    return _runAction(
      () => _repository.removeCommuterFromConfirmList(userId, batchId),
    );
  }

  Future<String?> joinReturnWaiting(String userId, String batchId) async {
    return _runAction(
      () => _repository.joinReturnWaiting(userId, batchId),
    );
  }

  Future<String?> endReturnTrip(String batchId) async {
    final blocked = await _ensureOnlineForMutation();
    if (blocked != null) return blocked;

    _actionInProgress = true;
    notifyListeners();

    final result = await _repository.endReturnTrip(batchId);
    _actionInProgress = false;

    if (result.isFailure) {
      _errorMessage = result.failure?.message;
      notifyListeners();
      return _errorMessage;
    }

    _homeCommuters = [];
    _overflowCommuters = [];
    _waitingCommuters = [];
    _confirmedCommuters = [];
    _statusByBatchId.remove(batchId);
    _capacity = const ReturnBatchCapacityModel(
      totalCapacity: 0,
      remainingCapacity: 0,
      confirmedCount: 0,
      isActive: false,
    );
    _state = ViewState.success;
    notifyListeners();
    return null;
  }

  Future<String?> _runAction(
    Future<ApiResult<String>> Function() action,
  ) async {
    final batchId = _activeBatchId;
    if (batchId == null) return 'No active batch';

    final blocked = await _ensureOnlineForMutation();
    if (blocked != null) return blocked;

    _actionInProgress = true;
    notifyListeners();

    final result = await action();
    _actionInProgress = false;

    if (result.isFailure) {
      _errorMessage = result.failure?.message;
      notifyListeners();
      return _errorMessage;
    }

    await loadReturnTrip(batchId, keepExistingData: true);
    return result.data;
  }

  Future<void> onAppResumed({required bool isOnline}) async {
    final batchId = _activeBatchId;
    if (batchId == null || _actionInProgress || !isOnline) return;
    await loadReturnTrip(batchId, keepExistingData: true);
  }

  Future<String?> _ensureOnlineForMutation() async {
    final networkGuard = _networkGuard;
    if (networkGuard == null) return null;
    final guard = await networkGuard.check();
    if (guard.isOnline) return null;
    final message = guard.message ?? NetworkActionGuard.actionBlockedMessage;
    _errorMessage = message;
    notifyListeners();
    return message;
  }

  void clearActiveBatch() {
    disconnectReturnLive();
    _loadGeneration++;
    _activeBatchId = null;
    _clearTripLists();
    _state = ViewState.idle;
    _errorMessage = null;
    notifyListeners();
  }

  /// Full reset for logout — clears picker status cache too.
  void reset() {
    disconnectReturnLive();
    _loadGeneration++;
    _activeBatchId = null;
    _clearTripLists();
    _statusByBatchId.clear();
    _actionInProgress = false;
    _state = ViewState.idle;
    _errorMessage = null;
    notifyListeners();
  }

  /// Subscribe to return live fan-out: ws/return/<batchId>/ (JWT Bearer like morning).
  /// Board/unboard stay REST; this only applies status + optional list refresh.
  void connectReturnLive(String batchId) {
    unawaited(_connectReturnLiveGuarded(batchId));
  }

  Future<void> _connectReturnLiveGuarded(String batchId) async {
    final id = batchId.trim();
    if (id.isEmpty) return;
    disconnectReturnLive(notify: false);
    _liveBatchId = id;
    _liveEnded = false;
    _lastLiveEvent = null;
    final generation = ++_liveGeneration;
    await _openReturnLiveSocket(id, generation);
  }

  Future<void> _openReturnLiveSocket(String batchId, int generation) async {
    try {
      final uri = Uri.parse(
        buildReturnLiveWsUrl(
          wsBaseUrl: AppConfig.instance.webSocketUrl,
          batchId: batchId,
        ),
      );
      final access = await SessionManager().getAccessToken();
      if (generation != _liveGeneration) return;

      if (kDebugMode) {
        debugPrint('ReturnLive: Connecting $uri');
      }

      _liveChannel = IOWebSocketChannel.connect(
        uri,
        headers: {
          if (access != null && access.isNotEmpty)
            HttpHeaders.authorizationHeader: 'Bearer $access',
        },
      );
      _liveConnected = true;
      notifyListeners();

      _liveSubscription = _liveChannel!.stream.listen(
        (message) => _handleReturnLiveMessage(message, batchId, generation),
        onError: (error) {
          if (generation != _liveGeneration) return;
          if (kDebugMode) {
            debugPrint('ReturnLive: error $error');
          }
          _liveConnected = false;
          notifyListeners();
        },
        onDone: () {
          if (generation != _liveGeneration) return;
          _liveConnected = false;
          notifyListeners();
        },
        cancelOnError: false,
      );
    } catch (e, s) {
      if (kDebugMode) {
        debugPrint('ReturnLive: open failed $e\n$s');
      }
      if (generation == _liveGeneration) {
        _liveConnected = false;
        notifyListeners();
      }
    }
  }

  void _handleReturnLiveMessage(
    dynamic message,
    String batchId,
    int generation,
  ) {
    if (generation != _liveGeneration) return;
    try {
      final decoded = message is String ? jsonDecode(message) : message;
      final payload = ReturnLiveWsPayload.tryParse(decoded);
      if (payload == null) {
        if (kDebugMode) {
          debugPrint('ReturnLive: ignore unparsed message');
        }
        return;
      }

      _statusByBatchId[batchId] = payload.status;
      _lastLiveEvent = payload.event;
      _capacity = ReturnBatchCapacityModel(
        totalCapacity: payload.status.totalCapacity,
        remainingCapacity: payload.status.remainingCapacity,
        confirmedCount: payload.status.confirmedCount,
        isActive: payload.status.isActive,
      );

      if (payload.isEnded) {
        _liveEnded = true;
        disconnectReturnLive(notify: false);
        notifyListeners();
        return;
      }

      notifyListeners();
      if (payload.shouldRefreshLists) {
        unawaited(loadReturnTrip(batchId, keepExistingData: true));
      }
    } catch (e, s) {
      if (kDebugMode) {
        debugPrint('ReturnLive: handle failed $e\n$s');
      }
    }
  }

  void disconnectReturnLive({bool notify = true}) {
    _liveGeneration++;
    _liveSubscription?.cancel();
    _liveSubscription = null;
    try {
      _liveChannel?.sink.close();
    } catch (_) {}
    _liveChannel = null;
    _liveConnected = false;
    _liveBatchId = null;
    if (notify) notifyListeners();
  }

  /// Clears [liveEnded] after the UI has reacted (pop / snackbar).
  void acknowledgeLiveEnded() {
    if (!_liveEnded) return;
    _liveEnded = false;
    notifyListeners();
  }


  void _clearTripLists() {
    _homeCommuters = [];
    _overflowCommuters = [];
    _waitingCommuters = [];
    _confirmedCommuters = [];
    _capacity = null;
  }
}
