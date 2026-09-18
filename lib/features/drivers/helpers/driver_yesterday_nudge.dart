import 'package:cts/features/d2d/models/odometer_models.dart';
import 'package:cts/features/d2d/repositories/d2d_repository.dart';
import 'package:cts/features/drivers/helpers/driver_trip_banner.dart';

class DriverYesterdayNudge {
  const DriverYesterdayNudge({
    this.visible = false,
    this.message,
    this.batchId,
    this.yesterdayIso,
    this.morningIssue = false,
    this.returnIssue = false,
  });

  final bool visible;
  final String? message;
  final String? batchId;
  final String? yesterdayIso;
  final bool morningIssue;
  final bool returnIssue;
}

String formatIsoDate(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${y}-${m}-${day}';
}

DateTime kolkataYesterday([DateTime? utcNow]) {
  final now = kolkataNow(utcNow);
  return DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
}

/// True when leg looks incomplete or auto-closed from flags or odometer shape.
bool legNeedsDriverAttention(OdometerLegSnapshot leg) {
  if (leg.incomplete || leg.autoClosed) return true;
  // Started but not complete.
  if (leg.startKm != null && !leg.complete) return true;
  // Auto-close pattern: complete with end_km == start_km (BE sets both).
  if (leg.complete &&
      leg.startKm != null &&
      leg.endKm != null &&
      leg.startKm == leg.endKm) {
    return true;
  }
  return false;
}

Future<DriverYesterdayNudge> resolveDriverYesterdayNudge({
  required String batchId,
  required D2dRepository d2d,
  DateTime? nowUtc,
}) async {
  final id = batchId.trim();
  if (id.isEmpty) return const DriverYesterdayNudge();

  final yday = kolkataYesterday(nowUtc);
  final iso = formatIsoDate(yday);
  final odo = await d2d.getOdometer(id, date: iso);
  if (!odo.isSuccess || odo.data == null) {
    return DriverYesterdayNudge(batchId: id, yesterdayIso: iso);
  }

  final snap = odo.data!;
  final morningIssue = legNeedsDriverAttention(snap.morning);
  final returnIssue = legNeedsDriverAttention(snap.returnLeg);
  if (!morningIssue && !returnIssue) {
    return DriverYesterdayNudge(batchId: id, yesterdayIso: iso);
  }

  final parts = <String>[];
  if (morningIssue) parts.add('morning');
  if (returnIssue) parts.add('return');
  final which = parts.join(' and ');

  return DriverYesterdayNudge(
    visible: true,
    batchId: id,
    yesterdayIso: iso,
    morningIssue: morningIssue,
    returnIssue: returnIssue,
    message:
        'Yesterday ($iso) $which trip needs attention (incomplete or auto-closed). Finish end km if still open.',
  );
}

/// Morning still open — block/nudge before starting return flow.
Future<bool> isMorningStillOpen({
  required String batchId,
  required D2dRepository d2d,
}) async {
  final id = batchId.trim();
  if (id.isEmpty) return false;
  final status = await d2d.getLogStatus(id);
  if (status.isSuccess && status.data == D2dTripStatus.active) {
    return true;
  }
  final odo = await d2d.getOdometer(id);
  if (odo.isSuccess && odo.data != null) {
    final m = odo.data!.morning;
    if (m.startKm != null && !m.complete) return true;
    if (m.incomplete) return true;
  }
  return false;
}
