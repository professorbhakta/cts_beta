/// Month index from GET /d2d/trip_report/month/.
class TripReportMonthDay {
  const TripReportMonthDay({
    required this.date,
    this.hasTrip = false,
    this.anyIncomplete = false,
    this.anyAutoClosed = false,
    this.anyEdited = false,
    this.morningCount = 0,
    this.returnCount = 0,
  });

  final String date;
  final bool hasTrip;
  final bool anyIncomplete;
  final bool anyAutoClosed;
  final bool anyEdited;
  final int morningCount;
  final int returnCount;

  bool get hasFlag => anyIncomplete || anyAutoClosed || anyEdited;

  factory TripReportMonthDay.fromJson(Map<String, dynamic> json) {
    return TripReportMonthDay(
      date: json['date']?.toString() ?? '',
      hasTrip: json['has_trip'] == true,
      anyIncomplete: json['any_incomplete'] == true,
      anyAutoClosed: json['any_auto_closed'] == true,
      anyEdited: json['any_edited'] == true,
      morningCount: _asInt(json['morning_count']) ?? 0,
      returnCount: _asInt(json['return_count']) ?? 0,
    );
  }
}

class TripReportMonthResponse {
  const TripReportMonthResponse({
    required this.status,
    required this.year,
    required this.month,
    this.adminCode,
    required this.days,
  });

  final String status;
  final int year;
  final int month;
  final String? adminCode;
  final List<TripReportMonthDay> days;

  TripReportMonthDay? dayFor(String dateIso) {
    for (final d in days) {
      if (d.date == dateIso) return d;
    }
    return null;
  }

  factory TripReportMonthResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['days'];
    final days = <TripReportMonthDay>[];
    if (raw is List) {
      for (final row in raw) {
        if (row is Map) {
          days.add(
            TripReportMonthDay.fromJson(Map<String, dynamic>.from(row)),
          );
        }
      }
    }
    return TripReportMonthResponse(
      status: json['status']?.toString() ?? 'ok',
      year: _asInt(json['year']) ?? 0,
      month: _asInt(json['month']) ?? 0,
      adminCode: json['admin_code']?.toString(),
      days: days,
    );
  }
}

/// Client-side day-detail filter chips (do not refetch month or day).
enum TripReportDayFilter { incomplete, autoClosed, edited }

int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  return int.tryParse(v.toString());
}
