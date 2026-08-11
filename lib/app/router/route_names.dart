import 'package:flutter/foundation.dart';

/// Canonical route path constants for go_router + legacy call sites.
class RouteName {
  static const String splashScreen = '/splashScreen';
  static const String signIn = '/signIn';
  static const String signUp = '/signUp';

  static const String profileScreen = '/profileScreen';
  static const String noInternet = '/noInternet';

  // D2D (path params enable deep links)
  static const String d2dChannel = '/d2dChannel';
  static const String d2dLog = '/d2dLog';

  // Role homes
  static const String adminHomeScreen = '/adminHomeScreen';
  static const String driverHomeScreen = '/driverHomeScreen';
  static const String commuterHomeScreen = '/commuterHomeScreen';
  static const String trackCabScreen = '/trackCabScreen';

  // Admin CRUD
  static const String routeForm = '/routeForm';
  static const String routeScreen = '/routeScreen';

  static const String batchForm = '/batchForm';
  static const String batchScreen = '/batchScreen';
  static const String runningBatchScreen = '/runningBatchScreen';
  static const String returnBatchScreen = '/returnBatchScreen';
  static const String returnCommuterScreen = '/returnCommuterScreen';
  static const String driverReturnCommuter = '/driverReturnCommuter';

  static const String popForm = '/popForm';
  static const String popScreen = '/popScreen';

  static const String cabForm = '/cabForm';
  static const String cabScreen = '/cabScreen';

  static const String driverForm = '/driverForm';
  static const String driverScreen = '/driverScreen';

  static const String commuterForm = '/commuterForm';
  static const String commuterListScreen = '/commuterListScreen';
  static const String commuterScreen = '/commuterScreen';

  // Offline temp module
  static const String offlineTempHome = '/offlineTempHome';
  static const String offlineBatchCommuters = '/offlineBatchCommuters';
  static const String offlineRoutePops = '/offlineRoutePops';

  /// Debug UI gallery (see docs/WIREFRAME_GALLERY.md).
  static const String designWireframeGallery = '/designWireframes';

  /// Public routes (no login required).
  static const Set<String> public = {
    splashScreen,
    signIn,
    signUp,
    noInternet,
  };

  /// Routes reachable without login in debug builds only.
  static bool isPublicLocation(String location) {
    if (public.any(
      (path) => location == path || location.startsWith('$path/'),
    )) {
      return true;
    }
    if (kDebugMode &&
        (location == designWireframeGallery ||
            location.startsWith('$designWireframeGallery/'))) {
      return true;
    }
    return false;
  }

  /// Admin-only routes (CRUD + admin D2D channel).
  static const Set<String> adminOnlyPrefixes = {
    adminHomeScreen,
    routeScreen,
    routeForm,
    batchScreen,
    batchForm,
    runningBatchScreen,
    returnBatchScreen,
    returnCommuterScreen,
    popScreen,
    popForm,
    cabScreen,
    cabForm,
    driverScreen,
    driverForm,
    commuterScreen,
    commuterForm,
    d2dChannel,
  };

  /// Driver role home + driver D2D log + read-only return list.
  static const Set<String> driverOnlyPrefixes = {
    driverHomeScreen,
    d2dLog,
    driverReturnCommuter,
  };

  /// Commuter role home + cab tracking.
  static const Set<String> commuterOnlyPrefixes = {
    commuterHomeScreen,
    trackCabScreen,
  };

  static String homeForRole(String? userType) {
    switch (userType) {
      case 'ADMIN':
        return adminHomeScreen;
      case 'DRIVER':
        return driverHomeScreen;
      case 'COMMUTER':
        return commuterHomeScreen;
      default:
        return signIn;
    }
  }
}
