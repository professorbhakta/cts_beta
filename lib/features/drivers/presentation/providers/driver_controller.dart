import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/drivers/domain/repositories/driver_repository.dart';
import 'package:cts/features/drivers/domain/models/driver_model.dart';
import 'package:flutter/foundation.dart';

class DriverProvider with ChangeNotifier {
  final DriverRepository _driverRepository;

  DriverProvider(this._driverRepository);

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<DriverModel> _drivers = [];
  List<DriverModel> get drivers => _drivers;

  bool _isFetching = false; // Prevent race conditions

  Future<void> fetchDrivers() async {
    // Prevent multiple simultaneous calls
    if (_isFetching) return;
    
    _isFetching = true;
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _driverRepository.getDrivers();

      if (result.isSuccess) {
        _drivers = result.data ?? [];
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
    _drivers = [];
    _state = ViewState.idle;
    _errorMessage = null;
    _isFetching = false;
    notifyListeners();
  }

  Future<bool> createDriver(Map<String, dynamic> data) async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _driverRepository.createDriver(data);

    if (result.isSuccess) {
      await fetchDrivers(); 
      return state == ViewState.success;
    } else {
      _errorMessage = result.failure?.message;
      _state = ViewState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDriver(int id, Map<String, dynamic> userData, Map<String, dynamic> driverData ) async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _driverRepository.updateDriver(id, userData, driverData);

    if (result.isSuccess) {
      await fetchDrivers();
      return state == ViewState.success;
    } else {
      _errorMessage = result.failure?.message;
      _state = ViewState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDriver(int id) async {
    // Optimistic update: Remove from UI immediately
    DriverModel? removedDriver;
    final index = _drivers.indexWhere((driver) => driver.userId?.id == id);
    if (index != -1) {
      removedDriver = _drivers[index];
      _drivers.removeAt(index);
      notifyListeners();
    }

    // Then sync with server
    final result = await _driverRepository.deleteDriver(id);

    if (result.isSuccess) {
      return true;
    } else {
      // Rollback on failure: Restore the item
      if (removedDriver != null && index != -1) {
        _drivers.insert(index, removedDriver);
        notifyListeners();
      }
      _errorMessage = result.failure?.message;
      notifyListeners();
      return false;
    }
  }
}

