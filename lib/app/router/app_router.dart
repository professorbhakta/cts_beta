import 'package:cts/app/router/route_names.dart';
import 'package:cts/app/router/session_auth_notifier.dart';
import 'package:cts/appManager/d2d_route_args.dart';
import 'package:cts/features/auth/presentation/screens/sign_in.dart';
import 'package:cts/features/auth/presentation/screens/sign_up.dart';
import 'package:cts/features/d2d/presentation/screens/d2d_channel.dart';
import 'package:cts/features/d2d/presentation/screens/d2d_log_screen.dart';
import 'package:cts/features/profile/presentation/screens/profile_screen.dart';
import 'package:cts/features/splash/presentation/screens/splash_screen.dart';
import 'package:cts/offline_temp/screens/offline_batch_commuters_screen.dart';
import 'package:cts/offline_temp/screens/offline_home_screen.dart';
import 'package:cts/offline_temp/screens/offline_route_pops_screen.dart';
import 'package:cts/features/admin_home/presentation/screens/admin_home_screen.dart';
import 'package:cts/features/cabs/presentation/forms/cab_form.dart';
import 'package:cts/features/cabs/presentation/screens/cab_screen.dart';
import 'package:cts/features/pops/presentation/forms/pop_form.dart';
import 'package:cts/features/pops/presentation/screens/pop_screen.dart';
import 'package:cts/features/routes/presentation/forms/route_form.dart';
import 'package:cts/features/routes/presentation/screens/route_screen.dart';
import 'package:cts/features/commuters/presentation/forms/commuter_form.dart';
import 'package:cts/features/commuters/presentation/screens/commuter_home_page.dart';
import 'package:cts/features/commuters/presentation/screens/commuter_screen.dart';
import 'package:cts/features/drivers/presentation/forms/driver_form.dart';
import 'package:cts/features/drivers/presentation/screens/driver_home_page.dart';
import 'package:cts/features/drivers/presentation/screens/driver_screen.dart';
import 'package:cts/features/batches/presentation/forms/batch_form.dart';
import 'package:cts/features/batches/presentation/screens/batch_screen.dart';
import 'package:cts/features/batches/presentation/screens/returning_batch_screen.dart';
import 'package:cts/features/batches/presentation/screens/running_batch_screen.dart';
import 'package:cts/screens/no_internet_screen.dart';
import 'package:cts/design/wireframes/wireframe_gallery_screen.dart';
import 'package:flutter/foundation.dart';
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
      final location = state.matchedLocation;
      final isPublic = RouteName.isPublicLocation(location);

      // Splash always allowed while session is resolving.
      if (location == RouteName.splashScreen) return null;

      if (!authNotifier.ready) return null;

      final loggedIn = authNotifier.loggedIn;
      final userType = authNotifier.userType;

      if (!loggedIn) {
        if (isPublic) return null;
        return RouteName.signIn;
      }

      // Logged-in users leave auth screens.
      if (location == RouteName.signIn || location == RouteName.signUp) {
        return RouteName.homeForRole(userType);
      }

      if (_matchesAny(location, RouteName.adminOnlyPrefixes) &&
          userType != 'ADMIN') {
        return RouteName.homeForRole(userType);
      }

      if (_matchesAny(location, RouteName.driverOnlyPrefixes) &&
          userType != 'DRIVER' &&
          userType != 'ADMIN') {
        return RouteName.homeForRole(userType);
      }

      if (_matchesAny(location, RouteName.commuterOnlyPrefixes) &&
          userType != 'COMMUTER' &&
          userType != 'ADMIN') {
        return RouteName.homeForRole(userType);
      }

      return null;
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
        builder: (context, state) => const SignUpScreen(),
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
      if (kDebugMode) ...[
        GoRoute(
          path: RouteName.designWireframeGallery,
          builder: (context, state) => const WireframeGalleryScreen(),
          routes: [
            GoRoute(
              path: ':wireframeId',
              builder: (context, state) {
                final id = state.pathParameters['wireframeId'] ?? '';
                return WireframeDetailScreen(wireframeId: id);
              },
            ),
          ],
        ),
      ],
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.uri}'),
      ),
    ),
  );
}

bool _matchesAny(String location, Set<String> prefixes) {
  for (final prefix in prefixes) {
    if (location == prefix || location.startsWith('$prefix/')) {
      return true;
    }
  }
  return false;
}
