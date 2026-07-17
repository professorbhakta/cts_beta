import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/pops/domain/repositories/pop_repository.dart';
import 'package:cts/models/pop_model.dart';
import 'package:flutter/foundation.dart';

class PopProvider with ChangeNotifier {
  final PopRepository _popRepository;

  PopProvider(this._popRepository);

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<PickUpPointModel> _pops = [];
  List<PickUpPointModel> get pops => _pops;

  bool _isFetching = false; // Prevent race conditions

  Future<void> fetchPops() async {
    // Prevent multiple simultaneous calls
    if (_isFetching) return;
    
    _isFetching = true;
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _popRepository.getPops();
      if (result.isSuccess) {
        _pops = result.data ?? [];
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
    _pops = [];
    _state = ViewState.idle;
    _errorMessage = null;
    _isFetching = false;
    notifyListeners();
  }

  Future<bool> createPop(Map<String, dynamic> data) async {
    _state = ViewState.loading;
    notifyListeners();

    final result = await _popRepository.createPop(data);
    bool success = false;

    if (result.isSuccess) {
      await fetchPops();
      success = true;
      _state = ViewState.success;
    } else {
      _errorMessage = result.failure?.message;
      _state = ViewState.error;
      success = false;
    }

    notifyListeners();
    return success;
  }

  Future<bool> updatePop(int id, Map<String, dynamic> data) async {
    _state = ViewState.loading;
    notifyListeners();

    final result = await _popRepository.updatePop(id, data);
    bool success = false;

    if (result.isSuccess) {
      await fetchPops();
      success = true;
      _state = ViewState.success;
    } else {
      _errorMessage = result.failure?.message;
      _state = ViewState.error;
      success = false;
    }

    notifyListeners();
    return success;
  }

  Future<bool> deletePop(int id) async {
    // Optimistic update: Remove from UI immediately
    PickUpPointModel? removedPop;
    final index = _pops.indexWhere((pop) => pop.id == id);
    if (index != -1) {
      removedPop = _pops[index];
      _pops.removeAt(index);
      notifyListeners();
    }

    // Then sync with server
    final result = await _popRepository.deletePop(id);

    if (result.isSuccess) {
      return true;
    } else {
      // Rollback on failure: Restore the item
      if (removedPop != null && index != -1) {
        _pops.insert(index, removedPop);
        notifyListeners();
      }
      _errorMessage = result.failure?.message;
      notifyListeners();
      return false;
    }
  }
}

