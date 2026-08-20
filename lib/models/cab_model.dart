import 'package:cts/features/drivers/models/driver_model.dart';

class CabModel {
  int? id;
  String? regNumber;
  int? capacity;
  RouteId? routeId;
  int? km;
  /// Tata Fleet Edge vehicle reference id for live tracking (optional).
  String? trackingVehicleId;
  List<DriverModel>? driver;

  CabModel({
    this.id,
    this.regNumber,
    this.capacity,
    this.routeId,
    this.km,
    this.trackingVehicleId,
    this.driver,
  });

  CabModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    regNumber = json['regNumber'];
    capacity = json['capacity'];
    routeId =
        json['routeId'] != null ? RouteId.fromJson(json['routeId']) : null;
    km = json['km'];
    trackingVehicleId = _readTrackingVehicleId(json);
    driver = json['driver'] != null
        ? (json['driver'] as List)
            .map((e) => DriverModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : [];
  }

  static String? _readTrackingVehicleId(Map<String, dynamic> json) {
    for (final key in [
      'trackingVehicleId',
      'tracking_vehicle_id',
      'fleetVehicleId',
      'vehicleRefId',
    ]) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['regNumber'] = regNumber;
    data['capacity'] = capacity;
    if (routeId != null) {
      data['routeId'] = routeId!.toJson();
    }
    data['km'] = km;
    if (trackingVehicleId != null) {
      data['trackingVehicleId'] = trackingVehicleId;
    }
    data['driver'] = driver;
    return data;
  }
}

class RouteId {
  int? id;
  String? routeName;

  RouteId({this.id, this.routeName});

  RouteId.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    routeName = json['routeName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['routeName'] = routeName;
    return data;
  }
}

