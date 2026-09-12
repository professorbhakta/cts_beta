// Daily trip report models — snake_case wire keys from /d2d/trip_report/.

enum TripReportLegKind {
  morning,
  ret; // "return" is reserved in Dart

  String get apiValue => this == TripReportLegKind.morning ? 'morning' : 'return';

  static TripReportLegKind? tryParse(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'morning':
        return TripReportLegKind.morning;
      case 'return':
        return TripReportLegKind.ret;
      default:
        return null;
    }
  }
}

/// Display / chip kind for a morning or return leg.
enum TripCloseKind {
  absent,
  open,
  normal,
  incomplete,
  edited,
  autoClosed;

  static TripCloseKind parse(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'absent':
        return TripCloseKind.absent;
      case 'open':
        return TripCloseKind.open;
      case 'normal':
        return TripCloseKind.normal;
      case 'incomplete':
        return TripCloseKind.incomplete;
      case 'edited':
        return TripCloseKind.edited;
      case 'auto_closed':
      case 'autoclosed':
        return TripCloseKind.autoClosed;
      default:
        return TripCloseKind.absent;
    }
  }

  String get label {
    switch (this) {
      case TripCloseKind.absent:
        return 'Absent';
      case TripCloseKind.open:
        return 'Open';
      case TripCloseKind.normal:
        return 'Normal';
      case TripCloseKind.incomplete:
        return 'Incomplete';
      case TripCloseKind.edited:
        return 'Edited';
      case TripCloseKind.autoClosed:
        return 'Auto-closed';
    }
  }
}

class TripReportLeg {
  const TripReportLeg({
    this.tripId,
    this.isActive = false,
    this.endTime,
    this.startKm,
    this.endKm,
    this.distanceKm,
    this.autoClosed = false,
    this.incomplete = false,
    this.edited = false,
    this.closeKind = TripCloseKind.absent,
  });

  final String? tripId;
  final bool isActive;
  final String? endTime;
  final int? startKm;
  final int? endKm;
  final int? distanceKm;
  final bool autoClosed;
  final bool incomplete;
  final bool edited;
  final TripCloseKind closeKind;

  /// Chip kinds to show for this leg (close_kind + auto_closed flag).
  List<TripCloseKind> get displayChips {
    if (closeKind == TripCloseKind.absent) {
      return const [TripCloseKind.absent];
    }
    final chips = <TripCloseKind>[closeKind];
    if (autoClosed && closeKind != TripCloseKind.autoClosed) {
      chips.add(TripCloseKind.autoClosed);
    }
    return chips;
  }

  factory TripReportLeg.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TripReportLeg(closeKind: TripCloseKind.absent);
    }
    final kind = TripCloseKind.parse(json['close_kind']?.toString());
    final autoClosed = json['auto_closed'] == true;
    return TripReportLeg(
      tripId: json['trip_id']?.toString(),
      isActive: json['is_active'] == true,
      endTime: json['end_time']?.toString(),
      startKm: _asInt(json['start_km']),
      endKm: _asInt(json['end_km']),
      distanceKm: _asInt(json['distance_km']),
      autoClosed: autoClosed,
      incomplete: json['incomplete'] == true,
      edited: json['edited'] == true,
      closeKind: kind == TripCloseKind.absent && autoClosed
          ? TripCloseKind.autoClosed
          : kind,
    );
  }

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

class TripReportBatchItem {
  const TripReportBatchItem({
    required this.batchId,
    required this.batchName,
    required this.adminCode,
    required this.tripDate,
    this.morning,
    this.returnLeg,
    this.anyIncomplete = false,
    this.anyEdited = false,
    this.anyAutoClosed = false,
  });

  final String batchId;
  final String batchName;
  final String adminCode;
  final String tripDate;
  final TripReportLeg? morning;
  final TripReportLeg? returnLeg;
  final bool anyIncomplete;
  final bool anyEdited;
  final bool anyAutoClosed;

  factory TripReportBatchItem.fromJson(Map<String, dynamic> json) {
    TripReportLeg? parseLeg(dynamic raw) {
      if (raw == null) return null;
      if (raw is! Map) return null;
      return TripReportLeg.fromJson(Map<String, dynamic>.from(raw));
    }

    return TripReportBatchItem(
      batchId: json['batch_id']?.toString() ?? '',
      batchName: json['batch_name']?.toString() ?? '',
      adminCode: json['admin_code']?.toString() ?? '',
      tripDate: json['trip_date']?.toString() ?? '',
      morning: parseLeg(json['morning']),
      returnLeg: parseLeg(json['return']),
      anyIncomplete: json['any_incomplete'] == true,
      anyEdited: json['any_edited'] == true,
      anyAutoClosed: json['any_auto_closed'] == true,
    );
  }
}

class TripReportResponse {
  const TripReportResponse({
    required this.status,
    required this.tripDate,
    required this.count,
    required this.items,
  });

  final String status;
  final String tripDate;
  final int count;
  final List<TripReportBatchItem> items;

  factory TripReportResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['items'];
    final items = <TripReportBatchItem>[];
    if (raw is List) {
      for (final row in raw) {
        if (row is Map) {
          items.add(
            TripReportBatchItem.fromJson(Map<String, dynamic>.from(row)),
          );
        }
      }
    }
    return TripReportResponse(
      status: json['status']?.toString() ?? '',
      tripDate: json['trip_date']?.toString() ?? '',
      count: TripReportLeg._asInt(json['count']) ?? items.length,
      items: items,
    );
  }
}

class TripReportEditResult {
  const TripReportEditResult({
    required this.status,
    required this.leg,
    required this.batchId,
    required this.tripDate,
    this.tripId,
    this.startKm,
    this.endKm,
    this.distanceKm,
    this.autoClosed = false,
    this.incomplete = false,
    this.edited = false,
  });

  final String status;
  final TripReportLegKind leg;
  final String batchId;
  final String tripDate;
  final String? tripId;
  final int? startKm;
  final int? endKm;
  final int? distanceKm;
  final bool autoClosed;
  final bool incomplete;
  final bool edited;

  factory TripReportEditResult.fromJson(Map<String, dynamic> json) {
    final leg = TripReportLegKind.tryParse(json['leg']?.toString()) ??
        TripReportLegKind.morning;
    return TripReportEditResult(
      status: json['status']?.toString() ?? '',
      leg: leg,
      batchId: json['batch_id']?.toString() ?? '',
      tripDate: json['trip_date']?.toString() ?? '',
      tripId: json['trip_id']?.toString(),
      startKm: TripReportLeg._asInt(json['start_km']),
      endKm: TripReportLeg._asInt(json['end_km']),
      distanceKm: TripReportLeg._asInt(json['distance_km']),
      autoClosed: json['auto_closed'] == true,
      incomplete: json['incomplete'] == true,
      edited: json['edited'] == true,
    );
  }
}
