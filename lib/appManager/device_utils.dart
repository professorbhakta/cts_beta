import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Utility class for device-related operations
class DeviceUtils {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  static String? _cachedDeviceId;

  /// Gets a unique device identifier
  /// Returns a cached value if already retrieved
  static Future<String> getDeviceId() async {
    if (_cachedDeviceId != null && _cachedDeviceId!.isNotEmpty) {
      return _cachedDeviceId!;
    }

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        _cachedDeviceId = androidInfo.id; // Android ID
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        _cachedDeviceId = iosInfo.identifierForVendor;
      } else {
        // For other platforms, use a fallback
        _cachedDeviceId = 'unknown-device-${DateTime.now().millisecondsSinceEpoch}';
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting device ID: $e');
      }
      // Fallback to timestamp-based ID if device info fails
      _cachedDeviceId = 'fallback-device-${DateTime.now().millisecondsSinceEpoch}';
    }

    return _cachedDeviceId ?? 'unknown-device';
  }

  /// Clears the cached device ID (useful for testing)
  static void clearCache() {
    _cachedDeviceId = null;
  }
}







