import 'package:cts/features/trip_report/models/trip_report_month_models.dart';
import 'package:cts/features/trip_report/providers/trip_review_alert_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('attention item from flagged month day', () {
    const day = TripReportMonthDay(
      date: '2026-09-17',
      hasTrip: true,
      anyIncomplete: true,
      anyAutoClosed: true,
      anyEdited: false,
    );
    final item = TripAttentionItem.fromMonthDay(day);
    expect(item.date, '2026-09-17');
    expect(item.anyIncomplete, isTrue);
    expect(item.anyAutoClosed, isTrue);
    expect(item.anyEdited, isFalse);
  });

  test('clean day is not attention material for inbox filter', () {
    const day = TripReportMonthDay(date: '2026-09-01', hasTrip: true);
    final flagged = day.anyIncomplete || day.anyAutoClosed || day.anyEdited;
    expect(flagged, isFalse);
  });
}
