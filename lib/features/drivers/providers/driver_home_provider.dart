import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/batches/repositories/return_batch_repository.dart';
import 'package:cts/features/d2d/repositories/d2d_repository.dart';
import 'package:cts/features/drivers/helpers/driver_trip_banner.dart';
import 'package:cts/features/drivers/helpers/driver_yesterday_nudge.dart';
import 'package:cts/features/drivers/models/driver_model.dart';
import 'package:cts/features/drivers/repositories/driver_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  static const _prefsAlertPrefix = 'driver_yesterday_alert_shown_';

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  DriverModel? _driverProfile;
  DriverModel? get driverProfile => _driverProfile;

  DriverTripBannerState _tripBanner = const DriverTripBannerState();
  DriverTripBannerState get tripBanner => _tripBanner;

  DriverYesterdayNudge _yesterdayNudge = const DriverYesterdayNudge();
  DriverYesterdayNudge get yesterdayNudge => _yesterdayNudge;

  /// True when icon should show (yesterday incomplete/auto_closed).
  bool get showTripAlertIcon => _yesterdayNudge.visible;

  /// One-shot dialog after load (null if already shown today for that date).
  String? _pendingAlertMessage;
  String? get pendingAlertMessage => _pendingAlertMessage;

  Future<void> fetchDriverProfile() async {
    _state = ViewState.loading;
    _errorMessage = null;
    _pendingAlertMessage = null;
    notifyListeners();

    final result = await _driverRepository.getDriverProfile();

    if (result.isSuccess) {
      _driverProfile = result.data;
      _state = ViewState.success;
      await _refreshTripBanner();
      await _refreshYesterdayNudge();
    } else {
      _errorMessage = result.failure?.message;
      _state = ViewState.error;
      _tripBanner = const DriverTripBannerState();
      _yesterdayNudge = const DriverYesterdayNudge();
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

  Future<void> _refreshYesterdayNudge() async {
    final batchId = _driverProfile?.batchId?.id?.toString();
    if (batchId == null || batchId.isEmpty) {
      _yesterdayNudge = const DriverYesterdayNudge();
      _pendingAlertMessage = null;
      return;
    }
    _yesterdayNudge = await resolveDriverYesterdayNudge(
      batchId: batchId,
      d2d: _d2dRepository,
    );
    if (!_yesterdayNudge.visible) {
      _pendingAlertMessage = null;
      return;
    }
    final key = '$_prefsAlertPrefix${_yesterdayNudge.yesterdayIso}';
    final prefs = await SharedPreferences.getInstance();
    final already = prefs.getBool(key) ?? false;
    if (!already) {
      _pendingAlertMessage = _yesterdayNudge.message;
    }
  }

  Future<void> markYesterdayAlertShown() async {
    final iso = _yesterdayNudge.yesterdayIso;
    if (iso == null || iso.isEmpty) {
      _pendingAlertMessage = null;
      notifyListeners();
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefsAlertPrefix$iso', true);
    _pendingAlertMessage = null;
    notifyListeners();
  }

  Future<bool> morningStillOpen() async {
    final batchId = _driverProfile?.batchId?.id?.toString();
    if (batchId == null || batchId.isEmpty) return false;
    return isMorningStillOpen(batchId: batchId, d2d: _d2dRepository);
  }
}
