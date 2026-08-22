import 'package:cts/features/batches/models/return_intent_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReturnIntentModel', () {
    test('fromJson defaults missing intent to home', () {
      final model = ReturnIntentModel.fromJson({});
      expect(model.intent, ReturnIntentKind.home);
      expect(model.targetBatchId, isNull);
    });

    test('fromJson parses skip and earlier with target', () {
      expect(
        ReturnIntentModel.fromJson({'intent': 'skip'}).intent,
        ReturnIntentKind.skip,
      );
      final earlier = ReturnIntentModel.fromJson({
        'intent': 'earlier',
        'target_batch_id': 12,
        'trip_date': '22-08-2026',
        'user_id': 4,
      });
      expect(earlier.intent, ReturnIntentKind.earlier);
      expect(earlier.targetBatchId, '12');
      expect(earlier.tripDate, '22-08-2026');
      expect(earlier.userId, '4');
    });

    test('toPostBody omits target for home/skip and includes for earlier', () {
      expect(
        const ReturnIntentModel(intent: ReturnIntentKind.home).toPostBody(),
        {'intent': 'home'},
      );
      expect(
        const ReturnIntentModel(intent: ReturnIntentKind.skip).toPostBody(),
        {'intent': 'skip'},
      );
      expect(
        const ReturnIntentModel(
          intent: ReturnIntentKind.earlier,
          targetBatchId: '7',
        ).toPostBody(),
        {'intent': 'earlier', 'target_batch_id': '7'},
      );
    });
  });

  group('ReturnIntentOptionModel', () {
    test('fromJson and label', () {
      final option = ReturnIntentOptionModel.fromJson({
        'id': '3',
        'batchName': 'Batch A',
        'end_time': '16:30',
      });
      expect(option.id, '3');
      expect(option.label, 'Batch A (16:30)');
    });
  });
}
