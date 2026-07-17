import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Wraps connectivity checks and exposes a simple online/offline stream.
class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final StreamController<bool> _onlineController =
      StreamController<bool>.broadcast();

  Stream<bool> get onOnlineStatusChanged => _onlineController.stream;

  Future<bool> get isOnline async {
    final results = await _connectivity.checkConnectivity();
    return _hasConnection(results);
  }

  void startListening() {
    _subscription ??= _connectivity.onConnectivityChanged.listen((results) {
      _onlineController.add(_hasConnection(results));
    });
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    await _onlineController.close();
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }
}
