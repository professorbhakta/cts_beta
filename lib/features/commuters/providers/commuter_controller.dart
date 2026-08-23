import 'package:cts/features/commuters/repositories/commuter_repository.dart';
import 'package:cts/features/commuters/models/commuter_model.dart';
import 'package:cts/models/user_model.dart';
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

  /// Null = full admin list. Set when [fetchCommutersByBatch] last won.
  String? _listBatchId;
  String? get listBatchId => _listBatchId;

  int _fetchGeneration = 0;
  final Set<int> _isComingInFlight = {};
  bool _markAllComingInFlight = false;
  bool get isMarkAllComingInFlight => _markAllComingInFlight;

  Future<void> fetchCommuters() => _loadCommuters(batchId: null);

  Future<void> fetchCommutersByBatch(String batchId) =>
      _loadCommuters(batchId: batchId);

  /// Reloads whichever list is currently scoped (all vs one batch).
  Future<void> refreshCurrentList() {
    final batchId = _listBatchId;
    if (batchId == null) return fetchCommuters();
    return fetchCommutersByBatch(batchId);
  }

  Future<void> _loadCommuters({required String? batchId}) async {
    final generation = ++_fetchGeneration;
    _listBatchId = batchId;
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = batchId == null
        ? await _commuterRepository.getCommuters()
        : await _commuterRepository.getCommutersByBatch(batchId);

    if (generation != _fetchGeneration) return;

    if (result.isSuccess) {
      _commuters = result.data ?? [];
      _state = ViewState.success;
    } else {
      _errorMessage = result.failure?.message;
      _state = ViewState.error;
    }
    notifyListeners();
  }

  Future<UserModel?> fetchUser(int userId) async {
    final result = await _commuterRepository.getUser(userId);
    if (result.isSuccess) {
      return result.data;
    }
    return null;
  }

  void reset() {
    _fetchGeneration++;
    _commuters = [];
    _state = ViewState.idle;
    _errorMessage = null;
    _listBatchId = null;
    notifyListeners();
  }

  Future<bool> createCommuter(Map<String, dynamic> data) async {
    _state = ViewState.loading;
    notifyListeners();

    final result = await _commuterRepository.createCommuter(data);

    if (result.isSuccess) {
      await refreshCurrentList();
      return true;
    } else {
      _errorMessage = result.failure?.message;
      _state = ViewState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCommuter(
    int userId,
    Map<String, dynamic> userData,
    Map<String, dynamic> commuterData,
  ) async {
    _state = ViewState.loading;
    notifyListeners();

    final result = await _commuterRepository.updateCommuter(
      userId,
      userData,
      commuterData,
    );

    if (result.isSuccess) {
      await refreshCurrentList();
      return true;
    } else {
      _errorMessage = result.failure?.message;
      _state = ViewState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCommuter(int userId) async {
    CommuterModel? removedCommuter;
    final index = _commuters.indexWhere(
      (commuter) => commuter.userId?.id == userId,
    );
    if (index != -1) {
      removedCommuter = _commuters[index];
      _commuters.removeAt(index);
      notifyListeners();
    }

    final result = await _commuterRepository.deleteCommuter(userId);

    if (result.isSuccess) {
      return true;
    } else {
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
    if (_isComingInFlight.contains(userId)) {
      return true;
    }
    _isComingInFlight.add(userId);

    final index = _commuters.indexWhere(
      (commuter) => commuter.userId?.id == userId,
    );
    final previous = index != -1 ? _commuters[index].isComing : null;
    if (index != -1) {
      _commuters[index].isComing = isComing;
      notifyListeners();
    }

    try {
      final result = await _commuterRepository.updateCommuterIsComing(
        userId,
        isComing,
      );

      if (result.isSuccess) {
        return true;
      }
      if (index != -1) {
        _commuters[index].isComing = previous;
        notifyListeners();
      }
      _errorMessage = result.failure?.message;
      notifyListeners();
      return false;
    } finally {
      _isComingInFlight.remove(userId);
    }
  }

  /// Marks every loaded org commuter coming. Returns updated count, or null on failure.
  Future<int?> markAllComing() async {
    if (_markAllComingInFlight) {
      return null;
    }
    _markAllComingInFlight = true;
    notifyListeners();

    try {
      final result = await _commuterRepository.markAllComing();
      if (result.isSuccess) {
        for (final c in _commuters) {
          c.isComing = true;
        }
        notifyListeners();
        return result.data ?? 0;
      }
      _errorMessage = result.failure?.message;
      notifyListeners();
      return null;
    } finally {
      _markAllComingInFlight = false;
      notifyListeners();
    }
  }
}
