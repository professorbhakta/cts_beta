import 'dart:async';

import 'package:cts/app/app_providers.dart';
import 'package:cts/app/router/app_router.dart';
import 'package:cts/app/router/session_auth_notifier.dart';
import 'package:cts/app/session_invalidation.dart';
import 'package:cts/theme/app_theme.dart';
import 'package:cts/appManager/snackbar_service.dart';
import 'package:cts/api/connectivity_service.dart';
import 'package:cts/core/sync/sync_manager.dart';
import 'package:cts/features/batches/repositories/offline_first_batch_repository.dart';
import 'package:cts/api/base_api_services.dart';
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
    required this.onSessionInvalidated,
  });

  final BaseApiServices apiService;
  final ConnectivityService connectivityService;
  final SyncManager syncManager;
  final OfflineFirstBatchRepository offlineFirstBatchRepository;
  final SessionAuthNotifier sessionAuthNotifier;
  final SessionInvalidatedCallback onSessionInvalidated;

  @override
  State<CtsApp> createState() => _CtsAppState();
}

class _CtsAppState extends State<CtsApp> {
  late final GoRouter _router = createAppRouter(
    authNotifier: widget.sessionAuthNotifier,
    navigatorKey: SnackBarService.navigatorKey,
  );

  @override
  void dispose() {
    widget.syncManager.dispose();
    unawaited(widget.connectivityService.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.build(
        apiService: widget.apiService,
        connectivityService: widget.connectivityService,
        syncManager: widget.syncManager,
        offlineFirstBatchRepository: widget.offlineFirstBatchRepository,
        sessionAuthNotifier: widget.sessionAuthNotifier,
        onSessionInvalidated: widget.onSessionInvalidated,
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
