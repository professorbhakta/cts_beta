import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/batches/models/batch_model.dart';
import 'package:cts/features/batches/repositories/batch_repository.dart';
import 'package:cts/features/batches/repositories/running_batch_repository.dart';
import 'package:cts/features/cabs/repositories/cab_repository.dart';
import 'package:cts/features/commuters/models/commuter_model.dart';
import 'package:cts/features/commuters/repositories/commuter_repository.dart';
import 'package:cts/features/drivers/repositories/driver_repository.dart';
import 'package:cts/features/pops/repositories/pop_repository.dart';
import 'package:cts/features/routes/repositories/route_repository.dart';
import 'package:flutter/foundation.dart';

class AdminProvider with ChangeNotifier {
  final BatchRepository _batchRepository;
  final CommuterRepository _commuterRepository;
  final DriverRepository _driverRepository;
  final CabRepository _cabRepository;
  final RouteRepository _routeRepository;
  final PopRepository _popRepository;
  final RunningBatchRepository _runningBatchRepository;

  AdminProvider(
    this._batchRepository,
    this._commuterRepository,
    this._driverRepository,
    this._cabRepository,
    this._routeRepository,
    this._popRepository,
    this._runningBatchRepository,
  );

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _hasPartialError = false;
  bool get hasPartialError => _hasPartialError;

  String? _loadWarning;
  String? get loadWarning => _loadWarning;

  int _batchCount = 0;
  int get batchCount => _batchCount;

  int _commuterCount = 0;
  int get commuterCount => _commuterCount;

  int _driverCount = 0;
  int get driverCount => _driverCount;

  int _cabCount = 0;
  int get cabCount => _cabCount;

  int _routeCount = 0;
  int get routeCount => _routeCount;

  int _popCount = 0;
  int get popCount => _popCount;

  int _runningBatchCount = 0;
  int get runningBatchCount => _runningBatchCount;

  List<RunningBatches> _runningBatches = [];
  List<RunningBatches> get runningBatches => _runningBatches;

  int _isComingCount = 0;
  int get isComingCount => _isComingCount;

  Future<void> loadDetailedDashboardData() async {
    _state = ViewState.loading;
    _errorMessage = null;
    _hasPartialError = false;
    _loadWarning = null;
    notifyListeners();

    final results = await Future.wait([
      _batchRepository.getBatches(),
      _commuterRepository.getCommuters(),
      _driverRepository.getDrivers(),
      _cabRepository.getCabs(),
      _routeRepository.getRoutes(),
      _popRepository.getPops(),
      _runningBatchRepository.fetchRunningBatches(),
    ]);

    var successCount = 0;

    final batchResult = results[0];
    if (batchResult.isSuccess) {
      _batchCount = batchResult.data?.length ?? 0;
      successCount++;
    }

    final commuterResult = results[1];
    if (commuterResult.isSuccess) {
      final commuters = commuterResult.data as List<CommuterModel>?;
      _commuterCount = commuters?.length ?? 0;
      _isComingCount = commuters?.where((c) => c.isComing == true).length ?? 0;
      successCount++;
    }

    final driverResult = results[2];
    if (driverResult.isSuccess) {
      _driverCount = driverResult.data?.length ?? 0;
      successCount++;
    }

    final cabResult = results[3];
    if (cabResult.isSuccess) {
      _cabCount = cabResult.data?.length ?? 0;
      successCount++;
    }

    final routeResult = results[4];
    if (routeResult.isSuccess) {
      _routeCount = routeResult.data?.length ?? 0;
      successCount++;
    }

    final popResult = results[5];
    if (popResult.isSuccess) {
      _popCount = popResult.data?.length ?? 0;
      successCount++;
    }

    final runningBatchResult = results[6];
    if (runningBatchResult.isSuccess) {
      _runningBatches = List<RunningBatches>.from(
        runningBatchResult.data ?? [],
      );
      _runningBatchCount = _runningBatches.length;
      successCount++;
    }

    if (successCount == 0) {
      _state = ViewState.error;
      _errorMessage = 'Failed to load dashboard data.';
      _hasPartialError = false;
      _loadWarning = null;
    } else if (successCount < results.length) {
      _state = ViewState.success;
      _hasPartialError = true;
      _loadWarning = 'Some dashboard data could not be loaded.';
    } else {
      _state = ViewState.success;
      _hasPartialError = false;
      _loadWarning = null;
    }

    notifyListeners();
  }

  /// Snapshot of live morning trips only. Does not reload the full dashboard.
  Future<void> refreshRunningBatches() async {
    final result = await _runningBatchRepository.fetchRunningBatches();
    if (!result.isSuccess) return;
    _runningBatches = List<RunningBatches>.from(result.data ?? []);
    _runningBatchCount = _runningBatches.length;
    notifyListeners();
  }
}
