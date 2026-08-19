import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

/// Wraps connectivity checks and exposes a simple online/offline stream.
///
/// One plugin listener for the process. [isOnline] is cached after the first
/// probe so CRUD/sync do not hit Connectivity on every call.
class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final StreamController<bool> _onlineController =
      StreamController<bool>.broadcast();

  bool? _lastOnline;

  Stream<bool> get onOnlineStatusChanged => _onlineController.stream;

  Future<bool> get isOnline async {
    if (_lastOnline != null) return _lastOnline!;
    return refreshOnlineStatus();
  }

  /// Forces a fresh connectivity probe (e.g. after sleep/wake or app resume).
  Future<bool> refreshOnlineStatus() async => _refresh();

  void startListening() {
    if (_subscription != null) return;
    unawaited(_refresh());
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final online = _hasConnection(results);
      if (_lastOnline == online) return;
      _lastOnline = online;
      _onlineController.add(online);
    });
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    _lastOnline = null;
    await _onlineController.close();
  }

  Future<bool> _refresh() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final online = _hasConnection(results);
      _lastOnline = online;
      return online;
    } on MissingPluginException {
      return _lastOnline ?? true;
    }
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }
}
