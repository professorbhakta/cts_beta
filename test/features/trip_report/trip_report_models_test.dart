import 'package:cts/features/trip_report/models/trip_report_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TripReport models snake_case parse', () {
    test('parses full report with morning + return legs', () {
      final json = {
        'status': 'ok',
        'trip_date': '2026-09-12',
        'count': 1,
        'items': [
          {
            'batch_id': '42',
            'batch_name': 'Morning A',
            'admin_code': 'ac-1',
            'trip_date': '2026-09-12',
            'morning': {
              'trip_id': 'm1',
              'is_active': false,
              'end_time': '2026-09-12T12:00:00+05:30',
              'start_km': 100,
              'end_km': 100,
              'distance_km': 0,
              'auto_closed': true,
              'incomplete': true,
              'edited': false,
              'close_kind': 'incomplete',
            },
            'return': null,
            'any_incomplete': true,
            'any_edited': false,
            'any_auto_closed': true,
          },
        ],
      };

      final report = TripReportResponse.fromJson(json);
      expect(report.status, 'ok');
      expect(report.tripDate, '2026-09-12');
      expect(report.count, 1);
      expect(report.items, hasLength(1));

      final item = report.items.first;
      expect(item.batchId, '42');
      expect(item.batchName, 'Morning A');
      expect(item.adminCode, 'ac-1');
      expect(item.anyIncomplete, isTrue);
      expect(item.anyAutoClosed, isTrue);
      expect(item.returnLeg, isNull);

      final morning = item.morning!;
      expect(morning.tripId, 'm1');
      expect(morning.startKm, 100);
      expect(morning.endKm, 100);
      expect(morning.autoClosed, isTrue);
      expect(morning.incomplete, isTrue);
      expect(morning.closeKind, TripCloseKind.incomplete);
      expect(morning.displayChips, contains(TripCloseKind.incomplete));
      expect(morning.displayChips, contains(TripCloseKind.autoClosed));
    });

    test('null leg maps to absent close_kind', () {
      final leg = TripReportLeg.fromJson(null);
      expect(leg.closeKind, TripCloseKind.absent);
      expect(leg.displayChips, [TripCloseKind.absent]);
    });

    test('edit_end_km response parse', () {
      final result = TripReportEditResult.fromJson({
        'status': 'ok',
        'leg': 'return',
        'batch_id': '7',
        'trip_date': '2026-09-12',
        'trip_id': 'r9',
        'start_km': 200,
        'end_km': 215,
        'distance_km': 15,
        'auto_closed': false,
        'incomplete': false,
        'edited': true,
      });
      expect(result.leg, TripReportLegKind.ret);
      expect(result.leg.apiValue, 'return');
      expect(result.endKm, 215);
      expect(result.edited, isTrue);
    });
  });
}
