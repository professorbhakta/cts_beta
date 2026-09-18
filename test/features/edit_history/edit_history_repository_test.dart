import 'package:cts/api/api_list.dart';
import 'package:cts/features/edit_history/models/edit_record_models.dart';
import 'package:cts/features/edit_history/repositories/edit_history_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EditHistoryRepositoryImpl.buildListUrl', () {
    test('encodes date user_id path limit', () {
      final url = EditHistoryRepositoryImpl.buildListUrl(
        date: '2026-09-19',
        userId: 7,
        path: 'edit_end_km',
        limit: 50,
      );
      expect(url, startsWith(ApiUrl.editRecordUrl));
      expect(url, contains('date=2026-09-19'));
      expect(url, contains('user_id=7'));
      expect(url, contains('path=edit_end_km'));
      expect(url, contains('limit=50'));
    });

    test('omits empty optional filters', () {
      final url = EditHistoryRepositoryImpl.buildListUrl(limit: 100);
      expect(url, 'd2d/edit_record/?limit=100');
      expect(url.contains('date='), isFalse);
      expect(url.contains('user_id='), isFalse);
      expect(url.contains('path='), isFalse);
    });
  });

  group('EditRecordItem trip_odometer shape', () {
    test('parses from→to payload_summary', () {
      final item = EditRecordItem.fromJson({
        'id': 42,
        'userId': 7,
        'username': 'er_admin',
        'edited_at': '2026-09-19T10:00:00+05:30',
        'method': 'PATCH',
        'path': '/d2d/trip_report/edit_end_km/',
        'resource_type': 'trip_odometer',
        'resource_id': '123',
        'payload_summary': {
          'leg': 'morning',
          'previous_end_km': 1000,
          'end_km': 1025,
          'date': '2026-09-19',
          'batch_id': 12,
        },
        'ip': '127.0.0.1',
      });
      expect(item.isTripOdometer, isTrue);
      expect(item.username, 'er_admin');
      expect(item.endKmChangeLabel, '1000 → 1025');
      expect(item.payloadSummary['leg'], 'morning');
      expect(item.payloadSummary['batch_id'], 12);
    });

    test('list response maps items', () {
      final resp = EditRecordListResponse.fromJson({
        'status': 'ok',
        'count': 1,
        'items': [
          {
            'id': 1,
            'userId': 2,
            'resource_type': 'trip_odometer',
            'payload_summary': {'end_km': 10},
          },
        ],
      });
      expect(resp.count, 1);
      expect(resp.items.single.resourceType, 'trip_odometer');
    });
  });
}
