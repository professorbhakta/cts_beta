import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/drivers/domain/repositories/driver_repository.dart';
import 'package:cts/features/drivers/domain/models/driver_model.dart';
import 'package:flutter/material.dart';

class DriverHomeProvider with ChangeNotifier {
  final DriverRepository _driverRepository;

  DriverHomeProvider(this._driverRepository);

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  DriverModel? _driverProfile;
  DriverModel? get driverProfile => _driverProfile;

  Future<void> fetchDriverProfile() async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _driverRepository.getDriverProfile();

    if (result.isSuccess) {
      _driverProfile = result.data;
      _state = ViewState.success;
    } else {
      _errorMessage = result.failure?.message;
      _state = ViewState.error;
    }
    notifyListeners();
  }
}

