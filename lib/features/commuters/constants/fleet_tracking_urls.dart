/// Tata Motors Fleet Edge live tracking URLs for commuter cab tracking.
class FleetTrackingUrls {
  const FleetTrackingUrls._();

  static const String baseUrl =
      'https://fleetedgelivetracking.home.tatamotors/';

  /// Default vehicle reference ID for live tracking.
  static const String defaultVehicleId = 'ref17849780231903099150';

  static String trackingUrl({String? vehicleId}) {
    final id = resolveVehicleId(cabTrackingVehicleId: vehicleId);
    return Uri.parse(baseUrl).replace(queryParameters: {'id': id}).toString();
  }

  /// Uses cab-specific Fleet Edge id when set; otherwise lab [defaultVehicleId].
  static String resolveVehicleId({String? cabTrackingVehicleId}) {
    final trimmed = cabTrackingVehicleId?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
    return defaultVehicleId;
  }

  static bool usesDefaultFallback({String? cabTrackingVehicleId}) {
    final trimmed = cabTrackingVehicleId?.trim();
    return trimmed == null || trimmed.isEmpty;
  }
}
