import 'package:cts/api/connectivity_service.dart';

/// How mutating actions behave when the device has no network.
///
/// P5 uses [requireOnline] only. [queueWhenOffline] is reserved for a future
/// offline queue/replay path (see [SyncManager] + entity handlers).
enum NetworkActionPolicy {
  requireOnline,
  queueWhenOffline,
}

/// Result of a pre-action connectivity check.
sealed class NetworkGuardResult {
  const NetworkGuardResult();

  bool get isOnline => this is NetworkGuardOnline;
  String? get message =>
      this is NetworkGuardOffline ? (this as NetworkGuardOffline).message : null;
}

class NetworkGuardOnline extends NetworkGuardResult {
  const NetworkGuardOnline();
}

class NetworkGuardOffline extends NetworkGuardResult {
  const NetworkGuardOffline({required this.message});

  @override
  final String message;
}

/// Pre-check helper for live-trip and return-batch mutations.
///
/// Uses the app-scoped [ConnectivityService] — no extra plugin listeners.
class NetworkActionGuard {
  NetworkActionGuard(this._connectivity);

  final ConnectivityService _connectivity;

  static const String actionBlockedMessage =
      'No internet connection. Connect to the network to continue.';

  static const String bannerMessage =
      'You are offline. Live updates and server actions are unavailable.';

  /// Fast read of last-known connectivity (null until first probe → assume online).
  bool get appearsOnline => _connectivity.isOnlineCached;

  /// Returns [NetworkGuardOnline] when the device can reach the network.
  ///
  /// [queueWhenOffline] is not implemented in P5 — always fails closed like
  /// [requireOnline] until queue handlers exist per entity type.
  Future<NetworkGuardResult> check({
    NetworkActionPolicy policy = NetworkActionPolicy.requireOnline,
    bool refresh = false,
  }) async {
    // Extension point: when queueWhenOffline is implemented, enqueue here instead
    // of blocking. For P5, both policies fail closed without queue/replay.
    assert(
      policy == NetworkActionPolicy.requireOnline ||
          policy == NetworkActionPolicy.queueWhenOffline,
      'Unknown NetworkActionPolicy',
    );

    final online = refresh
        ? await _connectivity.refreshOnlineStatus()
        : await _connectivity.isOnline;

    if (online) return const NetworkGuardOnline();
    return const NetworkGuardOffline(message: actionBlockedMessage);
  }
}
