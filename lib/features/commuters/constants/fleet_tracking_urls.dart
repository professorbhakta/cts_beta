/// Tata Motors Fleet Edge live tracking URLs for commuter cab tracking.
class FleetTrackingUrls {
  const FleetTrackingUrls._();

  static const String baseUrl =
      'https://fleetedgelivetracking.home.tatamotors/';

  /// Lab-only sample vehicle id — **not** used as a silent production fallback
  /// (wrong cab map). Kept for docs/tests; [trackingUrl] requires a real id.
  static const String defaultVehicleId = 'ref17849780231903099150';

  static const String allowedHost = 'fleetedgelivetracking.home.tatamotors';

  /// True when [uri] may load inside the Track Cab WebView (exact Fleet Edge host).
  static bool isAllowedNavigation(Uri uri) {
    if (uri.scheme != 'https' && uri.scheme != 'http') return false;
    return uri.host.toLowerCase() == allowedHost;
  }

  /// Cab-specific Fleet Edge id when set; otherwise `null` (no wrong-vehicle map).
  static String? resolveVehicleId({String? cabTrackingVehicleId}) {
    final trimmed = cabTrackingVehicleId?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
    return null;
  }

  /// Tracking URL when a vehicle id is present; otherwise `null`.
  static String? trackingUrl({String? vehicleId}) {
    final id = resolveVehicleId(cabTrackingVehicleId: vehicleId);
    if (id == null) return null;
    return Uri.parse(baseUrl).replace(queryParameters: {'id': id}).toString();
  }

  static bool usesDefaultFallback({String? cabTrackingVehicleId}) {
    return resolveVehicleId(cabTrackingVehicleId: cabTrackingVehicleId) == null;
  }
}
