import 'dart:math';

import 'package:cts/api/api_result.dart';
import 'package:cts/features/batches/models/return_batch_status_model.dart';
import 'package:cts/features/batches/providers/return_batch_provider.dart';
import 'package:cts/features/batches/repositories/return_batch_repository.dart';
import 'package:flutter_test/flutter_test.dart';

ReturnBatchStatusModel _status(String batchId) {
  return ReturnBatchStatusModel(
    batchId: batchId,
    tripDate: '2026-08-20',
    isActive: false,
    availableCount: 1,
    confirmedCount: 0,
    totalCapacity: 4,
    remainingCapacity: 4,
  );
}

class _TrackingReturnBatchRepository implements ReturnBatchRepository {
  _TrackingReturnBatchRepository({this.responseDelay = Duration.zero});

  final Duration responseDelay;
  var inFlight = 0;
  var maxInFlight = 0;
  var callCount = 0;

  @override
  Future<ApiResult<ReturnBatchStatusModel>> getReturnBatchStatus(
    String batchId,
  ) async {
    callCount++;
    inFlight++;
    maxInFlight = max(maxInFlight, inFlight);
    await Future<void>.delayed(responseDelay);
    inFlight--;
    return ApiResult.success(_status(batchId));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ReturnBatchProvider.fetchStatusesForBatches', () {
    test('caps concurrent status calls', () async {
      final repository = _TrackingReturnBatchRepository(
        responseDelay: const Duration(milliseconds: 30),
      );
      final provider = ReturnBatchProvider(
        repository,
        statusFetchConcurrency: 5,
      );

      final batchIds = List.generate(20, (index) => '${index + 1}');
      await provider.fetchStatusesForBatches(batchIds);

      expect(repository.callCount, 20);
      expect(repository.maxInFlight, lessThanOrEqualTo(5));
      expect(provider.statusByBatchId.length, 20);
    });

    test('updates cache progressively during fetch', () async {
      final repository = _TrackingReturnBatchRepository(
        responseDelay: const Duration(milliseconds: 5),
      );
      final provider = ReturnBatchProvider(
        repository,
        statusFetchConcurrency: 3,
      );
      var notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.fetchStatusesForBatches(['1', '2', '3', '4']);

      expect(provider.statusByBatchId.keys, containsAll(['1', '2', '3', '4']));
      expect(notifyCount, greaterThanOrEqualTo(4));
    });
  });
}
