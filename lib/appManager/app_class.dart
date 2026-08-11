import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:cts/screens/no_internet_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
      _ => null,
    };
  }

  static bool get isAdmin => userType == 'ADMIN';

  static bool get isDriver => userType == 'DRIVER';

  static bool get isCommuter => userType == 'COMMUTER';

  static String get homeRoute => RouteName.homeForRole(userType);

  static String get roleLabel => switch (userType) {
        'ADMIN' => 'Admin',
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

  Future getPermissions() async {
    if (kDebugMode) {
      debugPrint(
        "await Permission.phone.isGranted ${await Permission.phone.isGranted}",
      );
      debugPrint(
        "await Permission.notification.isGranted ${await Permission.notification.isGranted}",
      );
      debugPrint(
        "await Permission.location.isGranted ${await Permission.location.isGranted}",
      );
    }

    if (!await Permission.phone.isGranted) {
      await Permission.phone.request();
    }
    if (!await Permission.notification.isGranted) {
      await Permission.notification.request();
    }

    if (!await Permission.location.isGranted) {
      await Permission.location.request();
    }
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

    const defaultApiBaseUrl = 'http://172.20.10.2/';
    const defaultWebSocketUrl = 'ws://172.20.10.2/ws/';

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

    _instance = AppConfig._(
      apiBaseUrl: _normalizeBaseUrl(envApiBaseUrl()),
      webSocketUrl: _normalizeWebSocketUrl(envWebSocketUrl()),
      defaultAdminCode: envOrDefault('DEFAULT_ADMIN_CODE', ''),
    );
    AppManager.defaultAdminCodeFallback = _instance!.defaultAdminCode;

    if (kDebugMode) {
      final originalApiUrl = envApiBaseUrl();
      final originalWsUrl = envWebSocketUrl();

      if (originalApiUrl.startsWith('https://')) {
        debugPrint(
          'AppConfig: HTTPS detected in API_BASE_URL, converted to HTTP',
        );
      }
      if (originalWsUrl.startsWith('wss://')) {
        debugPrint('AppConfig: WSS detected in WEBSOCKET_URL, converted to WS');
      }

      debugPrint('AppConfig: Using API Base URL: ${_instance!.apiBaseUrl}');
      debugPrint('AppConfig: Using WebSocket URL: ${_instance!.webSocketUrl}');
    }
  }

  static String _normalizeBaseUrl(String value) {
    if (value.isEmpty) return value;

    final normalized = value.replaceFirst(RegExp(r'^https://'), 'http://');

    return normalized.endsWith('/') ? normalized : '$normalized/';
  }

  static String _normalizeWebSocketUrl(String value) {
    if (value.isEmpty) return value;

    final normalized = value.replaceFirst(RegExp(r'^wss://'), 'ws://');

    return normalized.endsWith('/') ? normalized : '$normalized/';
  }
}
