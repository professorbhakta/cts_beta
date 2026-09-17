import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/batches/repositories/return_batch_repository.dart';
import 'package:cts/features/d2d/repositories/d2d_repository.dart';
import 'package:cts/features/drivers/helpers/driver_trip_banner.dart';
import 'package:cts/features/drivers/models/driver_model.dart';
import 'package:cts/features/drivers/repositories/driver_repository.dart';
import 'package:flutter/material.dart';

class DriverHomeProvider with ChangeNotifier {
  DriverHomeProvider(
    this._driverRepository, {
    required D2dRepository d2dRepository,
    required ReturnBatchRepository returnBatchRepository,
  })  : _d2dRepository = d2dRepository,
        _returnBatchRepository = returnBatchRepository;

  final DriverRepository _driverRepository;
  final D2dRepository _d2dRepository;
  final ReturnBatchRepository _returnBatchRepository;

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  DriverModel? _driverProfile;
  DriverModel? get driverProfile => _driverProfile;

  DriverTripBannerState _tripBanner = const DriverTripBannerState();
  DriverTripBannerState get tripBanner => _tripBanner;

  Future<void> fetchDriverProfile() async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _driverRepository.getDriverProfile();

    if (result.isSuccess) {
      _driverProfile = result.data;
      _state = ViewState.success;
      await _refreshTripBanner();
    } else {
      _errorMessage = result.failure?.message;
      _state = ViewState.error;
      _tripBanner = const DriverTripBannerState();
    }
    notifyListeners();
  }

  Future<void> _refreshTripBanner() async {
    final batchId = _driverProfile?.batchId?.id?.toString();
    if (batchId == null || batchId.isEmpty) {
      _tripBanner = const DriverTripBannerState();
      return;
    }
    _tripBanner = await resolveDriverTripBanner(
      batchId: batchId,
      d2d: _d2dRepository,
      returnBatches: _returnBatchRepository,
    );
  }
}
