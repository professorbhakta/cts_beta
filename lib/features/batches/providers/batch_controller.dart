import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/batches/models/batch_model.dart';
import 'package:cts/features/batches/repositories/batch_repository.dart';
import 'package:flutter/foundation.dart';

class BatchProvider with ChangeNotifier {
  final BatchRepository _batchRepository;

  BatchProvider(this._batchRepository);

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<BatchModel> _batches = [];
  List<BatchModel> get batches => _batches;

  bool _isFetching = false; // Prevent race conditions

  Future<void> fetchBatches() async {
    // Prevent multiple simultaneous calls
    if (_isFetching) return;

    _isFetching = true;
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _batchRepository.getBatches();

      if (result.isSuccess) {
        _batches = result.data ?? [];
        _state = ViewState.success;
      } else {
        _errorMessage = result.failure?.message;
        _state = ViewState.error;
      }
      notifyListeners();
    } finally {
      _isFetching = false; // Reset flag even if error occurs
    }
  }

  // Method to reset state (useful for logout)
  void reset() {
    _batches = [];
    _state = ViewState.idle;
    _errorMessage = null;
    _isFetching = false;
    notifyListeners();
  }

  Future<bool> createBatch(Map<String, dynamic> data) async {
    _state = ViewState.loading;
    notifyListeners();

    final result = await _batchRepository.createBatch(data);

    if (result.isSuccess) {
      await fetchBatches();
      return state == ViewState.success;
    } else {
      _errorMessage = result.failure?.message;
      _state = ViewState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBatch(int id, Map<String, dynamic> data) async {
    _state = ViewState.loading;
    notifyListeners();

    final result = await _batchRepository.updateBatch(id, data);

    if (result.isSuccess) {
      await fetchBatches();
      return state == ViewState.success;
    } else {
      _errorMessage = result.failure?.message;
      _state = ViewState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBatch(int id) async {
    // Optimistic update: Remove from UI immediately
    BatchModel? removedBatch;
    final index = _batches.indexWhere((batch) => batch.id == id);
    if (index != -1) {
      removedBatch = _batches[index];
      _batches.removeAt(index);
      notifyListeners();
    }

    // Then sync with server
    final result = await _batchRepository.deleteBatch(id);

    if (result.isSuccess) {
      return true;
    } else {
      // Rollback on failure: Restore the item
      if (removedBatch != null && index != -1) {
        _batches.insert(index, removedBatch);
        notifyListeners();
      }
      _errorMessage = result.failure?.message;
      notifyListeners();
      return false;
    }
  }
}
