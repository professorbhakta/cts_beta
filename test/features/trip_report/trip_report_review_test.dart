import 'package:cts/features/trip_report/helpers/trip_report_review.dart';
import 'package:cts/features/trip_report/models/trip_report_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('needs review when any_incomplete', () {
    const report = TripReportResponse(
      status: 'ok',
      tripDate: '2026-09-17',
      count: 1,
      items: [
        TripReportBatchItem(
          batchId: '1',
          batchName: 'A',
          adminCode: 'x',
          tripDate: '2026-09-17',
          anyIncomplete: true,
        ),
      ],
    );
    expect(tripReportNeedsEndKmReview(report), isTrue);
    expect(firstTripReportReviewIndex(report), 0);
  });

  test('needs review when any_auto_closed', () {
    const report = TripReportResponse(
      status: 'ok',
      tripDate: '2026-09-17',
      count: 1,
      items: [
        TripReportBatchItem(
          batchId: '1',
          batchName: 'A',
          adminCode: 'x',
          tripDate: '2026-09-17',
          anyAutoClosed: true,
        ),
      ],
    );
    expect(tripReportNeedsEndKmReview(report), isTrue);
  });

  test('no review when clean', () {
    const report = TripReportResponse(
      status: 'ok',
      tripDate: '2026-09-17',
      count: 1,
      items: [
        TripReportBatchItem(
          batchId: '1',
          batchName: 'A',
          adminCode: 'x',
          tripDate: '2026-09-17',
        ),
      ],
    );
    expect(tripReportNeedsEndKmReview(report), isFalse);
    expect(firstTripReportReviewIndex(report), -1);
  });
}
