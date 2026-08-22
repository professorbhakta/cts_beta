import 'package:cts/api/api_result.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/batches/models/return_intent_model.dart';
import 'package:cts/features/batches/repositories/return_batch_repository.dart';
import 'package:cts/features/commuters/models/commuter_model.dart';
import 'package:cts/features/commuters/providers/commuter_home_provider.dart';
import 'package:cts/features/commuters/repositories/commuter_repository.dart';
import 'package:cts/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCommuterRepository implements CommuterRepository {
  @override
  Future<ApiResult<CommuterModel>> getCommuterProfile() async {
    return ApiResult.success(
      CommuterModel(userId: UserModel(id: 4, username: 'c1'), isComing: true),
    );
  }

  @override
  Future<ApiResult<void>> updateIsComing(bool isComing) async {
    return ApiResult.success(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeReturnBatchRepository implements ReturnBatchRepository {
  ReturnIntentModel current = const ReturnIntentModel(
    intent: ReturnIntentKind.home,
  );
  List<ReturnIntentOptionModel> options = const [
    ReturnIntentOptionModel(id: '2', batchName: 'Early', endTime: '15:00'),
  ];
  ReturnIntentModel? lastSaved;

  @override
  Future<ApiResult<ReturnIntentModel>> getReturnIntent() async {
    return ApiResult.success(current);
  }

  @override
  Future<ApiResult<ReturnIntentModel>> setReturnIntent(
    ReturnIntentModel intent,
  ) async {
    lastSaved = intent;
    current = intent;
    return ApiResult.success(intent);
  }

  @override
  Future<ApiResult<List<ReturnIntentOptionModel>>>
      getReturnIntentOptions() async {
    return ApiResult.success(options);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('fetchCommuterProfile loads return intent and options', () async {
    final returnRepo = _FakeReturnBatchRepository()
      ..current = const ReturnIntentModel(
        intent: ReturnIntentKind.skip,
      );
    final provider = CommuterHomeProvider(
      _FakeCommuterRepository(),
      returnRepo,
    );

    await provider.fetchCommuterProfile();

    expect(provider.state, ViewState.success);
    expect(provider.returnIntent.intent, ReturnIntentKind.skip);
    expect(provider.earlierOptions, hasLength(1));
  });

  test('selectEarlierIntent saves target batch', () async {
    final returnRepo = _FakeReturnBatchRepository();
    final provider = CommuterHomeProvider(
      _FakeCommuterRepository(),
      returnRepo,
    );

    await provider.fetchCommuterProfile();
    final ok = await provider.selectEarlierIntent('2');

    expect(ok, isTrue);
    expect(returnRepo.lastSaved?.intent, ReturnIntentKind.earlier);
    expect(returnRepo.lastSaved?.targetBatchId, '2');
    expect(provider.returnIntent.intent, ReturnIntentKind.earlier);
    expect(provider.earlierOptionLabel, 'Early (15:00)');
  });
}
