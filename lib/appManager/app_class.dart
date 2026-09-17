import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:cts/screens/no_internet_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cts/appManager/session_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppClass {
  static int userId = 0;
  static int userType = 0;
  static int batchId = 0;
  static String batchName = "";
  static String deviceId = "";
  static String webSocBatchToken = "";
  static bool confirmYesOrNo = false;

  static String driverBatchId = "";
  static String d2dBatchId = "";
}

/// Role checks for session-scoped UI (e.g. admin-only navigation drawer).
class SessionRole {
  SessionRole._();

  static String? get userType {
    final stored = AppManager.instance.getString(ManagerKey.userType);
    if (stored.isNotEmpty && stored != '0') return stored;
    return switch (AppClass.userType) {
      1 => 'COMMUTER',
      2 => 'DRIVER',
      3 => 'ADMIN',
      4 => 'SUPERVISOR',
      5 => 'STAFF',
      _ => null,
    };
  }

  static bool get isAdmin => userType == 'ADMIN';

  static bool get isSupervisor => userType == 'SUPERVISOR';

  static bool get isStaff => userType == 'STAFF';

  /// ADMIN (full) + SUPERVISOR (allow-listed) may use the admin shell.
  /// STAFF is not admin-like — see [RouteName.isAdminLike].
  static bool get isAdminLike => RouteName.isAdminLike(userType);

  static bool get isDriver => userType == 'DRIVER';

  static bool get isCommuter => userType == 'COMMUTER';

  /// COMMUTER + STAFF share commuter home / prefixes.
  static bool get isCommuterLike => RouteName.isCommuterLike(userType);

  static String get homeRoute => RouteName.homeForRole(userType);

  static String get roleLabel => switch (userType) {
        'ADMIN' => 'Admin',
        'SUPERVISOR' => 'Supervisor',
        'STAFF' => 'Staff',
        'DRIVER' => 'Driver',
        'COMMUTER' => 'Commuter',
        _ => 'User',
      };
}

class ManagerKey {
  static const sessionLogin = "login_data";
  static const csrfToken = "csrfToken";
  static const fcmToken = "fcmToken";
  static const sessionId = "session_id";
  static const isLogin = "isLogin";

  static const deviceId = "deviceId";
  static const hasPaid = "hasPaid";

  static const userName = "username";
  static const userId = "id";
  static const mobile = "Mobile";
  static const email = "Email";
  static const name = "Name";
  static const fName = "Name";
  static const lName = "Name";
  static const college = "college";
  static const gender = "Gender";
  static const address = "Address";
  static const image = "Image";
  static const cabId = "cab_id";
  static const cabNumb = "cabNumb";
  static const batchId = "batch_id";
  static const batchName = "batchName";
  static const batchTime = "batchTime";
  static const popId = "pop_id";
  static const userType = "user_type";
  static const adminCode = "admin_code";
  /// Org admin mobile from login profile `adminCode.userId.mobileNumber` when present.
  static const adminMobile = "admin_mobile";
  static const isComing = "isComing";
  static const webSocketConn = "webSocketConn";

  static const isGuestUser = "isGuestUser";
  static const credit = "credit";
  static const deleteAccount = "deleteAccount";
  static const razorPayKey = "razorPayKey";
  static const razorPayKeySecret = "razorPayKeySecret";
  static const languageCode = "languageCode";
  static const languageCountryCode = "languageCountryCode";
}

class AppManager {
  // 1. Private constructor
  AppManager._internal();

  // 2. Static instance
  static final AppManager _instance = AppManager._internal();

  // 3. Static getter for the instance
  static AppManager get instance => _instance;

  // 4. SharedPreferences instance is now static and nullable
  static SharedPreferences? _preferences;
  static String defaultAdminCodeFallback = '';

  // 5. Static initialize method
  static Future<void> initialize() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // 6. All methods now use the static _preferences instance
  Future setString(String key, String value) async {
    await _preferences?.setString(key, value);
  }

  String getString(String key, {String defValue = '0'}) {
    final storedValue = _preferences?.getString(key);

    if ((storedValue == null || storedValue.isEmpty) &&
        key == ManagerKey.adminCode) {
      if (defaultAdminCodeFallback.isNotEmpty) {
        return defaultAdminCodeFallback;
      }
    }

    return storedValue ?? defValue;
  }

  Future setBool(String key, bool value) async {
    await _preferences?.setBool(key, value);
  }

  bool getBool(String key, {bool defValue = false}) {
    return _preferences?.getBool(key) ?? defValue;
  }

  Future clearSharedPreferences() async {
    await _preferences?.clear();
  }

  /// Drops secure cookies, prefs, and in-memory role. Safe to call when
  /// logout POST fails or a REST call returns 401.
  Future<void> clearLocalSession() async {
    await SessionManager().clear();
    await clearSharedPreferences();
    AppClass.userType = 0;
  }

  /// Runtime permissions at splash (mobile only).
  ///
  /// Splash requests **notifications** on non-web (firebase_messaging / OS
  /// alerts). **Camera is never requested here** — point-of-use already
  /// requests in `boarding_scan_screen` + `odometer_camera_helper`.
  ///
  /// **Web (`kIsWeb`):** no-op. `permission_handler` prompts are useless /
  /// noisy on Flutter web; avoid splash-time camera (and notification) prompts.
  ///
  /// **Removed (FIND-012 / FE-7.4 / FE-7.5):** `Permission.phone` and
  /// `Permission.location` — no Geolocator / READ_PHONE_STATE; Android
  /// phone+location perms and iOS NSLocation* strings dropped.
  Future getPermissions() async {
    // Flutter web: skip permission_handler entirely at splash.
    if (kIsWeb) {
      return;
    }

    if (kDebugMode) {
      debugPrint(
        'Permission.notification.isGranted ${await Permission.notification.isGranted}',
      );
    }

    // firebase_messaging (held) + OS alerts — mobile splash only.
    if (!await Permission.notification.isGranted) {
      await Permission.notification.request();
    }
    // Camera intentionally omitted at splash (QR / odometer request at use).
  }

  Future<void> checkInternet(BuildContext context) async {
    final connectivityResults = await Connectivity().checkConnectivity();
    if (connectivityResults.every(
      (result) => result == ConnectivityResult.none,
    )) {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NoInternetError()),
        );
      }
    }
  }
}

class GetDataFromApi {
  static List popList = [];
  static List batchList = [];
  static List routeList = [];
  static List cabList = [];
  static List commuterList = [];
  static List driverList = [];
}

class ProcessedData {
  static List<String> popList = ['Select Pick-Up-Point', 'No Data Found'];
  static List<String> routeList = ['Select Route', 'No Data Found'];
  static List<String> batchList = ['Select Batch', 'No Data Found'];
  static List<String> cabList = ['Select Cab', 'No Data Found'];
  static List<String> commuterList = [];
  static List<String> driverList = [];
}

class AppConfig {
  AppConfig._({
    required this.apiBaseUrl,
    required this.webSocketUrl,
    required this.defaultAdminCode,
  });

  static AppConfig? _instance;

  final String apiBaseUrl;
  final String webSocketUrl;
  final String defaultAdminCode;

  static AppConfig get instance {
    final config = _instance;
    if (config == null) {
      throw StateError(
        'AppConfig.initialize() must be called before accessing configuration values.',
      );
    }
    return config;
  }

  static Future<void> initialize({String fileName = '.env'}) async {
    if (_instance != null) return;

    await AppManager.initialize();

    // Lab LAN defaults are for local debug/profile only — never silent in release.
    const labApiBaseUrl = 'http://172.20.10.2/';
    const labWebSocketUrl = 'ws://172.20.10.2/ws/';
    final allowLabDefaults = !kReleaseMode;
    final defaultApiBaseUrl = allowLabDefaults ? labApiBaseUrl : '';
    final defaultWebSocketUrl = allowLabDefaults ? labWebSocketUrl : '';

    try {
      await dotenv.load(fileName: fileName, isOptional: true);
    } catch (e, s) {
      if (kDebugMode) {
        debugPrint(
          'AppConfig: Caught error while loading dotenv file ($fileName): $e',
        );
        debugPrint('AppConfig: Stacktrace: $s');
        debugPrint(
          'AppConfig: Using default values. Create a .env file in the project root to customize.',
        );
      }
    }

    String envOrDefault(String key, String fallback) {
      if (!dotenv.isInitialized) return fallback;
      return dotenv.maybeGet(key, fallback: fallback) ?? fallback;
    }

    String envApiBaseUrl() {
      final direct = envOrDefault('API_BASE_URL', '');
      if (direct.isNotEmpty) return direct;
      // Legacy alias from early .env templates
      return envOrDefault('BASE_URL', defaultApiBaseUrl);
    }

    String envWebSocketUrl() {
      return envOrDefault('WEBSOCKET_URL', defaultWebSocketUrl);
    }

    if (kDebugMode &&
        (!dotenv.isInitialized ||
            (envOrDefault('API_BASE_URL', '').isEmpty &&
                envOrDefault('BASE_URL', '').isEmpty) ||
            envOrDefault('WEBSOCKET_URL', '').isEmpty)) {
      debugPrint(
        'AppConfig: .env missing or incomplete — using defaults. '
        'Copy .env.example to .env and set API_BASE_URL / WEBSOCKET_URL.',
      );
    }

    final apiBaseUrl = _normalizeBaseUrl(envApiBaseUrl());
    final webSocketUrl = _normalizeWebSocketUrl(envWebSocketUrl());

    if (apiBaseUrl.isEmpty || webSocketUrl.isEmpty) {
      throw StateError(
        'AppConfig: API_BASE_URL and WEBSOCKET_URL must be set in .env. '
        'Release builds refuse silent lab LAN defaults (FIND-010).',
      );
    }

    if (kReleaseMode &&
        (apiBaseUrl.startsWith('http://172.') ||
            apiBaseUrl.contains('172.20.10.2') ||
            webSocketUrl.contains('172.20.10.2'))) {
      throw StateError(
        'AppConfig: release build must not use lab LAN host 172.20.10.2. '
        'Set production HTTPS/WSS endpoints in .env.',
      );
    }

    _instance = AppConfig._(
      apiBaseUrl: apiBaseUrl,
      webSocketUrl: webSocketUrl,
      defaultAdminCode: envOrDefault('DEFAULT_ADMIN_CODE', ''),
    );
    AppManager.defaultAdminCodeFallback = _instance!.defaultAdminCode;

    if (kDebugMode) {
      debugPrint('AppConfig: Using API Base URL: ${_instance!.apiBaseUrl}');
      debugPrint('AppConfig: Using WebSocket URL: ${_instance!.webSocketUrl}');
    }
  }

  static String _normalizeBaseUrl(String value) {
    if (value.isEmpty) return value;
    return value.endsWith('/') ? value : '$value/';
  }

  static String _normalizeWebSocketUrl(String value) {
    if (value.isEmpty) return value;
    return value.endsWith('/') ? value : '$value/';
  }
}
