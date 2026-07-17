import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cts/appManager/app_class.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Sends Admin/Driver users to offline mode when there is no connection.
class OfflineAutoRedirect extends StatefulWidget {
  const OfflineAutoRedirect({required this.child, super.key});

  final Widget child;

  static bool isOfflineRole() {
    final userType = AppManager.instance.getString(ManagerKey.userType);
    if (userType == 'ADMIN' || userType == 'DRIVER') return true;

    // Fallback when session flags are set but user_type string is missing.
    return AppClass.userType == 1 || AppClass.userType == 2;
  }

  static Future<bool> isDeviceOffline() async {
    final results = await Connectivity().checkConnectivity();
    return results.every((result) => result == ConnectivityResult.none);
  }

  @override
  State<OfflineAutoRedirect> createState() => _OfflineAutoRedirectState();
}

class _OfflineAutoRedirectState extends State<OfflineAutoRedirect> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirectIfNeeded());
    Connectivity().onConnectivityChanged.listen((_) => _redirectIfNeeded());
  }

  Future<void> _redirectIfNeeded() async {
    if (!mounted || !OfflineAutoRedirect.isOfflineRole()) return;

    final isOffline = await OfflineAutoRedirect.isDeviceOffline();
    if (!isOffline || !mounted) return;

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
