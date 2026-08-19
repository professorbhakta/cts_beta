import 'dart:async';

import 'package:cts/api/connectivity_service.dart';
import 'package:cts/core/network/network_action_guard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// App-wide overlay banner when connectivity is lost (degraded mode).
class NetworkDegradedBanner extends StatefulWidget {
  const NetworkDegradedBanner({super.key, required this.child});

  final Widget child;

  @override
  State<NetworkDegradedBanner> createState() => _NetworkDegradedBannerState();
}

class _NetworkDegradedBannerState extends State<NetworkDegradedBanner> {
  StreamSubscription<bool>? _onlineSub;
  bool _isOnline = true;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final connectivity = context.read<ConnectivityService>();
    unawaited(_syncInitial(connectivity));
    _onlineSub = connectivity.onOnlineStatusChanged.listen((online) {
      if (!mounted) return;
      setState(() => _isOnline = online);
    });
  }

  Future<void> _syncInitial(ConnectivityService connectivity) async {
    final online = await connectivity.isOnline;
    if (mounted) setState(() => _isOnline = online);
  }

  @override
  void dispose() {
    _onlineSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (!_isOnline)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildBanner(context),
          ),
      ],
    );
  }

  Widget _buildBanner(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 4,
      color: theme.colorScheme.errorContainer,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.wifi_off_rounded,
                color: theme.colorScheme.onErrorContainer,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  NetworkActionGuard.bannerMessage,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
