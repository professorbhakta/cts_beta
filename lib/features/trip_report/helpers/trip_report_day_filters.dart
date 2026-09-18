import 'package:cts/features/trip_report/models/trip_report_models.dart';
import 'package:cts/features/trip_report/models/trip_report_month_models.dart';

bool batchMatchesDayFilters(
  TripReportBatchItem item,
  Set<TripReportDayFilter> filters,
) {
  if (filters.isEmpty) return true;
  if (filters.contains(TripReportDayFilter.incomplete) &&
      (item.anyIncomplete ||
          _legIncomplete(item.morning) ||
          _legIncomplete(item.returnLeg))) {
    return true;
  }
  if (filters.contains(TripReportDayFilter.autoClosed) &&
      (item.anyAutoClosed ||
          _legAutoClosed(item.morning) ||
          _legAutoClosed(item.returnLeg))) {
    return true;
  }
  if (filters.contains(TripReportDayFilter.edited) &&
      (item.anyEdited ||
          _legEdited(item.morning) ||
          _legEdited(item.returnLeg))) {
    return true;
  }
  return false;
}

List<TripReportBatchItem> filterTripReportItems(
  List<TripReportBatchItem> items,
  Set<TripReportDayFilter> filters,
) {
  if (filters.isEmpty) return items;
  return [
    for (final i in items)
      if (batchMatchesDayFilters(i, filters)) i,
  ];
}

bool _legIncomplete(TripReportLeg? leg) {
  if (leg == null) return false;
  return leg.incomplete || leg.closeKind == TripCloseKind.incomplete;
}

bool _legAutoClosed(TripReportLeg? leg) {
  if (leg == null) return false;
  return leg.autoClosed || leg.closeKind == TripCloseKind.autoClosed;
}

bool _legEdited(TripReportLeg? leg) {
  if (leg == null) return false;
  return leg.edited || leg.closeKind == TripCloseKind.edited;
}
