import 'package:cts/features/batches/models/return_available_model.dart';
import 'package:cts/features/batches/models/return_batch_status_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// P7 — client-side expectations for R4/R9 (backend is source of truth).
void main() {
  group('R9 — STOP-gated eligibility (client parse)', () {
    test('empty home and overflow when backend sends no stopped CList riders', () {
      final result = ReturnAvailableResult.fromJson({
        'status': 'ok',
        'home': [],
        'overflow': [],
      });
      expect(result.all, isEmpty);
    });

    test('old flat commuters payload is not confirmable (fail closed)', () {
      final result = ReturnAvailableResult.fromJson({
        'status': 'ok',
        'commuters': [
          {
            'userId': {'id': 4},
          },
        ],
      });
      expect(result.all, isEmpty);
    });
  });

  group('R4 — bidirectional overflow (client parse)', () {
    Map<String, dynamic> rider(int id, {required String batchName}) => {
      'userId': {'id': id, 'username': 'U$id'},
      'batchId': {'id': id, 'batchName': batchName},
    };

    test('overflow list accepts earlier-home rider on later departure', () {
      final result = ReturnAvailableResult.fromJson({
        'status': 'ok',
        'home': [rider(21, batchName: 'Batch-Late')],
        'overflow': [rider(780, batchName: 'Batch-Early')],
      });
      expect(result.home, hasLength(1));
      expect(result.overflow, hasLength(1));
      expect(result.overflow.first.batchId?.batchName, 'Batch-Early');
    });

    test('overflow confirm gated by overflow_remaining not remaining_capacity', () {
      final status = ReturnBatchStatusModel.fromJson({
        'batch_id': '1',
        'available_count': 99,
        'confirmed_count': 0,
        'total_capacity': 53,
        'remaining_capacity': 53,
        'home_hold': 25,
        'overflow_confirmed': 0,
        'overflow_remaining': 0,
      });
      expect(status.hasPoolExtras, isTrue);
      expect(status.overflowRemaining, 0);
      expect(status.remainingCapacity, 53);
    });
  });
}
