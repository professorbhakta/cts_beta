import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/batches/models/batch_model.dart';
import 'package:cts/features/batches/repositories/running_batch_repository.dart';
import 'package:flutter/foundation.dart';

class RunningBatchProvider with ChangeNotifier {
  final RunningBatchRepository _repository;

  RunningBatchProvider(this._repository);

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<RunningBatches> _runningBatches = [];
  List<RunningBatches> get runningBatches => _runningBatches;

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
}
