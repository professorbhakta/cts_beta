import 'package:cts/features/batches/helpers/return_live_ws.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildReturnLiveWsUrl', () {
    test('appends return/<batchId>/ under ws base', () {
      expect(
        buildReturnLiveWsUrl(
          wsBaseUrl: 'ws://lab/ws/',
          batchId: '42',
        ),
        'ws://lab/ws/return/42/',
      );
    });

    test('normalizes missing trailing slash on base', () {
      expect(
        buildReturnLiveWsUrl(
          wsBaseUrl: 'wss://prod/ws',
          batchId: '7',
        ),
        'wss://prod/ws/return/7/',
      );
    });
  });

  group('ReturnLiveWsPayload.tryParse', () {
    final statusFields = <String, dynamic>{
      'batch_id': '9',
      'trip_date': '2026-09-18',
      'is_active': true,
      'available_count': 3,
      'confirmed_count': 2,
      'total_capacity': 10,
      'remaining_capacity': 8,
      'leg': 'return',
    };

    test('parses added event and wants list refresh', () {
      final payload = ReturnLiveWsPayload.tryParse({
        'result': {...statusFields, 'event': 'added'},
      });
      expect(payload, isNotNull);
      expect(payload!.event, 'added');
      expect(payload.leg, 'return');
      expect(payload.shouldRefreshLists, isTrue);
      expect(payload.isEnded, isFalse);
      expect(payload.status.confirmedCount, 2);
    });

    test('ended event tears down', () {
      final payload = ReturnLiveWsPayload.tryParse({
        'result': {
          ...statusFields,
          'is_active': false,
          'event': 'ended',
        },
      });
      expect(payload!.isEnded, isTrue);
      expect(payload.shouldRefreshLists, isFalse);
    });

    test('is_active false alone ends', () {
      final payload = ReturnLiveWsPayload.tryParse({
        'result': {...statusFields, 'is_active': false},
      });
      expect(payload!.isEnded, isTrue);
    });

    test('returns null without result map', () {
      expect(ReturnLiveWsPayload.tryParse({'ok': true}), isNull);
    });
  });
}
