import 'package:cts/api/api_result.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/batches/models/return_batch_status_model.dart';
import 'package:cts/features/batches/repositories/return_batch_repository.dart';
import 'package:cts/features/commuters/models/commuter_model.dart';
import 'package:flutter/foundation.dart';

class ReturnBatchProvider with ChangeNotifier {
  ReturnBatchProvider(this._repository);

  final ReturnBatchRepository _repository;

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _activeBatchId;
  String? get activeBatchId => _activeBatchId;

  List<CommuterModel> _availableCommuters = [];
  List<CommuterModel> get availableCommuters => _availableCommuters;

  List<CommuterModel> _confirmedCommuters = [];
  List<CommuterModel> get confirmedCommuters => _confirmedCommuters;

  ReturnBatchCapacityModel? _capacity;
  ReturnBatchCapacityModel? get capacity => _capacity;

  final Map<String, ReturnBatchStatusModel> _statusByBatchId = {};
  Map<String, ReturnBatchStatusModel> get statusByBatchId => _statusByBatchId;

  bool _actionInProgress = false;
  bool get actionInProgress => _actionInProgress;

  Future<void> fetchStatusesForBatches(List<String> batchIds) async {
    if (batchIds.isEmpty) return;

    final results = await Future.wait(
      batchIds.map(_repository.getReturnBatchStatus),
    );

    for (var i = 0; i < batchIds.length; i++) {
      final result = results[i];
      if (result.isSuccess && result.data != null) {
        _statusByBatchId[batchIds[i]] = result.data!;
      }
    }
    notifyListeners();
  }

  ReturnBatchStatusModel? statusForBatch(String batchId) =>
      _statusByBatchId[batchId];

  Future<void> loadReturnTrip(String batchId) async {
    _activeBatchId = batchId;
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    final results = await Future.wait([
      _repository.getAvailableCommuters(batchId),
      _repository.getConfirmedCommuters(batchId),
    ]);

    final availableResult = results[0] as ApiResult<List<CommuterModel>>;
    final confirmedResult =
        results[1] as ApiResult<ReturnBatchConfirmedResult>;

    if (availableResult.isFailure) {
      _errorMessage = availableResult.failure?.message;
      _state = ViewState.error;
      notifyListeners();
      return;
    }

    if (confirmedResult.isFailure) {
      _errorMessage = confirmedResult.failure?.message;
      _state = ViewState.error;
      notifyListeners();
      return;
    }

    _availableCommuters = availableResult.data ?? [];
    _confirmedCommuters = confirmedResult.data?.commuters ?? [];
    _capacity = confirmedResult.data?.capacity;
    _state = ViewState.success;
    notifyListeners();
  }

  Future<String?> confirmCommuter(String userId, String batchId) async {
    return _runAction(
      () => _repository.addCommuterToConfirmList(userId, batchId),
    );
  }

  Future<String?> removeCommuter(String userId, String batchId) async {
    return _runAction(
      () => _repository.removeCommuterFromConfirmList(userId, batchId),
    );
  }

  Future<String?> endReturnTrip(String batchId) async {
    _actionInProgress = true;
    notifyListeners();

    final result = await _repository.endReturnTrip(batchId);
    _actionInProgress = false;

    if (result.isFailure) {
      _errorMessage = result.failure?.message;
      notifyListeners();
      return _errorMessage;
    }

    _availableCommuters = [];
    _confirmedCommuters = [];
    _capacity = const ReturnBatchCapacityModel(
      totalCapacity: 0,
      remainingCapacity: 0,
      confirmedCount: 0,
      isActive: false,
    );
    _state = ViewState.success;
    notifyListeners();
    return null;
  }

  Future<String?> _runAction(
    Future<ApiResult<String>> Function() action,
  ) async {
    final batchId = _activeBatchId;
    if (batchId == null) return 'No active batch';

    _actionInProgress = true;
    notifyListeners();

    final result = await action();
    _actionInProgress = false;

    if (result.isFailure) {
      _errorMessage = result.failure?.message;
      notifyListeners();
      return _errorMessage;
    }

    await loadReturnTrip(batchId);
    return result.data;
  }

  void clearActiveBatch() {
    _activeBatchId = null;
    _availableCommuters = [];
    _confirmedCommuters = [];
    _capacity = null;
    _state = ViewState.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
