import 'package:cts/app/di/app_providers.dart';
import 'package:cts/app/router/app_router.dart';
import 'package:cts/app/router/session_auth_notifier.dart';
import 'package:cts/app/theme/app_theme.dart';
import 'package:cts/appManager/snackbar_service.dart';
import 'package:cts/core/network/connectivity_service.dart';
import 'package:cts/core/sync/sync_manager.dart';
import 'package:cts/features/batches/data/repositories/offline_first_batch_repository.dart';
import 'package:cts/core/network/base_api_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CtsApp extends StatefulWidget {
  const CtsApp({
    super.key,
    required this.apiService,
    required this.connectivityService,
    required this.syncManager,
    required this.offlineFirstBatchRepository,
    required this.sessionAuthNotifier,
  });

  final BaseApiServices apiService;
  final ConnectivityService connectivityService;
  final SyncManager syncManager;
  final OfflineFirstBatchRepository offlineFirstBatchRepository;
  final SessionAuthNotifier sessionAuthNotifier;

  @override
  State<CtsApp> createState() => _CtsAppState();
}

class _CtsAppState extends State<CtsApp> {
  late final GoRouter _router = createAppRouter(
    authNotifier: widget.sessionAuthNotifier,
    navigatorKey: SnackBarService.navigatorKey,
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.build(
        apiService: widget.apiService,
        connectivityService: widget.connectivityService,
        syncManager: widget.syncManager,
        offlineFirstBatchRepository: widget.offlineFirstBatchRepository,
        sessionAuthNotifier: widget.sessionAuthNotifier,
      ),
      child: MaterialApp.router(
        title: 'CTS',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        scaffoldMessengerKey: SnackBarService.scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
        builder: EasyLoading.init(),
      ),
    );
  }
}
