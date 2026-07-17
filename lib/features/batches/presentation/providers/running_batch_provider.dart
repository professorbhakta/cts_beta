import 'dart:async';

import 'package:cts/api/api_result.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/batches/domain/models/batch_model.dart';
import 'package:cts/features/batches/domain/repositories/running_batch_repository.dart';
import 'package:flutter/foundation.dart';

class RunningBatchProvider with ChangeNotifier {
  final RunningBatchRepository _repository;
  StreamSubscription<ApiResult<List<RunningBatches>>>? _subscription;

  RunningBatchProvider(this._repository);

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<RunningBatches> _runningBatches = [];
  List<RunningBatches> get runningBatches => _runningBatches;

  void startStream() {
    if (_subscription != null) return;

    _state = ViewState.loading;
    notifyListeners();

    _subscription = _repository.watchRunningBatches().listen(
      (result) {
        if (result.isSuccess) {
          _runningBatches = result.data ?? [];
          _state = ViewState.success;
          _errorMessage = null;
        } else {
          _runningBatches = [];
          _state = ViewState.error;
          _errorMessage = result.failure?.message;
        }
        notifyListeners();
      },
      onError: (error) {
        _runningBatches = [];
        _state = ViewState.error;
        _errorMessage = 'An unexpected error occurred.';
        notifyListeners();
      },
    );
  }

  void stopStream() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> fetchOnce() async {
    _state = ViewState.loading;
    notifyListeners();
    final result = await _repository.fetchRunningBatches();
    if (result.isSuccess) {
      _runningBatches = result.data ?? [];
      _state = ViewState.success;
      _errorMessage = null;
    } else {
      _state = ViewState.error;
      _errorMessage = result.failure?.message;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    stopStream();
    super.dispose();
  }
}
