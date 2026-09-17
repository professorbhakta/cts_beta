import 'package:cts/features/batches/repositories/return_batch_repository.dart';
import 'package:cts/features/d2d/models/odometer_models.dart';
import 'package:cts/features/d2d/repositories/d2d_repository.dart';

/// Asia/Kolkata wall clock from device UTC (+05:30). India ops default.
DateTime kolkataNow([DateTime? utcNow]) {
  final utc = (utcNow ?? DateTime.now()).toUtc();
  return utc.add(const Duration(hours: 5, minutes: 30));
}

enum DriverTripBannerKind { none, openPastExpectedEnd, needsEndKm }

class DriverTripBannerState {
  const DriverTripBannerState({
    this.kind = DriverTripBannerKind.none,
    this.message,
    this.batchId,
  });

  final DriverTripBannerKind kind;
  final String? message;
  final String? batchId;

  bool get visible => kind != DriverTripBannerKind.none;
}

/// Path A driver rules from existing APIs only (no trip_report, no FCM).
Future<DriverTripBannerState> resolveDriverTripBanner({
  required String batchId,
  required D2dRepository d2d,
  required ReturnBatchRepository returnBatches,
  DateTime? nowUtc,
}) async {
  final id = batchId.trim();
  if (id.isEmpty) return const DriverTripBannerState();

  final now = kolkataNow(nowUtc);
  final morningStatus = await d2d.getLogStatus(id);
  final returnStatus = await returnBatches.getReturnBatchStatus(id);
  final odo = await d2d.getOdometer(id);

  final morningActive =
      morningStatus.isSuccess && morningStatus.data == D2dTripStatus.active;
  final returnActive =
      returnStatus.isSuccess && returnStatus.data?.isActive == true;

  // Morning expected end 12:00; return expected end 00:00 next day.
  final morningPast = morningActive && now.hour >= 12;
  // After midnight (00:00-11:59) a still-active return is past expected end.
  final returnPast = returnActive && now.hour < 12;

  if (morningPast || returnPast) {
    final which = morningPast && returnPast
        ? 'Morning and return trips are still open past expected end.'
        : morningPast
            ? 'Morning trip is still open past 12:00. End the trip or set end km.'
            : 'Return trip is still open past midnight. End the trip or set end km.';
    return DriverTripBannerState(
      kind: DriverTripBannerKind.openPastExpectedEnd,
      message: which,
      batchId: id,
    );
  }

  if (odo.isSuccess && odo.data != null) {
    final snap = odo.data!;
    if (_legNeedsKm(snap.morning) || _legNeedsKm(snap.returnLeg)) {
      return DriverTripBannerState(
        kind: DriverTripBannerKind.needsEndKm,
        message: 'Trip needs end km. Open the live trip to finish odometer.',
        batchId: id,
      );
    }
  }

  return DriverTripBannerState(batchId: id);
}

bool _legNeedsKm(OdometerLegSnapshot leg) {
  return leg.startKm != null && !leg.complete;
}
