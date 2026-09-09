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
  static const String boardingScan = '/boardingScan';

  // Admin CRUD
  static const String routeForm = '/routeForm';
  static const String routeScreen = '/routeScreen';

  static const String batchForm = '/batchForm';
  static const String batchScreen = '/batchScreen';
  static const String runningBatchScreen = '/runningBatchScreen';
  static const String returnBatchScreen = '/returnBatchScreen';
  static const String returnCommuterScreen = '/returnCommuterScreen';
  static const String driverReturnCommuter = '/driverReturnCommuter';

  /// Driver/admin-like show screen for return boarding QR (visual prep).
  /// Binds later to return trip log + RCList — not morning DTODLOG return_*.
  /// See `docs/setup/RETURN_QR_UI_PREP.md`.
  static const String returnBoardingQr = '/returnBoardingQr';

  /// Return boarding scan entry (visual prep). Not morning `/boardingScan`.
  /// TODO(Dock): RCList scan contract — user-ID list on return trip log row
  /// (like CList); no invented camelCase fields.
  static const String returnBoardingScan = '/returnBoardingScan';

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

  /// Public routes (no login required).
  static const Set<String> public = {
    splashScreen,
    signIn,
    signUp,
    noInternet,
  };

  /// Routes reachable without login.
  static bool isPublicLocation(String location) {
    return public.any(
      (path) => location == path || location.startsWith('$path/'),
    );
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

  /// Driver role home + driver D2D log + return list + return boarding QR show.
  static const Set<String> driverOnlyPrefixes = {
    driverHomeScreen,
    d2dLog,
    driverReturnCommuter,
    returnBoardingQr,
  };

  /// Commuter role home + cab tracking + boarding scan (+ return scan alias).
  static const Set<String> commuterOnlyPrefixes = {
    commuterHomeScreen,
    trackCabScreen,
    boardingScan,
    returnBoardingScan,
  };

  static String homeForRole(String? userType) {
    switch (userType) {
      case 'ADMIN':
      case 'SUPER_ADMIN':
      case 'SUPERVISOR':
        // SUPER_ADMIN / ADMIN / SUPERVISOR share admin shell (capabilities differ).
        return adminHomeScreen;
      case 'STAFF':
      case 'COMMUTER':
        // STAFF shares commuter home/UX (not admin CRUD).
        return commuterHomeScreen;
      case 'DRIVER':
        return driverHomeScreen;
      default:
        return signIn;
    }
  }

  /// Roles that land on / may open the admin shell.
  /// ADMIN + SUPER_ADMIN = full services; SUPERVISOR = allow-listed only.
  /// STAFF is not admin-like (commuter home).
  static bool isAdminLike(String? userType) =>
      userType == 'ADMIN' ||
      userType == 'SUPER_ADMIN' ||
      userType == 'SUPERVISOR';

  /// Roles that use commuter home + commuter-only prefixes.
  static bool isCommuterLike(String? userType) =>
      userType == 'COMMUTER' || userType == 'STAFF';
}
