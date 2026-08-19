import 'package:cts/appManager/app_class.dart';
import 'package:flutter/material.dart';

/// Former auto-redirect to offline temp when offline.
///
/// P5 degraded mode: stay on the current screen and rely on [NetworkDegradedBanner]
/// plus [NetworkActionGuard] pre-checks. Full offline_temp remains in the drawer.
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
  @override
  Widget build(BuildContext context) => widget.child;
}
