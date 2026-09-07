import 'package:cts/app/router/auth_redirect.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:cts/app/router/session_auth_notifier.dart';
import 'package:cts/appManager/d2d_route_args.dart';
import 'package:cts/features/auth/screens/sign_in.dart';
import 'package:cts/features/d2d/screens/boarding_scan_screen.dart';
import 'package:cts/features/d2d/screens/d2d_channel.dart';
import 'package:cts/features/d2d/screens/d2d_log_screen.dart';
import 'package:cts/features/profile/screens/profile_screen.dart';
import 'package:cts/features/splash/screens/splash_screen.dart';
import 'package:cts/offline_temp/screens/offline_batch_commuters_screen.dart';
import 'package:cts/offline_temp/screens/offline_home_screen.dart';
import 'package:cts/offline_temp/screens/offline_route_pops_screen.dart';
import 'package:cts/features/admin_home/screens/admin_home_screen.dart';
import 'package:cts/features/cabs/forms/cab_form.dart';
import 'package:cts/features/cabs/screens/cab_screen.dart';
import 'package:cts/features/pops/forms/pop_form.dart';
import 'package:cts/features/pops/screens/pop_screen.dart';
import 'package:cts/features/routes/forms/route_form.dart';
import 'package:cts/features/routes/screens/route_screen.dart';
import 'package:cts/features/commuters/forms/commuter_form.dart';
import 'package:cts/features/commuters/screens/commuter_home_page.dart';
import 'package:cts/features/commuters/screens/track_cab_screen.dart';
import 'package:cts/features/commuters/screens/commuter_screen.dart';
import 'package:cts/features/drivers/forms/driver_form.dart';
import 'package:cts/features/drivers/screens/driver_home_page.dart';
import 'package:cts/features/drivers/screens/driver_screen.dart';
import 'package:cts/features/batches/forms/batch_form.dart';
import 'package:cts/features/batches/screens/batch_screen.dart';
import 'package:cts/features/commuters/screens/return_batch_commuter_screen.dart';
import 'package:cts/features/batches/screens/returning_batch_screen.dart';
import 'package:cts/features/batches/screens/running_batch_screen.dart';
import 'package:cts/screens/error_page.dart';
import 'package:cts/screens/no_internet_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Builds the application [GoRouter] with role-based redirects and deep-link paths.
GoRouter createAppRouter({
  required SessionAuthNotifier authNotifier,
  GlobalKey<NavigatorState>? navigatorKey,
}) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: RouteName.splashScreen,
    refreshListenable: authNotifier,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      return resolveAuthRedirect(
        location: state.matchedLocation,
        authReady: authNotifier.ready,
        loggedIn: authNotifier.loggedIn,
        userType: authNotifier.userType,
      );
    },
    routes: [
      GoRoute(
        path: RouteName.splashScreen,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteName.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: RouteName.signUp,
        redirect: (context, state) => RouteName.signIn,
      ),
      GoRoute(
        path: RouteName.profileScreen,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: RouteName.noInternet,
        builder: (context, state) => const NoInternetError(),
      ),
      GoRoute(
        path: RouteName.adminHomeScreen,
        builder: (context, state) => const AdminMainScreen(),
      ),
      GoRoute(
        path: RouteName.driverHomeScreen,
        builder: (context, state) => const DriverHomePage(),
      ),
      GoRoute(
        path: RouteName.commuterHomeScreen,
        builder: (context, state) => const CommuterHomePage(),
      ),
      GoRoute(
        path: RouteName.trackCabScreen,
        builder: (context, state) {
          final vehicleId = state.uri.queryParameters['vehicleId'];
          final cabReg = state.uri.queryParameters['cabReg'];
          return TrackCabScreen(
            vehicleId: vehicleId != null && vehicleId.trim().isNotEmpty
                ? vehicleId.trim()
                : null,
            cabRegNumber:
                cabReg != null && cabReg.trim().isNotEmpty ? cabReg.trim() : null,
          );
        },
      ),
      GoRoute(
        path: RouteName.boardingScan,
        builder: (context, state) => const BoardingScanScreen(),
      ),
      GoRoute(
        path: RouteName.routeScreen,
        builder: (context, state) => const RouteScreen(),
      ),
      GoRoute(
        path: RouteName.routeForm,
        builder: (context, state) => const RouteForm(),
      ),
      GoRoute(
        path: RouteName.popScreen,
        builder: (context, state) => const PopScreen(),
      ),
      GoRoute(
        path: RouteName.popForm,
        builder: (context, state) => const PopForm(),
      ),
      GoRoute(
        path: RouteName.batchScreen,
        builder: (context, state) => const BatchScreen(),
      ),
      GoRoute(
        path: RouteName.batchForm,
        builder: (context, state) => const BatchForm(),
      ),
      GoRoute(
        path: RouteName.runningBatchScreen,
        builder: (context, state) => const RunningBatchScreen(),
      ),
      GoRoute(
        path: RouteName.returnBatchScreen,
        builder: (context, state) => const ReturningBatchScreen(),
      ),
      GoRoute(
        path: '${RouteName.returnCommuterScreen}/:batchId',
        builder: (context, state) {
          final batchId = state.pathParameters['batchId'];
          if (batchId == null || batchId.isEmpty) {
            return const ReturningBatchScreen();
          }
          return ReturnCommuterListScreen(
            batchId: batchId,
            canConfirmAvailable: true,
            canRemoveConfirmed: false,
            canEndTrip: false,
          );
        },
      ),
      GoRoute(
        path: '${RouteName.driverReturnCommuter}/:batchId',
        builder: (context, state) {
          final batchId = state.pathParameters['batchId'];
          if (batchId == null || batchId.isEmpty) {
            return const DriverHomePage();
          }
          return ReturnCommuterListScreen(
            batchId: batchId,
            canConfirmAvailable: true,
            canRemoveConfirmed: true,
            canEndTrip: true,
          );
        },
      ),
      GoRoute(
        path: RouteName.cabScreen,
        builder: (context, state) => const CabScreen(),
      ),
      GoRoute(
        path: RouteName.cabForm,
        builder: (context, state) => const CabForm(),
      ),
      GoRoute(
        path: RouteName.driverScreen,
        builder: (context, state) => const DriverScreen(),
      ),
      GoRoute(
        path: RouteName.driverForm,
        builder: (context, state) => const DriverForm(),
      ),
      GoRoute(
        path: RouteName.commuterScreen,
        builder: (context, state) => const CommuterScreen(),
      ),
      GoRoute(
        path: RouteName.commuterForm,
        builder: (context, state) => const CommuterForm(),
      ),
      GoRoute(
        path: '${RouteName.d2dChannel}/:batchId',
        builder: (context, state) {
          final batchId = state.pathParameters['batchId'] ??
              D2dRouteArgs.batchIdFrom(state.extra);
          if (batchId == null || batchId.isEmpty) {
            return const RunningBatchScreen();
          }
          return D2dChannel(batchId: batchId);
        },
      ),
      GoRoute(
        path: RouteName.d2dChannel,
        builder: (context, state) {
          final batchId = D2dRouteArgs.batchIdFrom(state.extra);
          if (batchId == null) return const RunningBatchScreen();
          return D2dChannel(batchId: batchId);
        },
      ),
      GoRoute(
        path: '${RouteName.d2dLog}/:batchId',
        builder: (context, state) {
          final batchId = state.pathParameters['batchId'] ??
              D2dRouteArgs.batchIdFrom(state.extra);
          if (batchId == null || batchId.isEmpty) {
            return const DriverHomePage();
          }
          return D2DLogScreen(batchId: batchId);
        },
      ),
      GoRoute(
        path: RouteName.d2dLog,
        builder: (context, state) {
          final batchId = D2dRouteArgs.batchIdFrom(state.extra);
          if (batchId == null) return const DriverHomePage();
          return D2DLogScreen(batchId: batchId);
        },
      ),
      GoRoute(
        path: RouteName.offlineTempHome,
        builder: (context, state) => const OfflineHomeScreen(),
      ),
      GoRoute(
        path: '${RouteName.offlineBatchCommuters}/:batchId',
        builder: (context, state) {
          final raw = state.pathParameters['batchId'];
          final batchId = int.tryParse(raw ?? '');
          if (batchId == null) return const OfflineHomeScreen();
          return OfflineBatchCommutersScreen(batchId: batchId);
        },
      ),
      GoRoute(
        path: RouteName.offlineBatchCommuters,
        builder: (context, state) {
          final batchId = state.extra as int?;
          if (batchId == null) return const OfflineHomeScreen();
          return OfflineBatchCommutersScreen(batchId: batchId);
        },
      ),
      GoRoute(
        path: '${RouteName.offlineRoutePops}/:routeId',
        builder: (context, state) {
          final routeId = int.tryParse(state.pathParameters['routeId'] ?? '');
          if (routeId == null) return const OfflineHomeScreen();
          return OfflineRoutePopsScreen(routeId: routeId);
        },
      ),
      GoRoute(
        path: RouteName.offlineRoutePops,
        builder: (context, state) {
          final routeId = state.extra as int?;
          if (routeId == null) return const OfflineHomeScreen();
          return OfflineRoutePopsScreen(routeId: routeId);
        },
      ),
    ],
    errorBuilder: (context, state) => const ErrorPage(),
  );
}
