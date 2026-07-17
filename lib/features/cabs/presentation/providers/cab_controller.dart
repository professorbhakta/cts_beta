import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/cabs/domain/repositories/cab_repository.dart';
import 'package:cts/models/cab_model.dart';
import 'package:flutter/foundation.dart';

class CabProvider with ChangeNotifier {
  final CabRepository _cabRepository;

  CabProvider(this._cabRepository);

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<CabModel> _cabs = [];
  List<CabModel> get cabs => _cabs;

  bool _isFetching = false; // Prevent race conditions

  Future<void> fetchCabs() async {
    // Prevent multiple simultaneous calls
    if (_isFetching) return;
    
    _isFetching = true;
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _cabRepository.getCabs();

      if (result.isSuccess) {
        _cabs = result.data ?? [];
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
    _cabs = [];
    _state = ViewState.idle;
    _errorMessage = null;
    _isFetching = false;
    notifyListeners();
  }

  Future<bool> createCab(Map<String, dynamic> data) async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _cabRepository.createCab(data);

    if (result.isSuccess) {
      await fetchCabs(); 
      return state == ViewState.success;
    } else {
      _errorMessage = result.failure?.message;
      _state = ViewState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCab(int id, Map<String, dynamic> data) async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _cabRepository.updateCab(id, data);

    if (result.isSuccess) {
      await fetchCabs();
      return state == ViewState.success;
    } else {
      _errorMessage = result.failure?.message;
      _state = ViewState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCab(int id) async {
    // Optimistic update: Remove from UI immediately
    CabModel? removedCab;
    final index = _cabs.indexWhere((cab) => cab.id == id);
    if (index != -1) {
      removedCab = _cabs[index];
      _cabs.removeAt(index);
      notifyListeners();
    }

    // Then sync with server
    final result = await _cabRepository.deleteCab(id);

    if (result.isSuccess) {
      return true;
    } else {
      // Rollback on failure: Restore the item
      if (removedCab != null && index != -1) {
        _cabs.insert(index, removedCab);
        notifyListeners();
      }
      _errorMessage = result.failure?.message;
      notifyListeners();
      return false;
    }
  }
}

