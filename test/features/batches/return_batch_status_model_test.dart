import 'package:cts/features/batches/models/return_batch_status_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> baseJson() => {
    'batch_id': '1',
    'trip_date': '19-08-2026',
    'is_active': true,
    'available_count': 12,
    'confirmed_count': 3,
    'total_capacity': 53,
    'remaining_capacity': 50,
  };

  test('parses old status payload without extras', () {
    final status = ReturnBatchStatusModel.fromJson(baseJson());
    expect(status.availableCount, 12);
    expect(status.remainingCapacity, 50);
    expect(status.hasPoolExtras, isFalse);
    expect(status.homeHold, isNull);
    expect(status.overflowRemaining, isNull);
  });

  test('parses additive pool extras without touching remaining_capacity', () {
    final status = ReturnBatchStatusModel.fromJson({
      ...baseJson(),
      'home_hold': 25,
      'overflow_confirmed': 0,
      'overflow_remaining': 28,
    });
    expect(status.remainingCapacity, 50);
    expect(status.hasPoolExtras, isTrue);
    expect(status.homeHold, 25);
    expect(status.overflowConfirmed, 0);
    expect(status.overflowRemaining, 28);
  });

  test('home_hold 0 is present extras, not fail-closed omit', () {
    final status = ReturnBatchStatusModel.fromJson({
      ...baseJson(),
      'home_hold': 0,
      'overflow_confirmed': 0,
      'overflow_remaining': 53,
    });
    expect(status.hasPoolExtras, isTrue);
    expect(status.homeHold, 0);
    expect(status.overflowRemaining, 53);
  });

  test('partial extras are treated as omitted', () {
    final status = ReturnBatchStatusModel.fromJson({
      ...baseJson(),
      'home_hold': 25,
    });
    expect(status.hasPoolExtras, isFalse);
    expect(status.homeHold, isNull);
    expect(status.remainingCapacity, 50);
  });
}
