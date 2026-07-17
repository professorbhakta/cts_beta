import 'dart:async';
import 'package:cts/features/commuters/domain/repositories/commuter_repository.dart';
import 'package:cts/features/commuters/domain/models/commuter_model.dart';
import 'package:flutter/foundation.dart';
import 'package:cts/appManager/view_state.dart';

class CommuterController with ChangeNotifier {
  final CommuterRepository _commuterRepository;

  CommuterController(this._commuterRepository);

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<CommuterModel> _commuters = [];
  List<CommuterModel> get commuters => _commuters;

  bool _isFetching = false; // Prevent race conditions

  Future<void> fetchCommuters() async {
    // Prevent multiple simultaneous calls
    if (_isFetching) return;
    
    _isFetching = true;
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _commuterRepository.getCommuters();

      if (result.isSuccess) {
        _commuters = result.data ?? [];
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

  Future<void> fetchCommutersByBatch(String batchId) async {
    // Prevent multiple simultaneous calls
    if (_isFetching) return;
    
    _isFetching = true;
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _commuterRepository.getCommutersByBatch(batchId);

      if (result.isSuccess) {
        _commuters = result.data ?? [];
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
    _commuters = [];
    _state = ViewState.idle;
    _errorMessage = null;
    _isFetching = false;
    notifyListeners();
  }

  Future<bool> createCommuter(Map<String, dynamic> data) async {
    _state = ViewState.loading;
    notifyListeners();

    final result = await _commuterRepository.createCommuter(data);

    if (result.isSuccess) {
      await fetchCommuters(); 
      return state == ViewState.success;
    } else {
      _errorMessage = result.failure?.message;
      _state = ViewState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCommuter(int userId, Map<String, dynamic> userData, Map<String, dynamic> commuterData) async {
    _state = ViewState.loading;
    notifyListeners();

    final result = await _commuterRepository.updateCommuter(userId, userData, commuterData);

    if (result.isSuccess) {
      await fetchCommuters();
      return state == ViewState.success;
    } else {
      _errorMessage = result.failure?.message;
      _state = ViewState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCommuter(int userId) async {
    // Optimistic update: Remove from UI immediately
    CommuterModel? removedCommuter;
    final index = _commuters.indexWhere((commuter) => commuter.userId?.id == userId);
    if (index != -1) {
      removedCommuter = _commuters[index];
      _commuters.removeAt(index);
      notifyListeners();
    }

    // Then sync with server
    final result = await _commuterRepository.deleteCommuter(userId);

    if (result.isSuccess) {
      return true;
    } else {
      // Rollback on failure: Restore the item
      if (removedCommuter != null && index != -1) {
        _commuters.insert(index, removedCommuter);
        notifyListeners();
      }
      _errorMessage = result.failure?.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCommuterIsComing(int userId, bool isComing) async {
    // Optimistic update: Update UI immediately
    final index = _commuters.indexWhere((commuter) => commuter.userId?.id == userId);
    if (index != -1) {
      _commuters[index].isComing = isComing;
      notifyListeners();
    }

    // Then sync with server
    final result = await _commuterRepository.updateCommuterIsComing(userId, isComing);

    if (result.isSuccess) {
      return true;
    } else {
      // Rollback on failure: Restore the previous value
      if (index != -1) {
        _commuters[index].isComing = !isComing;
        notifyListeners();
      }
      _errorMessage = result.failure?.message;
      notifyListeners();
      return false;
    }
  }
}

