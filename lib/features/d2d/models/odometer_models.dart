// Odometer API models — mirrors GET/POST /d2d/odometer/… payloads.

enum OdometerLeg {
  morning,
  ret; // "return" is reserved in Dart

  String get apiValue => this == OdometerLeg.morning ? 'morning' : 'return';

  static OdometerLeg? tryParse(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'morning':
        return OdometerLeg.morning;
      case 'return':
        return OdometerLeg.ret;
      default:
        return null;
    }
  }
}

class OdometerLegSnapshot {
  const OdometerLegSnapshot({
    this.startKm,
    this.endKm,
    this.startPhotoUrl,
    this.endPhotoUrl,
    this.startRecordedAt,
    this.endRecordedAt,
    this.distanceKm,
    this.complete = false,
  });

  final int? startKm;
  final int? endKm;
  final String? startPhotoUrl;
  final String? endPhotoUrl;
  final String? startRecordedAt;
  final String? endRecordedAt;
  final int? distanceKm;
  final bool complete;

  factory OdometerLegSnapshot.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const OdometerLegSnapshot();
    }
    return OdometerLegSnapshot(
      startKm: _asInt(json['start_km']),
      endKm: _asInt(json['end_km']),
      startPhotoUrl: json['start_photo']?.toString(),
      endPhotoUrl: json['end_photo']?.toString(),
      startRecordedAt: json['start_recorded_at']?.toString(),
      endRecordedAt: json['end_recorded_at']?.toString(),
      distanceKm: _asInt(json['distance_km']),
      complete: json['complete'] == true,
    );
  }

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

class OdometerSnapshot {
  const OdometerSnapshot({
    required this.batchId,
    required this.tripDate,
    this.d2dId,
    required this.morning,
    required this.returnLeg,
    this.gapKm,
    this.complete = false,
  });

  final String batchId;
  final String tripDate;
  final int? d2dId;
  final OdometerLegSnapshot morning;
  final OdometerLegSnapshot returnLeg;
  final int? gapKm;
  final bool complete;

  factory OdometerSnapshot.fromJson(Map<String, dynamic> json) {
    return OdometerSnapshot(
      batchId: json['batch_id']?.toString() ?? '',
      tripDate: json['trip_date']?.toString() ?? '',
      d2dId: OdometerLegSnapshot._asInt(json['d2d_id']),
      morning: OdometerLegSnapshot.fromJson(
        json['morning'] is Map
            ? Map<String, dynamic>.from(json['morning'] as Map)
            : null,
      ),
      returnLeg: OdometerLegSnapshot.fromJson(
        json['return'] is Map
            ? Map<String, dynamic>.from(json['return'] as Map)
            : null,
      ),
      gapKm: OdometerLegSnapshot._asInt(json['gap_km']),
      complete: json['complete'] == true,
    );
  }
}

class OdometerOrgList {
  const OdometerOrgList({
    required this.tripDate,
    required this.items,
  });

  final String tripDate;
  final List<OdometerSnapshot> items;

  factory OdometerOrgList.fromJson(Map<String, dynamic> json) {
    final raw = json['items'];
    final items = <OdometerSnapshot>[];
    if (raw is List) {
      for (final row in raw) {
        if (row is Map) {
          items.add(OdometerSnapshot.fromJson(Map<String, dynamic>.from(row)));
        }
      }
    }
    return OdometerOrgList(
      tripDate: json['trip_date']?.toString() ?? '',
      items: items,
    );
  }
}
