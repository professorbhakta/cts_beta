import 'package:cts/api/api_result.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/batches/models/return_available_model.dart';
import 'package:cts/features/batches/models/return_batch_status_model.dart';
import 'package:cts/features/batches/models/return_intent_model.dart';
import 'package:cts/features/batches/providers/return_batch_provider.dart';
import 'package:cts/features/batches/repositories/return_batch_repository.dart';
import 'package:cts/features/commuters/models/commuter_model.dart';
import 'package:cts/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

CommuterModel _commuter(int userId, String name) {
  return CommuterModel(
    userId: UserModel(id: userId, username: name),
  );
}

ReturnBatchStatusModel _status(String batchId) {
  return ReturnBatchStatusModel(
    batchId: batchId,
    tripDate: '2026-08-20',
    isActive: true,
    availableCount: 1,
    confirmedCount: 0,
    totalCapacity: 4,
    remainingCapacity: 4,
  );
}

ReturnBatchConfirmedResult _confirmedResult() {
  return const ReturnBatchConfirmedResult(
    commuters: [],
    capacity: ReturnBatchCapacityModel(
      totalCapacity: 4,
      remainingCapacity: 4,
      confirmedCount: 0,
      isActive: true,
    ),
  );
}

class _FakeReturnBatchRepository implements ReturnBatchRepository {
  _FakeReturnBatchRepository({Duration responseDelay = Duration.zero})
      : responseDelay = responseDelay;

  Duration responseDelay;
  final Map<String, ReturnAvailableResult> availableByBatch = {};

  @override
  Future<ApiResult<ReturnAvailableResult>> getAvailableCommuters(
    String batchId,
  ) async {
    await Future<void>.delayed(responseDelay);
    return ApiResult.success(
      availableByBatch[batchId] ??
          const ReturnAvailableResult(home: [], overflow: []),
    );
  }

  @override
  Future<ApiResult<ReturnBatchConfirmedResult>> getConfirmedCommuters(
    String batchId,
  ) async {
    await Future<void>.delayed(responseDelay);
    return ApiResult.success(_confirmedResult());
  }

  @override
  Future<ApiResult<ReturnBatchStatusModel>> getReturnBatchStatus(
    String batchId,
  ) async {
    await Future<void>.delayed(responseDelay);
    return ApiResult.success(_status(batchId));
  }

  @override
  Future<ApiResult<String>> addCommuterToConfirmList(
    String userId,
    String batchId,
  ) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<String>> removeCommuterFromConfirmList(
    String userId,
    String batchId,
  ) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<void>> endReturnTrip(String batchId) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<ReturnIntentModel>> getReturnIntent() =>
      throw UnimplementedError();

  @override
  Future<ApiResult<ReturnIntentModel>> setReturnIntent(
    ReturnIntentModel intent,
  ) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<List<ReturnIntentOptionModel>>> getReturnIntentOptions() =>
      throw UnimplementedError();
}

void main() {
  group('ReturnBatchProvider lifecycle', () {
    late _FakeReturnBatchRepository repository;
    late ReturnBatchProvider provider;

    setUp(() {
      repository = _FakeReturnBatchRepository();
      provider = ReturnBatchProvider(repository);
    });

    test('clearActiveBatch resets trip state', () {
      provider.bindActiveBatchForTesting('1');
      provider.beginReturnTripLoad('1');
      expect(provider.activeBatchId, '1');
      expect(provider.state, ViewState.loading);

      provider.clearActiveBatch();

      expect(provider.activeBatchId, isNull);
      expect(provider.state, ViewState.idle);
      expect(provider.hasTripData, isFalse);
      expect(provider.homeCommuters, isEmpty);
      expect(provider.confirmedCommuters, isEmpty);
    });

    test('reset clears status cache and trip state', () async {
      repository.availableByBatch['1'] = ReturnAvailableResult(
        home: [_commuter(1, 'Alpha')],
        overflow: [],
      );
      await provider.loadReturnTrip('1');
      await provider.fetchStatusesForBatches(['1']);

      provider.reset();

      expect(provider.activeBatchId, isNull);
      expect(provider.state, ViewState.idle);
      expect(provider.statusByBatchId, isEmpty);
      expect(provider.hasTripData, isFalse);
    });

    test('beginReturnTripLoad clears stale lists when switching batch', () {
      provider.bindActiveBatchForTesting('1');
      provider.beginReturnTripLoad('1');
      provider.beginReturnTripLoad('2');

      expect(provider.activeBatchId, '2');
      expect(provider.state, ViewState.loading);
      expect(provider.hasTripData, isFalse);
      expect(provider.isDisplayingBatch('2'), isTrue);
      expect(provider.isDisplayingBatch('1'), isFalse);
    });

    test('loadReturnTrip replaces batch A data with batch B', () async {
      repository.availableByBatch['1'] = ReturnAvailableResult(
        home: [_commuter(1, 'Batch-A')],
        overflow: [],
      );
      repository.availableByBatch['2'] = ReturnAvailableResult(
        home: [_commuter(2, 'Batch-B')],
        overflow: [],
      );

      await provider.loadReturnTrip('1');
      expect(provider.homeCommuters.single.userId?.username, 'Batch-A');

      final loadB = provider.loadReturnTrip('2');
      expect(provider.hasTripData, isFalse);
      expect(provider.state, ViewState.loading);
      await loadB;

      expect(provider.activeBatchId, '2');
      expect(provider.homeCommuters.single.userId?.username, 'Batch-B');
    });

    test('superseded in-flight load does not overwrite newer batch', () async {
      repository.responseDelay = const Duration(milliseconds: 50);
      repository.availableByBatch['1'] = ReturnAvailableResult(
        home: [_commuter(1, 'Slow-A')],
        overflow: [],
      );
      repository.availableByBatch['2'] = ReturnAvailableResult(
        home: [_commuter(2, 'Fast-B')],
        overflow: [],
      );

      final slowLoad = provider.loadReturnTrip('1');
      await Future<void>.delayed(Duration.zero);
      await provider.loadReturnTrip('2');
      await slowLoad;

      expect(provider.activeBatchId, '2');
      expect(provider.homeCommuters.single.userId?.username, 'Fast-B');
    });

    test('keepExistingData retains lists while reloading same batch', () async {
      repository.availableByBatch['1'] = ReturnAvailableResult(
        home: [_commuter(1, 'Rider')],
        overflow: [],
      );
      await provider.loadReturnTrip('1');
      expect(provider.hasTripData, isTrue);

      repository.availableByBatch['1'] = ReturnAvailableResult(
        home: [_commuter(1, 'Rider'), _commuter(2, 'New')],
        overflow: [],
      );
      final reload = provider.loadReturnTrip('1', keepExistingData: true);

      expect(provider.hasTripData, isTrue);
      expect(provider.homeCommuters.single.userId?.username, 'Rider');
      await reload;
      expect(provider.homeCommuters, hasLength(2));
    });
  });
}
