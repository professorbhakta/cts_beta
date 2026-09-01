import 'package:cts/api/api_result.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/core/concurrency/batched_runner.dart';
import 'package:cts/core/network/network_action_guard.dart';
import 'package:cts/features/batches/models/return_available_model.dart';
import 'package:cts/features/batches/models/return_batch_status_model.dart';
import 'package:cts/features/batches/repositories/return_batch_repository.dart';
import 'package:cts/features/commuters/models/commuter_model.dart';
import 'package:flutter/foundation.dart';

class ReturnBatchProvider with ChangeNotifier {
  ReturnBatchProvider(
    this._repository, {
    NetworkActionGuard? networkGuard,
    int statusFetchConcurrency = defaultStatusFetchConcurrency,
  })  : _networkGuard = networkGuard,
        _statusFetchConcurrency = statusFetchConcurrency;

  static const int defaultStatusFetchConcurrency = 10;

  final ReturnBatchRepository _repository;
  final NetworkActionGuard? _networkGuard;
  final int _statusFetchConcurrency;

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

  List<CommuterModel> _waitingCommuters = [];
  List<CommuterModel> get waitingCommuters => _waitingCommuters;

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

  int _loadGeneration = 0;

  bool get hasTripData =>
      _homeCommuters.isNotEmpty ||
      _overflowCommuters.isNotEmpty ||
      _waitingCommuters.isNotEmpty ||
      _confirmedCommuters.isNotEmpty ||
      _capacity != null;

  bool isDisplayingBatch(String batchId) => _activeBatchId == batchId;

  @visibleForTesting
  void bindActiveBatchForTesting(String batchId) {
    _activeBatchId = batchId;
  }

  /// Clears trip lists immediately when opening a different batch (before async load).
  void beginReturnTripLoad(String batchId, {bool keepExistingData = false}) {
    _activeBatchId = batchId;
    _state = ViewState.loading;
    _errorMessage = null;
    if (!keepExistingData) {
      _clearTripLists();
    }
    notifyListeners();
  }

  Future<void> fetchStatusesForBatches(List<String> batchIds) async {
    if (batchIds.isEmpty) return;

    await runWithConcurrency(
      batchIds,
      concurrency: _statusFetchConcurrency,
      task: (batchId) async {
        final result = await _repository.getReturnBatchStatus(batchId);
        if (result.isSuccess && result.data != null) {
          _statusByBatchId[batchId] = result.data!;
          notifyListeners();
        }
        return result;
      },
    );
  }

  ReturnBatchStatusModel? statusForBatch(String batchId) =>
      _statusByBatchId[batchId];

  Future<void> loadReturnTrip(
    String batchId, {
    bool keepExistingData = false,
  }) async {
    final generation = ++_loadGeneration;
    beginReturnTripLoad(batchId, keepExistingData: keepExistingData);

    final results = await Future.wait([
      _repository.getAvailableCommuters(batchId),
      _repository.getConfirmedCommuters(batchId),
      _repository.getReturnBatchStatus(batchId),
    ]);

    if (generation != _loadGeneration) return;

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
    _waitingCommuters = split.waiting;
    final waitingIds = {
      for (final commuter in _waitingCommuters)
        if (commuter.userId?.id != null) commuter.userId!.id.toString(),
    };
    _homeCommuters =
        split.home.where(isOpen).where((c) {
          final id = c.userId?.id?.toString();
          return id == null || !waitingIds.contains(id);
        }).toList();
    _overflowCommuters =
        split.overflow.where(isOpen).where((c) {
          final id = c.userId?.id?.toString();
          return id == null || !waitingIds.contains(id);
        }).toList();
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

  Future<String?> joinReturnWaiting(String userId, String batchId) async {
    return _runAction(
      () => _repository.joinReturnWaiting(userId, batchId),
    );
  }

  Future<String?> endReturnTrip(String batchId) async {
    final blocked = await _ensureOnlineForMutation();
    if (blocked != null) return blocked;

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
    _waitingCommuters = [];
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

    final blocked = await _ensureOnlineForMutation();
    if (blocked != null) return blocked;

    _actionInProgress = true;
    notifyListeners();

    final result = await action();
    _actionInProgress = false;

    if (result.isFailure) {
      _errorMessage = result.failure?.message;
      notifyListeners();
      return _errorMessage;
    }

    await loadReturnTrip(batchId, keepExistingData: true);
    return result.data;
  }

  Future<void> onAppResumed({required bool isOnline}) async {
    final batchId = _activeBatchId;
    if (batchId == null || _actionInProgress || !isOnline) return;
    await loadReturnTrip(batchId, keepExistingData: true);
  }

  Future<String?> _ensureOnlineForMutation() async {
    final networkGuard = _networkGuard;
    if (networkGuard == null) return null;
    final guard = await networkGuard.check();
    if (guard.isOnline) return null;
    final message = guard.message ?? NetworkActionGuard.actionBlockedMessage;
    _errorMessage = message;
    notifyListeners();
    return message;
  }

  void clearActiveBatch() {
    _loadGeneration++;
    _activeBatchId = null;
    _clearTripLists();
    _state = ViewState.idle;
    _errorMessage = null;
    notifyListeners();
  }

  /// Full reset for logout — clears picker status cache too.
  void reset() {
    _loadGeneration++;
    _activeBatchId = null;
    _clearTripLists();
    _statusByBatchId.clear();
    _actionInProgress = false;
    _state = ViewState.idle;
    _errorMessage = null;
    notifyListeners();
  }

  void _clearTripLists() {
    _homeCommuters = [];
    _overflowCommuters = [];
    _waitingCommuters = [];
    _confirmedCommuters = [];
    _capacity = null;
  }
}
