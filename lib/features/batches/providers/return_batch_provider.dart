import 'package:cts/api/api_result.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/batches/models/return_available_model.dart';
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

  List<CommuterModel> _homeCommuters = [];
  List<CommuterModel> get homeCommuters => _homeCommuters;

  List<CommuterModel> _overflowCommuters = [];
  List<CommuterModel> get overflowCommuters => _overflowCommuters;

  List<CommuterModel> get availableCommuters => [
    ..._homeCommuters,
    ..._overflowCommuters,
  ];

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
      _repository.getReturnBatchStatus(batchId),
    ]);

    final availableResult = results[0] as ApiResult<ReturnAvailableResult>;
    final confirmedResult = results[1] as ApiResult<ReturnBatchConfirmedResult>;
    final statusResult = results[2] as ApiResult<ReturnBatchStatusModel>;

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

    final confirmed = confirmedResult.data?.commuters ?? [];
    final confirmedIds = {
      ...?confirmedResult.data?.confirmedUserIds,
      for (final commuter in confirmed)
        if (commuter.userId?.id != null) commuter.userId!.id.toString(),
    };
    _confirmedCommuters = confirmed;
    bool isOpen(CommuterModel commuter) {
      final id = commuter.userId?.id?.toString();
      return id != null && !confirmedIds.contains(id);
    }

    final split = availableResult.data ??
        const ReturnAvailableResult(home: [], overflow: []);
    _homeCommuters = split.home.where(isOpen).toList();
    _overflowCommuters = split.overflow.where(isOpen).toList();
    _capacity = confirmedResult.data?.capacity;
    if (statusResult.isSuccess && statusResult.data != null) {
      _statusByBatchId[batchId] = statusResult.data!;
    }
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

    _homeCommuters = [];
    _overflowCommuters = [];
    _confirmedCommuters = [];
    _statusByBatchId.remove(batchId);
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

  Future<void> onAppResumed({required bool isOnline}) async {
    final batchId = _activeBatchId;
    if (batchId == null || _actionInProgress || !isOnline) return;
    await loadReturnTrip(batchId);
  }

  void clearActiveBatch() {
    _activeBatchId = null;
    _homeCommuters = [];
    _overflowCommuters = [];
    _confirmedCommuters = [];
    _capacity = null;
    _state = ViewState.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
