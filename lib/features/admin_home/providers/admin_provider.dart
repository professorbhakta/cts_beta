import 'dart:async';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/batches/repositories/batch_repository.dart';
import 'package:cts/features/batches/repositories/running_batch_repository.dart';
import 'package:cts/features/cabs/repositories/cab_repository.dart';
import 'package:cts/features/commuters/repositories/commuter_repository.dart';
import 'package:cts/features/drivers/repositories/driver_repository.dart';
import 'package:cts/features/pops/repositories/pop_repository.dart';
import 'package:cts/features/routes/repositories/route_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cts/features/commuters/models/commuter_model.dart';

class AdminProvider with ChangeNotifier {
  final BatchRepository _batchRepository;
  final CommuterRepository _commuterRepository;
  final DriverRepository _driverRepository;
  final CabRepository _cabRepository;
  final RouteRepository _routeRepository;
  final PopRepository _popRepository;
  // Add the new repository
  final RunningBatchRepository _runningBatchRepository;

  AdminProvider(
    this._batchRepository,
    this._commuterRepository,
    this._driverRepository,
    this._cabRepository,
    this._routeRepository,
    this._popRepository,
    // Add to constructor
    this._runningBatchRepository,
  );

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

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
  
  // Add new properties for the new data
  int _runningBatchCount = 0;
  int get runningBatchCount => _runningBatchCount;

  int _isComingCount = 0;
  int get isComingCount => _isComingCount;

  Future<void> loadDashboardData() async {
    // This method remains unchanged as requested
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    final results = await Future.wait([
      _batchRepository.getBatches(),
      _commuterRepository.getCommuters(),
      _driverRepository.getDrivers(),
      _cabRepository.getCabs(),
      _routeRepository.getRoutes(),
      _popRepository.getPops(),
    ]);

    bool hasError = false;

    final batchResult = results[0];
    if (batchResult.isSuccess) {
      _batchCount = batchResult.data?.length ?? 0;
    } else { hasError = true; }

    final commuterResult = results[1];
    if (commuterResult.isSuccess) {
      _commuterCount = commuterResult.data?.length ?? 0;
    } else { hasError = true; }

    final driverResult = results[2];
    if (driverResult.isSuccess) {
      _driverCount = driverResult.data?.length ?? 0;
    } else { hasError = true; }

    final cabResult = results[3];
    if (cabResult.isSuccess) {
      _cabCount = cabResult.data?.length ?? 0;
    } else { hasError = true; }

    final routeResult = results[4];
    if (routeResult.isSuccess) {
      _routeCount = routeResult.data?.length ?? 0;
    } else { hasError = true; }

    final popResult = results[5];
    if (popResult.isSuccess) {
      _popCount = popResult.data?.length ?? 0;
    } else { hasError = true; }

    if (hasError) {
      _state = ViewState.error;
      _errorMessage = 'Failed to load some dashboard data.';
    } else {
      _state = ViewState.success;
    }

    notifyListeners();
  }

  // START OF NEW METHOD
  Future<void> loadDetailedDashboardData() async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    // Fetch all data in parallel, including the new running batches
    final results = await Future.wait([
      _batchRepository.getBatches(),
      _commuterRepository.getCommuters(),
      _driverRepository.getDrivers(),
      _cabRepository.getCabs(),
      _routeRepository.getRoutes(),
      _popRepository.getPops(),
      _runningBatchRepository.fetchRunningBatches(), 
    ]);

    bool hasError = false;

    // Process results with error checking
    final batchResult = results[0];
    if (batchResult.isSuccess) {
      _batchCount = batchResult.data?.length ?? 0;
    } else { hasError = true; }

    final commuterResult = results[1];
    if (commuterResult.isSuccess) {
      final commuters = commuterResult.data as List<CommuterModel>?;
      _commuterCount = commuters?.length ?? 0;
      // Calculate the isComing count
      _isComingCount = commuters?.where((c) => c.isComing == true).length ?? 0;
    } else { hasError = true; }

    final driverResult = results[2];
    if (driverResult.isSuccess) {
      _driverCount = driverResult.data?.length ?? 0;
    } else { hasError = true; }

    final cabResult = results[3];
    if (cabResult.isSuccess) {
      _cabCount = cabResult.data?.length ?? 0;
    } else { hasError = true; }
    
    final routeResult = results[4];
    if (routeResult.isSuccess) {
      _routeCount = routeResult.data?.length ?? 0;
    } else { hasError = true; }

    final popResult = results[5];
    if (popResult.isSuccess) {
      _popCount = popResult.data?.length ?? 0;
    } else { hasError = true; }

    final runningBatchResult = results[6];
    if (runningBatchResult.isSuccess) {
      _runningBatchCount = runningBatchResult.data?.length ?? 0;
    } else { hasError = true; }

    if (hasError) {
      _state = ViewState.error;
      _errorMessage = 'Failed to load some detailed dashboard data.';
    } else {
      _state = ViewState.success;
    }

    notifyListeners();
  }
  // END OF NEW METHOD
}

