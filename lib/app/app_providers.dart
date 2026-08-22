import 'package:cts/api/base_api_services.dart';
import 'package:cts/api/network_api_services.dart';
import 'package:cts/app/router/session_auth_notifier.dart';
import 'package:cts/app/session_invalidation.dart';
import 'package:cts/features/admin_home/providers/admin_provider.dart';
import 'package:cts/features/batches/repositories/batch_repository_impl.dart';
import 'package:cts/features/batches/repositories/offline_first_batch_repository.dart';
import 'package:cts/features/batches/repositories/return_batch_repository_impl.dart';
import 'package:cts/features/batches/repositories/running_batch_repository_impl.dart';
import 'package:cts/features/batches/repositories/batch_repository.dart';
import 'package:cts/features/batches/repositories/return_batch_repository.dart';
import 'package:cts/features/batches/repositories/running_batch_repository.dart';
import 'package:cts/features/batches/providers/batch_controller.dart';
import 'package:cts/features/batches/providers/batch_form_provider.dart';
import 'package:cts/features/batches/providers/return_batch_provider.dart';
import 'package:cts/features/batches/providers/running_batch_provider.dart';
import 'package:cts/features/cabs/repositories/cab_repository_impl.dart';
import 'package:cts/features/cabs/repositories/cab_repository.dart';
import 'package:cts/features/cabs/providers/cab_controller.dart';
import 'package:cts/features/cabs/providers/cab_form_provider.dart';
import 'package:cts/features/pops/repositories/pop_repository_impl.dart';
import 'package:cts/features/pops/repositories/pop_repository.dart';
import 'package:cts/features/pops/providers/pop_controller.dart';
import 'package:cts/features/pops/providers/pop_form_provider.dart';
import 'package:cts/features/routes/repositories/route_repository_impl.dart';
import 'package:cts/features/routes/repositories/route_repository.dart';
import 'package:cts/features/routes/providers/route_controller.dart';
import 'package:cts/features/routes/providers/route_form_provider.dart';
import 'package:cts/features/commuters/repositories/commuter_repository_impl.dart';
import 'package:cts/features/commuters/repositories/commuter_repository.dart';
import 'package:cts/features/commuters/providers/commuter_controller.dart';
import 'package:cts/features/commuters/providers/commuter_form_provider.dart';
import 'package:cts/features/commuters/providers/commuter_home_provider.dart';
import 'package:cts/features/drivers/repositories/driver_repository_impl.dart';
import 'package:cts/features/drivers/repositories/driver_repository.dart';
import 'package:cts/features/drivers/providers/driver_controller.dart';
import 'package:cts/features/drivers/providers/driver_form_provider.dart';
import 'package:cts/features/drivers/providers/driver_home_provider.dart';
import 'package:cts/api/connectivity_service.dart';
import 'package:cts/core/network/network_action_guard.dart';
import 'package:cts/core/sync/sync_manager.dart';
import 'package:cts/data/local/cache/cache_service.dart';
import 'package:cts/data/repositories/authentication_repository_impl.dart';
import 'package:cts/data/repositories/session_repository_impl.dart';
import 'package:cts/domain/repositories/authentication_repository.dart';
import 'package:cts/domain/repositories/session_repository.dart';
import 'package:cts/domain/usecases/get_initial_route_usecase.dart';
import 'package:cts/features/auth/providers/sign_up_sign_in_controller.dart';
import 'package:cts/features/d2d/providers/d2d_channel_provider.dart';
import 'package:cts/features/d2d/repositories/d2d_repository.dart';
import 'package:cts/features/d2d/repositories/d2d_repository_impl.dart';
import 'package:cts/features/profile/providers/profile_provider.dart';
import 'package:cts/features/splash/providers/splash_provider.dart';
import 'package:cts/offline_temp/providers/offline_temp_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Composition root for Provider DI.
///
/// Decision (Task 2): keep **Provider** app-wide. Riverpod was considered for
/// compile-time safety and finer scoping, but migrating mid-flight with many
/// ChangeNotifiers would be high-cost / low-reward. Prefer:
/// - Feature-scoped providers at feature boundaries as features migrate
/// - Constructor injection of repositories (already in place)
/// - Revisit Riverpod only for greenfield features if scoped DI becomes painful
class AppProviders {
  const AppProviders._();

  static List<SingleChildWidget> build({
    required BaseApiServices apiService,
    required ConnectivityService connectivityService,
    required SyncManager syncManager,
    required OfflineFirstBatchRepository offlineFirstBatchRepository,
    required SessionAuthNotifier sessionAuthNotifier,
    required SessionInvalidatedCallback onSessionInvalidated,
  }) {
    return [
      Provider<BaseApiServices>.value(value: apiService),
      Provider<ConnectivityService>.value(value: connectivityService),
      Provider<NetworkActionGuard>(
        create: (context) =>
            NetworkActionGuard(context.read<ConnectivityService>()),
      ),
      ChangeNotifierProvider<SyncManager>.value(value: syncManager),
      Provider<CacheService>(create: (_) => CacheService()),
      ChangeNotifierProvider<SessionAuthNotifier>.value(
        value: sessionAuthNotifier,
      ),
      Provider<SessionRepository>(create: (_) => SessionRepositoryImpl()),
      Provider<AuthenticationRepository>(
        create: (context) => AuthenticationRepositoryImpl(
          apiService: context.read<BaseApiServices>(),
        ),
      ),
      Provider<BatchRepository>.value(value: offlineFirstBatchRepository),
      Provider<CabRepository>(
        create: (context) =>
            CabRepositoryImpl(apiService: context.read<BaseApiServices>()),
      ),
      Provider<DriverRepository>(
        create: (context) =>
            DriverRepositoryImpl(apiService: context.read<BaseApiServices>()),
      ),
      Provider<CommuterRepository>(
        create: (context) => CommuterRepositoryImpl(
          apiService: context.read<BaseApiServices>(),
        ),
      ),
      Provider<RouteRepository>(
        create: (context) =>
            RouteRepositoryImpl(apiService: context.read<BaseApiServices>()),
      ),
      Provider<PopRepository>(
        create: (context) =>
            PopRepositoryImpl(apiService: context.read<BaseApiServices>()),
      ),
      Provider<RunningBatchRepository>(
        create: (context) => RunningBatchRepositoryImpl(
          apiServices: context.read<BaseApiServices>(),
        ),
      ),
      Provider<ReturnBatchRepository>(
        create: (context) => ReturnBatchRepositoryImpl(
          apiService: context.read<BaseApiServices>(),
        ),
      ),
      Provider<D2dRepository>(
        create: (context) => D2dRepositoryImpl(
          apiService: context.read<BaseApiServices>(),
        ),
      ),
      Provider<GetInitialRouteUseCase>(
        create: (context) =>
            GetInitialRouteUseCase(context.read<SessionRepository>()),
      ),
      ChangeNotifierProvider(
        create: (context) =>
            SplashProvider(context.read<GetInitialRouteUseCase>()),
      ),
      ChangeNotifierProvider(
        create: (context) =>
            SignInProvider(context.read<AuthenticationRepository>()),
      ),
      ChangeNotifierProvider(
        create: (context) =>
            SignUpProvider(context.read<AuthenticationRepository>()),
      ),
      ChangeNotifierProvider(
        create: (context) => BatchProvider(context.read<BatchRepository>()),
      ),
      ChangeNotifierProvider(create: (_) => BatchFormProvider()),
      ChangeNotifierProvider(
        create: (context) => CabProvider(context.read<CabRepository>()),
      ),
      ChangeNotifierProvider(create: (_) => CabFormProvider()),
      ChangeNotifierProvider(
        create: (context) => DriverProvider(context.read<DriverRepository>()),
      ),
      ChangeNotifierProvider(create: (_) => DriverFormProvider()),
      ChangeNotifierProvider(
        create: (context) =>
            CommuterController(context.read<CommuterRepository>()),
      ),
      ChangeNotifierProvider(create: (_) => CommuterFormProvider()),
      ChangeNotifierProvider(
        create: (context) => RouteController(context.read<RouteRepository>()),
      ),
      ChangeNotifierProvider(create: (_) => RouteFormProvider()),
      ChangeNotifierProvider(
        create: (context) => PopProvider(context.read<PopRepository>()),
      ),
      ChangeNotifierProvider(create: (_) => PopFormProvider()),
      ChangeNotifierProvider(
        create: (context) =>
            RunningBatchProvider(context.read<RunningBatchRepository>()),
      ),
      ChangeNotifierProvider(
        create: (context) => ReturnBatchProvider(
          context.read<ReturnBatchRepository>(),
          networkGuard: context.read<NetworkActionGuard>(),
        ),
      ),
      ChangeNotifierProvider(
        create: (context) =>
            D2dChannelProvider(
              context.read<DriverRepository>(),
              context.read<D2dRepository>(),
              networkGuard: context.read<NetworkActionGuard>(),
              onSessionInvalidated: onSessionInvalidated,
            ),
      ),
      ChangeNotifierProvider(
        create: (context) => AdminProvider(
          context.read<BatchRepository>(),
          context.read<CommuterRepository>(),
          context.read<DriverRepository>(),
          context.read<CabRepository>(),
          context.read<RouteRepository>(),
          context.read<PopRepository>(),
          context.read<RunningBatchRepository>(),
        ),
      ),
      ChangeNotifierProvider(
        create: (context) =>
            DriverHomeProvider(context.read<DriverRepository>()),
      ),
      ChangeNotifierProvider(
        create: (context) => CommuterHomeProvider(
          context.read<CommuterRepository>(),
          context.read<ReturnBatchRepository>(),
        ),
      ),
      ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ChangeNotifierProvider(create: (_) => OfflineTempProvider()),
    ];
  }

  static Future<AppBootstrap> bootstrapServices() async {
    final sessionAuthNotifier = SessionAuthNotifier(SessionRepositoryImpl());

    late final SessionInvalidatedCallback onSessionInvalidated;
    onSessionInvalidated = createSessionInvalidatedHandler(
      authNotifier: sessionAuthNotifier,
    );

    final apiService = NetworkApiServices(
      onUnauthorized: onSessionInvalidated,
    );

    final authRepository = AuthenticationRepositoryImpl(apiService: apiService);
    sessionAuthNotifier.bindAuthRepository(authRepository);
    await sessionAuthNotifier.refresh(validateWithServer: true);

    final connectivityService = ConnectivityService();
    final syncManager = SyncManager(connectivityService: connectivityService);
    final offlineFirstBatchRepository = OfflineFirstBatchRepository(
      remote: BatchRepositoryImpl(apiService: apiService),
      connectivityService: connectivityService,
    );
    offlineFirstBatchRepository.registerSyncHandlers(syncManager);
    await syncManager.start();

    return AppBootstrap(
      apiService: apiService,
      connectivityService: connectivityService,
      syncManager: syncManager,
      offlineFirstBatchRepository: offlineFirstBatchRepository,
      sessionAuthNotifier: sessionAuthNotifier,
      onSessionInvalidated: onSessionInvalidated,
    );
  }
}

class AppBootstrap {
  const AppBootstrap({
    required this.apiService,
    required this.connectivityService,
    required this.syncManager,
    required this.offlineFirstBatchRepository,
    required this.sessionAuthNotifier,
    required this.onSessionInvalidated,
  });

  final NetworkApiServices apiService;
  final ConnectivityService connectivityService;
  final SyncManager syncManager;
  final OfflineFirstBatchRepository offlineFirstBatchRepository;
  final SessionAuthNotifier sessionAuthNotifier;
  final SessionInvalidatedCallback onSessionInvalidated;
}
