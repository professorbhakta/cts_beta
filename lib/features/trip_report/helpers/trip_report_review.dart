import 'package:cts/features/trip_report/models/trip_report_models.dart';

/// True when Admin/Supervisor should review end_km (incomplete or auto-closed).
bool tripReportNeedsEndKmReview(TripReportResponse? report) {
  if (report == null) return false;
  for (final item in report.items) {
    if (item.anyIncomplete || item.anyAutoClosed) return true;
    if (_legNeedsReview(item.morning) || _legNeedsReview(item.returnLeg)) {
      return true;
    }
  }
  return false;
}

bool _legNeedsReview(TripReportLeg? leg) {
  if (leg == null) return false;
  if (leg.incomplete || leg.autoClosed) return true;
  return leg.closeKind == TripCloseKind.incomplete ||
      leg.closeKind == TripCloseKind.autoClosed;
}

/// Index of first batch that needs review, or -1.
int firstTripReportReviewIndex(TripReportResponse? report) {
  if (report == null) return -1;
  for (var i = 0; i < report.items.length; i++) {
    final item = report.items[i];
    if (item.anyIncomplete ||
        item.anyAutoClosed ||
        _legNeedsReview(item.morning) ||
        _legNeedsReview(item.returnLeg)) {
      return i;
    }
  }
  return -1;
}
