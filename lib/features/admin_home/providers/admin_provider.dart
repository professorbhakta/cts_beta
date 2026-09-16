import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/admin_bootstrap/mappers/admin_bootstrap_list_mapper.dart';
import 'package:cts/features/admin_bootstrap/models/admin_bootstrap_response.dart';
import 'package:cts/features/admin_bootstrap/repositories/admin_bootstrap_repository.dart';
import 'package:cts/features/batches/models/batch_model.dart';
import 'package:cts/features/batches/repositories/running_batch_repository.dart';
import 'package:flutter/foundation.dart';

/// Admin home dashboard. Catalog counts come from bootstrap luggage;
/// only live morning running batches still hit a separate API.
class AdminProvider with ChangeNotifier {
  final AdminBootstrapRepository _bootstrapRepository;
  final RunningBatchRepository _runningBatchRepository;

  AdminProvider(
    this._bootstrapRepository,
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

  Future<void> loadDetailedDashboardData({bool forceRefresh = false}) async {
    _state = ViewState.loading;
    _errorMessage = null;
    _hasPartialError = false;
    _loadWarning = null;
    notifyListeners();

    var luggageOk = false;
    var runningOk = false;

    if (forceRefresh) {
      final sync = await _bootstrapRepository.sync();
      luggageOk = sync.isSuccess && sync.data != null;
      if (luggageOk) {
        _applyLuggageCounts(sync.data!);
      }
    } else {
      var luggage = await _bootstrapRepository.readLuggage();
      if (luggage == null) {
        final sync = await _bootstrapRepository.sync();
        luggage = sync.data;
        luggageOk = sync.isSuccess && luggage != null;
      } else {
        luggageOk = true;
      }
      if (luggage != null) {
        _applyLuggageCounts(luggage);
      }
    }

    final runningResult = await _runningBatchRepository.fetchRunningBatches();
    if (runningResult.isSuccess) {
      _runningBatches = List<RunningBatches>.from(runningResult.data ?? []);
      _runningBatchCount = _runningBatches.length;
      runningOk = true;
    }

    if (!luggageOk && !runningOk) {
      _state = ViewState.error;
      _errorMessage = 'Failed to load dashboard data.';
      _hasPartialError = false;
      _loadWarning = null;
    } else if (!luggageOk || !runningOk) {
      _state = ViewState.success;
      _hasPartialError = true;
      _loadWarning = luggageOk
          ? 'Live running trips could not be loaded.'
          : 'Catalog sync failed; live trips may still work.';
    } else {
      _state = ViewState.success;
      _hasPartialError = false;
      _loadWarning = null;
    }

    notifyListeners();
  }

  void _applyLuggageCounts(AdminBootstrapResponse luggage) {
    _batchCount = AdminBootstrapListMapper.batches(luggage).length;
    final commuters = AdminBootstrapListMapper.commuters(luggage);
    _commuterCount = commuters.length;
    _isComingCount = commuters.where((c) => c.isComing == true).length;
    _driverCount = AdminBootstrapListMapper.drivers(luggage).length;
    _cabCount = AdminBootstrapListMapper.cabs(luggage).length;
    _routeCount = AdminBootstrapListMapper.routes(luggage).length;
    _popCount = AdminBootstrapListMapper.pops(luggage).length;
  }

  /// Snapshot of live morning trips only. Does not reload catalog luggage.
  Future<void> refreshRunningBatches() async {
    final result = await _runningBatchRepository.fetchRunningBatches();
    if (!result.isSuccess) return;
    _runningBatches = List<RunningBatches>.from(result.data ?? []);
    _runningBatchCount = _runningBatches.length;
    notifyListeners();
  }
}
