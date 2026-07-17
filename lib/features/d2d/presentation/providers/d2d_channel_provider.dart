import 'dart:async';
import 'dart:convert';

import 'package:cts/appManager/app_class.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/models/d2d_commuter_model.dart';
import 'package:cts/models/driver_model.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class D2dChannelProvider with ChangeNotifier {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  DriverModel? _driver;
  List<D2dCommuterModel> _commuters = [];
  bool _isAscending = true;

  ViewState _state = ViewState.idle;
  String? _errorMessage;

  ViewState get state => _state;
  String? get errorMessage => _errorMessage;
  DriverModel? get driver => _driver;
  List<D2dCommuterModel> get commuters => _commuters;
  bool get isAscending => _isAscending;

  void connect(String batchId) {
    if (_channel != null) {
      disconnect(); // Clean up existing connection first
    }

    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Use AppConfig for WebSocket URL instead of hardcoded localhost
      final wsBaseUrl = AppConfig.instance.webSocketUrl;
      final uri = Uri.parse('$wsBaseUrl$batchId/');

      if (kDebugMode) {
        debugPrint('D2D: Connecting to WebSocket: $uri');
      }

      _channel = WebSocketChannel.connect(uri);

      _subscription = _channel!.stream.listen(
        (data) {
          try {
            final decodedData = json.decode(data);
            if (decodedData['result'] != null &&
                decodedData['result']['data'] is List) {
              if (decodedData['result']['driver'] != null) {
                _driver = DriverModel.fromJson(decodedData['result']['driver']);
              }

              _commuters = (decodedData['result']['data'] as List)
                  .map((item) => D2dCommuterModel.fromJson(item.values.first))
                  .toList();

              _sortCommuters();
              _state = ViewState.success;
              notifyListeners();
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint('D2D: Error parsing WebSocket data: $e');
            }
            _state = ViewState.error;
            _errorMessage = "Failed to parse data from server.";
            notifyListeners();
          }
        },
        onError: (error) {
          if (kDebugMode) {
            debugPrint('D2D: WebSocket error: $error');
          }
          _state = ViewState.error;
          _errorMessage =
              "Live connection failed. Please check your internet and try again.";
          notifyListeners();
        },
        onDone: () {
          if (kDebugMode) {
            debugPrint('D2D: WebSocket connection closed');
          }
          _state = ViewState.idle;
          notifyListeners();
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('D2D: Connection exception: $e');
      }
      _state = ViewState.error;
      _errorMessage = "Failed to connect to the live channel. ${e.toString()}";
      notifyListeners();
    }
  }

  void disconnect() {
    if (kDebugMode) {
      debugPrint('D2D: Disconnecting WebSocket');
    }
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
    _driver = null;
    _state = ViewState.idle;
    notifyListeners();
  }

  void toggleSortOrder() {
    _isAscending = !_isAscending;
    _sortCommuters();
    notifyListeners();
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

  void removeCommuter(String commuterId) {
    final command = {
      "ACTION": "DELETE",
      "CLIST": [int.tryParse(commuterId) ?? 0],
    };
    _channel?.sink.add(json.encode(command));
  }

  void confirmCommuter(String commuterId) {
    final command = {
      "ACTION": "ADD",
      "CLIST": [int.tryParse(commuterId) ?? 0],
    };
    _channel?.sink.add(json.encode(command));
  }

  void denyCommuter(String commuterId) {
    final command = {
      "ACTION": "DELETE",
      "CLIST": [int.tryParse(commuterId) ?? 0],
    };
    _channel?.sink.add(json.encode(command));
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
