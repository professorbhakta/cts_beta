/// Tata Motors Fleet Edge live tracking URLs for commuter cab tracking.
class FleetTrackingUrls {
  const FleetTrackingUrls._();

  static const String baseUrl =
      'https://fleetedgelivetracking.home.tatamotors/';

  /// Default vehicle reference ID for live tracking.
  static const String defaultVehicleId = 'ref17849780231903099150';

  static String trackingUrl({String? vehicleId}) {
    final id = vehicleId ?? defaultVehicleId;
    return Uri.parse(baseUrl).replace(queryParameters: {'id': id}).toString();
  }
}
