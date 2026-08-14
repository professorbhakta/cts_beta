import 'dart:async';

import 'package:cts/api/connectivity_service.dart';
import 'package:cts/appManager/app_class.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Sends Admin/Driver users to offline mode when there is no connection.
///
/// Uses the app-scoped [ConnectivityService] — does not open another plugin
/// listener, and does not re-probe Connectivity on every event.
class OfflineAutoRedirect extends StatefulWidget {
  const OfflineAutoRedirect({required this.child, super.key});

  final Widget child;

  static bool isOfflineRole() {
    return SessionRole.isAdmin || SessionRole.isDriver;
  }

  @override
  State<OfflineAutoRedirect> createState() => _OfflineAutoRedirectState();
}

class _OfflineAutoRedirectState extends State<OfflineAutoRedirect> {
  StreamSubscription<bool>? _onlineSub;
  bool _listening = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_listening) return;
    _listening = true;
    if (!OfflineAutoRedirect.isOfflineRole()) return;

    final connectivity = _connectivityOf(context);
    if (connectivity == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_redirectIfOffline());
    });
    _onlineSub = connectivity.onOnlineStatusChanged.listen((isOnline) {
      if (!isOnline) unawaited(_redirectIfOffline());
    });
  }

  ConnectivityService? _connectivityOf(BuildContext context) {
    try {
      return context.read<ConnectivityService>();
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _onlineSub?.cancel();
    _onlineSub = null;
    super.dispose();
  }

  Future<void> _redirectIfOffline() async {
    if (!mounted || !OfflineAutoRedirect.isOfflineRole()) return;

    final connectivity = _connectivityOf(context);
    if (connectivity == null) return;
    final isOnline = await connectivity.isOnline;
    if (isOnline || !mounted) return;

    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == RouteName.offlineTempHome ||
        currentRoute == RouteName.offlineBatchCommuters) {
      return;
    }

    context.go(RouteName.offlineTempHome);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
