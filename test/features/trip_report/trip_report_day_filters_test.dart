import 'package:cts/features/trip_report/helpers/trip_report_day_filters.dart';
import 'package:cts/features/trip_report/models/trip_report_models.dart';
import 'package:cts/features/trip_report/models/trip_report_month_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const incomplete = TripReportBatchItem(
    batchId: '1',
    batchName: 'A',
    adminCode: 'x',
    tripDate: '2026-09-17',
    anyIncomplete: true,
  );
  const clean = TripReportBatchItem(
    batchId: '2',
    batchName: 'B',
    adminCode: 'x',
    tripDate: '2026-09-17',
  );
  const edited = TripReportBatchItem(
    batchId: '3',
    batchName: 'C',
    adminCode: 'x',
    tripDate: '2026-09-17',
    anyEdited: true,
  );

  test('no filters shows all', () {
    final out = filterTripReportItems([incomplete, clean, edited], {});
    expect(out.length, 3);
  });

  test('incomplete chip filters client-side', () {
    final out = filterTripReportItems(
      [incomplete, clean, edited],
      {TripReportDayFilter.incomplete},
    );
    expect(out.map((e) => e.batchId).toList(), ['1']);
  });

  test('multiple chips are OR', () {
    final out = filterTripReportItems(
      [incomplete, clean, edited],
      {TripReportDayFilter.incomplete, TripReportDayFilter.edited},
    );
    expect(out.map((e) => e.batchId).toList(), ['1', '3']);
  });
}
