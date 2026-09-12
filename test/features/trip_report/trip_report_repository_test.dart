import 'package:cts/api/api_list.dart';
import 'package:cts/features/trip_report/models/trip_report_models.dart';
import 'package:cts/features/trip_report/repositories/trip_report_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TripReportRepositoryImpl URL/body builders', () {
    test('buildReportUrl encodes date and admin_code', () {
      final url = TripReportRepositoryImpl.buildReportUrl(
        date: '2026-09-12',
        adminCode: 'ac 1',
      );
      expect(url, startsWith(ApiUrl.tripReportUrl));
      expect(url, contains('date=2026-09-12'));
      expect(url, contains('admin_code=ac+1'));
      expect(url, 'd2d/trip_report/?date=2026-09-12&admin_code=ac+1');
    });

    test('buildEditBody includes optional date', () {
      final withDate = TripReportRepositoryImpl.buildEditBody(
        batchId: '42',
        leg: TripReportLegKind.morning,
        endKm: 150,
        date: '2026-09-12',
      );
      expect(withDate, {
        'batch_id': '42',
        'leg': 'morning',
        'end_km': 150,
        'date': '2026-09-12',
      });

      final noDate = TripReportRepositoryImpl.buildEditBody(
        batchId: '42',
        leg: TripReportLegKind.ret,
        endKm: 160,
      );
      expect(noDate, {
        'batch_id': '42',
        'leg': 'return',
        'end_km': 160,
      });
      expect(noDate.containsKey('date'), isFalse);
    });

    test('edit endpoint constant', () {
      expect(ApiUrl.tripReportEditEndKmUrl, 'd2d/trip_report/edit_end_km/');
    });
  });
}
