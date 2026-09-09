/// CamelCase response from `GET /user/admin-bootstrap/` (Phase A).
///
/// Empty [organizations] and null fields are valid. Map to snake_case SQLite
/// columns in [AdminBootstrapDao].
class AdminBootstrapResponse {
  const AdminBootstrapResponse({
    required this.status,
    required this.generatedAt,
    this.adminCode,
    this.organizations = const [],
    this.enums = const BootstrapEnums(),
    this.routes = const [],
    this.pickUpPoints = const [],
    this.batches = const [],
    this.cabs = const [],
    this.drivers = const [],
    this.commuters = const [],
    this.today = const BootstrapToday(),
  });

  final String status;
  final String generatedAt;
  final String? adminCode;
  final List<BootstrapOrganization> organizations;
  final BootstrapEnums enums;
  final List<BootstrapRoute> routes;
  final List<BootstrapPickUpPoint> pickUpPoints;
  final List<BootstrapBatch> batches;
  final List<BootstrapCab> cabs;
  final List<BootstrapDriver> drivers;
  final List<BootstrapCommuter> commuters;
  final BootstrapToday today;

  factory AdminBootstrapResponse.fromJson(Map<String, dynamic> json) {
    return AdminBootstrapResponse(
      status: json['status']?.toString() ?? 'ok',
      generatedAt: json['generatedAt']?.toString() ?? '',
      adminCode: json['adminCode']?.toString(),
      organizations: _mapList(json['organizations'], BootstrapOrganization.fromJson),
      enums: BootstrapEnums.fromJson(_asMap(json['enums'])),
      routes: _mapList(json['routes'], BootstrapRoute.fromJson),
      pickUpPoints: _mapList(json['pickUpPoints'], BootstrapPickUpPoint.fromJson),
      batches: _mapList(json['batches'], BootstrapBatch.fromJson),
      cabs: _mapList(json['cabs'], BootstrapCab.fromJson),
      drivers: _mapList(json['drivers'], BootstrapDriver.fromJson),
      commuters: _mapList(json['commuters'], BootstrapCommuter.fromJson),
      today: BootstrapToday.fromJson(_asMap(json['today'])),
    );
  }

  static List<T> _mapList<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (raw is! List) return const [];
    final out = <T>[];
    for (final item in raw) {
      if (item is Map<String, dynamic>) {
        out.add(fromJson(item));
      } else if (item is Map) {
        out.add(fromJson(Map<String, dynamic>.from(item)));
      }
    }
    return out;
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }
}

class BootstrapEnums {
  const BootstrapEnums({
    this.userType = const [],
    this.acType = const [],
  });

  final List<String> userType;
  final List<String> acType;

  factory BootstrapEnums.fromJson(Map<String, dynamic> json) {
    return BootstrapEnums(
      userType: _stringList(json['userType']),
      acType: _stringList(json['acType']),
    );
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map((e) => e.toString()).toList();
  }
}

class BootstrapToday {
  const BootstrapToday({
    this.tripDate,
    this.activeMorningBatchIds = const [],
    this.activeReturnBatchIds = const [],
  });

  final String? tripDate;
  final List<String> activeMorningBatchIds;
  final List<String> activeReturnBatchIds;

  factory BootstrapToday.fromJson(Map<String, dynamic> json) {
    return BootstrapToday(
      tripDate: json['tripDate']?.toString(),
      activeMorningBatchIds: BootstrapEnums._stringList(
        json['activeMorningBatchIds'],
      ),
      activeReturnBatchIds: BootstrapEnums._stringList(
        json['activeReturnBatchIds'],
      ),
    );
  }
}

class BootstrapOrganization {
  const BootstrapOrganization({
    required this.id,
    this.orgName,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? orgName;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  factory BootstrapOrganization.fromJson(Map<String, dynamic> json) {
    return BootstrapOrganization(
      id: json['id']?.toString() ?? '',
      orgName: _nullableString(json['orgName'] ?? json['organizationName']),
      isActive: _asBool(json['isActive'], defaultValue: true),
      createdAt: _nullableString(json['createdAt']),
      updatedAt: _nullableString(json['updatedAt']),
    );
  }
}

class BootstrapRoute {
  const BootstrapRoute({
    required this.id,
    this.routeName,
    this.routeCode,
    this.isActive = true,
    this.organizationId,
  });

  final int id;
  final String? routeName;
  final String? routeCode;
  final bool isActive;
  final String? organizationId;

  factory BootstrapRoute.fromJson(Map<String, dynamic> json) {
    return BootstrapRoute(
      id: _asInt(json['id']) ?? 0,
      routeName: _nullableString(json['routeName']),
      routeCode: _nullableString(json['routeCode']),
      isActive: _asBool(json['isActive'], defaultValue: true),
      organizationId: _nullableString(
        json['organizationId'] ?? json['organization_id'],
      ),
    );
  }
}

class BootstrapPickUpPoint {
  const BootstrapPickUpPoint({
    required this.id,
    this.pickUpPointName,
    this.routeId,
    this.lat,
    this.longitude,
    this.inLine,
    this.area,
    this.isActive = true,
    this.organizationId,
  });

  final int id;
  final String? pickUpPointName;
  final int? routeId;
  final double? lat;
  final double? longitude;
  final int? inLine;
  final String? area;
  final bool isActive;
  final String? organizationId;

  factory BootstrapPickUpPoint.fromJson(Map<String, dynamic> json) {
    return BootstrapPickUpPoint(
      id: _asInt(json['id']) ?? 0,
      pickUpPointName: _nullableString(json['pickUpPointName']),
      routeId: _asInt(json['routeId']),
      lat: _asDouble(json['lat']),
      longitude: _asDouble(json['longitude']),
      inLine: _asInt(json['inLine']),
      area: _nullableString(json['area']),
      isActive: _asBool(json['isActive'], defaultValue: true),
      organizationId: _nullableString(
        json['organizationId'] ?? json['organization_id'],
      ),
    );
  }
}

class BootstrapBatch {
  const BootstrapBatch({
    required this.id,
    this.batchName,
    this.batchTime,
    this.endTime,
    this.startDate,
    this.endDate,
    this.isActive = true,
    this.organizationId,
  });

  final String id;
  final String? batchName;
  final String? batchTime;
  final String? endTime;
  final String? startDate;
  final String? endDate;
  final bool isActive;
  final String? organizationId;

  factory BootstrapBatch.fromJson(Map<String, dynamic> json) {
    return BootstrapBatch(
      id: json['id']?.toString() ?? '',
      batchName: _nullableString(json['batchName']),
      batchTime: _nullableString(json['batchTime']),
      endTime: _nullableString(json['endTime'] ?? json['end_time']),
      startDate: _nullableString(json['startDate']),
      endDate: _nullableString(json['endDate']),
      isActive: _asBool(json['isActive'], defaultValue: true),
      organizationId: _nullableString(
        json['organizationId'] ?? json['organization_id'],
      ),
    );
  }
}

class BootstrapCab {
  const BootstrapCab({
    required this.id,
    this.regNumber,
    this.capacity,
    this.routeId,
    this.acType,
    this.trackingVehicleId,
    this.isActive = true,
    this.organizationId,
  });

  final int id;
  final String? regNumber;
  final int? capacity;
  final int? routeId;
  final String? acType;
  final String? trackingVehicleId;
  final bool isActive;
  final String? organizationId;

  factory BootstrapCab.fromJson(Map<String, dynamic> json) {
    return BootstrapCab(
      id: _asInt(json['id']) ?? 0,
      regNumber: _nullableString(json['regNumber']),
      capacity: _asInt(json['capacity']),
      routeId: _asInt(json['routeId']),
      acType: _nullableString(json['acType']),
      trackingVehicleId: _nullableString(json['trackingVehicleId']),
      isActive: _asBool(json['isActive'], defaultValue: true),
      organizationId: _nullableString(
        json['organizationId'] ?? json['organization_id'],
      ),
    );
  }
}

class BootstrapDriver {
  const BootstrapDriver({
    required this.driverId,
    this.userId,
    this.username,
    this.mobileNumber,
    this.batchId,
    this.cabId,
    this.isActive = true,
    this.organizationId,
  });

  final int driverId;
  final int? userId;
  final String? username;
  final String? mobileNumber;
  final String? batchId;
  final int? cabId;
  final bool isActive;
  final String? organizationId;

  factory BootstrapDriver.fromJson(Map<String, dynamic> json) {
    return BootstrapDriver(
      driverId: _asInt(json['driverId'] ?? json['id']) ?? 0,
      userId: _asInt(json['userId']),
      username: _nullableString(json['username']),
      mobileNumber: _nullableString(json['mobileNumber']),
      batchId: _nullableString(json['batchId']),
      cabId: _asInt(json['cabId']),
      isActive: _asBool(json['isActive'], defaultValue: true),
      organizationId: _nullableString(
        json['organizationId'] ?? json['organization_id'],
      ),
    );
  }
}

class BootstrapCommuter {
  const BootstrapCommuter({
    required this.commuterId,
    this.userId,
    this.username,
    this.mobileNumber,
    this.userType,
    this.batchId,
    this.popId,
    this.cabId,
    this.isComing = false,
    this.hasPaid,
    this.isActive = true,
    this.organizationId,
  });

  final int commuterId;
  final int? userId;
  final String? username;
  final String? mobileNumber;
  final String? userType;
  final String? batchId;
  final int? popId;
  final int? cabId;
  final bool isComing;
  final bool? hasPaid;
  final bool isActive;
  final String? organizationId;

  factory BootstrapCommuter.fromJson(Map<String, dynamic> json) {
    return BootstrapCommuter(
      commuterId: _asInt(json['commuterId'] ?? json['id']) ?? 0,
      userId: _asInt(json['userId']),
      username: _nullableString(json['username']),
      mobileNumber: _nullableString(json['mobileNumber']),
      userType: _nullableString(json['userType']),
      batchId: _nullableString(json['batchId']),
      popId: _asInt(json['popId']),
      cabId: _asInt(json['cabId']),
      isComing: json['isComing'] == true,
      hasPaid: json['hasPaid'] == null ? null : json['hasPaid'] == true,
      isActive: _asBool(json['isActive'], defaultValue: true),
      organizationId: _nullableString(
        json['organizationId'] ?? json['organization_id'],
      ),
    );
  }
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return null;
  return int.tryParse(text);
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return null;
  return double.tryParse(text);
}

String? _nullableString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null' || text == 'None') {
    return null;
  }
  return text;
}

bool _asBool(dynamic value, {required bool defaultValue}) {
  if (value == null) return defaultValue;
  if (value is bool) return value;
  final text = value.toString().trim().toLowerCase();
  if (text.isEmpty || text == 'null') return defaultValue;
  if (text == 'true' || text == '1') return true;
  if (text == 'false' || text == '0') return false;
  return defaultValue;
}
