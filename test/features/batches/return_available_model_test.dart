import 'package:cts/features/batches/models/return_available_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> rider(int id, {String? batchName}) => {
    'userId': {'id': id, 'username': 'U$id', 'mobileNumber': '9$id'},
    'popId': {'pickUpPointName': 'Stop', 'inLine': 1},
    if (batchName != null)
      'batchId': {'id': id, 'batchName': batchName},
  };

  test('parses home then overflow and ignores flat commuters', () {
    final result = ReturnAvailableResult.fromJson({
      'status': 'ok',
      'batch_id': '4',
      'home': [rider(21, batchName: 'Batch-01')],
      'overflow': [rider(780, batchName: 'Batch-10')],
      'commuters': [rider(999)],
      'home_count': 1,
      'overflow_count': 1,
    });
    expect(result.home, hasLength(1));
    expect(result.home.first.userId?.id, 21);
    expect(result.overflow, hasLength(1));
    expect(result.overflow.first.userId?.id, 780);
    expect(result.all, hasLength(2));
  });

  test('old flat commuters payload is empty, not confirmable', () {
    final result = ReturnAvailableResult.fromJson({
      'status': 'ok',
      'commuters': [rider(4), rider(6)],
      'available_count': 2,
    });
    expect(result.home, isEmpty);
    expect(result.overflow, isEmpty);
    expect(result.all, isEmpty);
  });

  test('missing lists parse as empty', () {
    final result = ReturnAvailableResult.fromJson({
      'status': 'ok',
      'home': [],
    });
    expect(result.home, isEmpty);
    expect(result.overflow, isEmpty);
  });
}
