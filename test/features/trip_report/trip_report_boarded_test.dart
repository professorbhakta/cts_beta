import 'package:cts/features/trip_report/models/trip_report_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TripReport boarded[] parse', () {
    test('parses tip boarded rows (user_id, boarded_at, source)', () {
      final leg = TripReportLeg.fromJson({
        'close_kind': 'normal',
        'start_km': 10,
        'end_km': 20,
        'boarded': [
          {
            'user_id': '101',
            'boarded_at': '2026-09-17T08:15:00+05:30',
            'source': 'qr',
          },
          {
            'user_id': '102',
            'boarded_at': '2026-09-17T08:20:00+05:30',
            'source': 'manual',
          },
        ],
      });

      expect(leg.boarded, hasLength(2));
      expect(leg.boarded.first.userId, '101');
      expect(leg.boarded.first.boardedAt, '2026-09-17T08:15:00+05:30');
      expect(leg.boarded.first.source, 'qr');
      expect(leg.boarded.first.name, isNull);
      expect(leg.boarded.first.mobile, isNull);
      expect(leg.boarded.first.displayPrimary, '101');
      expect(leg.effectiveBoardedCount, 2);
    });

    test('empty boarded [] and missing boarded → empty list', () {
      final empty = TripReportLeg.fromJson({
        'close_kind': 'open',
        'boarded': <dynamic>[],
      });
      expect(empty.boarded, isEmpty);
      expect(empty.effectiveBoardedCount, 0);

      final missing = TripReportLeg.fromJson({
        'close_kind': 'normal',
        'start_km': 1,
      });
      expect(missing.boarded, isEmpty);
    });

    test('null-safe enrichment name/mobile + leg boarded_count/driver', () {
      final leg = TripReportLeg.fromJson({
        'close_kind': 'normal',
        'boarded_count': 1,
        'driver_name': 'Ravi',
        'driver_user_id': 'd9',
        'boarded': [
          {
            'user_id': '55',
            'boarded_at': '2026-09-17T09:00:00+05:30',
            'source': 'qr',
            'name': 'Ankit',
            'mobile': '9876543210',
          },
        ],
      });

      expect(leg.boardedCount, 1);
      expect(leg.driverName, 'Ravi');
      expect(leg.driverUserId, 'd9');
      expect(leg.effectiveBoardedCount, 1);

      final rider = leg.boarded.single;
      expect(rider.name, 'Ankit');
      expect(rider.mobile, '9876543210');
      expect(rider.displayPrimary, 'Ankit');
      expect(rider.displaySecondary, '9876543210');
    });

    test('enrichment string-null / empty → null; display falls back to user_id',
        () {
      final leg = TripReportLeg.fromJson({
        'close_kind': 'normal',
        'driver_name': 'null',
        'driver_user_id': '',
        'boarded': [
          {
            'user_id': '77',
            'boarded_at': null,
            'source': '  ',
            'name': '',
            'mobile': 'null',
          },
        ],
      });

      expect(leg.driverName, isNull);
      expect(leg.driverUserId, isNull);
      final rider = leg.boarded.single;
      expect(rider.name, isNull);
      expect(rider.mobile, isNull);
      expect(rider.source, isNull);
      expect(rider.boardedAt, isNull);
      expect(rider.displayPrimary, '77');
      expect(rider.displaySecondary, isNull);
    });

    test('ignores non-map boarded entries', () {
      final leg = TripReportLeg.fromJson({
        'close_kind': 'normal',
        'boarded': [
          'bad',
          3,
          {'user_id': '1', 'boarded_at': 't', 'source': 'qr'},
        ],
      });
      expect(leg.boarded, hasLength(1));
      expect(leg.boarded.single.userId, '1');
    });
  });
}
