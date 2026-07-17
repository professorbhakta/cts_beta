import 'package:cts/offline_temp/data/offline_seed_data.dart';
import 'package:cts/offline_temp/data/offline_seed_importer.dart';
import 'package:cts/offline_temp/data/offline_temp_repository.dart';
import 'package:cts/offline_temp/models/offline_batch.dart';
import 'package:cts/offline_temp/models/offline_commuter.dart';
import 'package:cts/offline_temp/models/offline_commuter_filter.dart';
import 'package:cts/offline_temp/models/offline_pop.dart';
import 'package:cts/offline_temp/models/offline_route.dart';
import 'package:cts/offline_temp/services/offline_export_service.dart';
import 'package:cts/offline_temp/utils/offline_validators.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class OfflineTempProvider extends ChangeNotifier {
  OfflineTempProvider({OfflineTempRepository? repository})
    : _repository = repository ?? OfflineTempRepository();

  final OfflineTempRepository _repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<OfflineRoute> _routes = [];
  List<OfflineRoute> get routes => _routes;

  List<OfflinePop> _pops = [];
  List<OfflinePop> get pops => _pops;

  List<OfflineBatch> _batches = [];
  List<OfflineBatch> get batches => _batches;

  List<OfflineCommuter> _allCommuters = [];
  List<OfflineCommuter> get allCommuters => _allCommuters;

  OfflineCommuterFilter _filter = OfflineCommuterFilter.empty;
  OfflineCommuterFilter get filter => _filter;

  List<String> _cabs = [];
  List<String> get cabs => _cabs;

  String _exportText = '';
  String get exportText => _exportText;

  Future<void> initialize() async {
    if (hasOfflineSeedData && !await _repository.hasAnyData()) {
      await importSeedData(offlineSeedData);
      return;
    }
    await refreshAll();
  }

  Future<void> refreshAll() async {
    _setLoading(true);
    try {
      _routes = await _repository.getRoutes();
      _pops = await _repository.getAllPops();
      _batches = await _repository.getBatches();
      _cabs = await _repository.getDistinctCabs(batchId: _filter.batchId);
      await _applyFilter();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load offline data.';
      if (kDebugMode) debugPrint('OfflineTempProvider.refreshAll: $e');
    } finally {
      _setLoading(false);
    }
  }

  List<OfflinePop> popsForRoute(int routeId) {
    return _pops.where((pop) => pop.routeId == routeId).toList();
  }

  Future<List<OfflineCommuter>> getCommutersForBatch(int batchId) {
    return _repository.getCommutersByBatch(batchId);
  }

  Future<OfflineBatch?> getBatch(int batchId) {
    return _repository.getBatchById(batchId);
  }

  Future<List<OfflinePop>> loadPopsForRoute(int routeId) {
    return _repository.getPopsByRoute(routeId);
  }

  // Routes
  Future<bool> addRoute(String name) async {
    final trimmed = name.trim();
    final validationError = OfflineValidators.routeName(trimmed);
    if (validationError != null) return false;

    try {
      if (await _repository.routeNameExists(trimmed)) return false;
      await _repository.insertRoute(trimmed);
      await refreshAll();
      return true;
    } on DatabaseException catch (e) {
      if (kDebugMode) debugPrint('addRoute: $e');
      return false;
    }
  }

  Future<bool> updateRouteName(int id, String name) async {
    final trimmed = name.trim();
    final validationError = OfflineValidators.routeName(trimmed);
    if (validationError != null) return false;

    if (await _repository.routeNameExists(trimmed, excludeRouteId: id)) {
      return false;
    }
    await _repository.updateRoute(id, trimmed);
    await refreshAll();
    return true;
  }

  Future<bool> deleteRoute(int id) async {
    try {
      await _repository.deleteRoute(id);
      await refreshAll();
      return true;
    } on DatabaseException catch (e) {
      if (kDebugMode) debugPrint('deleteRoute: $e');
      return false;
    }
  }

  // POPs
  Future<bool> addPop({required int routeId, required String name}) async {
    final trimmed = name.trim();
    final validationError = OfflineValidators.popName(trimmed);
    if (validationError != null) return false;

    try {
      if (await _repository.popNameExistsOnRoute(routeId, trimmed)) {
        return false;
      }
      await _repository.insertPop(routeId: routeId, name: trimmed);
      await refreshAll();
      return true;
    } on DatabaseException catch (e) {
      if (kDebugMode) debugPrint('addPop: $e');
      return false;
    }
  }

  Future<bool> updatePopName(int id, String name) async {
    final trimmed = name.trim();
    final validationError = OfflineValidators.popName(trimmed);
    if (validationError != null) return false;

    OfflinePop? pop;
    for (final candidate in _pops) {
      if (candidate.id == id) {
        pop = candidate;
        break;
      }
    }
    if (pop == null) return false;

    if (await _repository.popNameExistsOnRoute(
      pop.routeId,
      trimmed,
      excludePopId: id,
    )) {
      return false;
    }

    await _repository.updatePop(id, trimmed);
    await refreshAll();
    return true;
  }

  Future<bool> deletePop(int id) async {
    try {
      await _repository.deletePop(id);
      await refreshAll();
      return true;
    } on DatabaseException catch (e) {
      if (kDebugMode) debugPrint('deletePop: $e');
      return false;
    }
  }

  // Batches
  Future<bool> addBatch(String name) async {
    final trimmed = name.trim();
    final validationError = OfflineValidators.batchName(trimmed);
    if (validationError != null) return false;

    if (await _repository.batchNameExists(trimmed)) return false;
    await _repository.insertBatch(trimmed);
    await refreshAll();
    return true;
  }

  Future<bool> updateBatchName(int id, String name) async {
    final trimmed = name.trim();
    final validationError = OfflineValidators.batchName(trimmed);
    if (validationError != null) return false;

    if (await _repository.batchNameExists(trimmed, excludeBatchId: id)) {
      return false;
    }
    await _repository.updateBatch(id, trimmed);
    await refreshAll();
    return true;
  }

  Future<void> deleteBatch(int id) async {
    await _repository.deleteBatch(id);
    await refreshAll();
  }

  // Commuters
  Future<String?> saveCommuter(OfflineCommuter commuter) async {
    final name = commuter.name.trim();
    final mobile = commuter.mobile.trim();
    final cab = commuter.cab.trim();

    final nameError = OfflineValidators.commuterName(name);
    if (nameError != null) return nameError;

    final mobileError = OfflineValidators.optionalMobile(mobile);
    if (mobileError != null) return mobileError;

    final cabError = OfflineValidators.optionalCab(cab);
    if (cabError != null) return cabError;

    if (mobile.isNotEmpty &&
        await _repository.isMobileUsedInBatch(
          commuter.batchId,
          mobile,
          excludeCommuterId: commuter.id,
        )) {
      return 'This mobile number is already used in this batch.';
    }

    final toSave = commuter.copyWith(
      name: name,
      mobile: mobile,
      cab: cab,
    );

    if (commuter.id == null) {
      await _repository.insertCommuter(toSave);
    } else {
      await _repository.updateCommuter(toSave);
    }
    await refreshAll();
    return null;
  }

  Future<void> deleteCommuter(int id) async {
    await _repository.deleteCommuter(id);
    await refreshAll();
  }

  Future<void> toggleIsComing(int id, bool isComing) async {
    await _repository.toggleIsComing(id, isComing);
    await refreshAll();
  }

  Future<void> updateFilter(OfflineCommuterFilter filter) async {
    _filter = filter;
    _cabs = await _repository.getDistinctCabs(batchId: _filter.batchId);
    notifyListeners();
    await _applyFilter();
  }

  Future<void> _applyFilter() async {
    _allCommuters = await _repository.getAllCommuters(filter: _filter);
    _exportText = OfflineExportService.buildReport(commuters: _allCommuters);
    notifyListeners();
  }

  Future<void> regenerateExportFromFilter() async {
    _allCommuters = await _repository.getAllCommuters(filter: _filter);
    _exportText = OfflineExportService.buildReport(commuters: _allCommuters);
    notifyListeners();
  }

  Future<OfflineSeedResult> importSeedData(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final result = await OfflineSeedImporter().import(data);
      await refreshAll();
      return result;
    } finally {
      _setLoading(false);
    }
  }

  /// Deletes all rows from offline routes, POPs, batches, and commuters.
  Future<void> dumpAllData() async {
    _setLoading(true);
    try {
      await _repository.clearAllData();
      _filter = OfflineCommuterFilter.empty;
      await refreshAll();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to delete offline data.';
      if (kDebugMode) debugPrint('OfflineTempProvider.dumpAllData: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
