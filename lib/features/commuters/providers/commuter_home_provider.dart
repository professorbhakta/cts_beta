import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/batches/models/return_intent_model.dart';
import 'package:cts/features/batches/repositories/return_batch_repository.dart';
import 'package:cts/features/commuters/models/commuter_model.dart';
import 'package:cts/features/commuters/repositories/commuter_repository.dart';
import 'package:flutter/material.dart';

class CommuterHomeProvider with ChangeNotifier {
  CommuterHomeProvider(
    this._commuterRepository,
    this._returnBatchRepository,
  );

  final CommuterRepository _commuterRepository;
  final ReturnBatchRepository _returnBatchRepository;

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  CommuterModel? _commuterProfile;
  CommuterModel? get commuterProfile => _commuterProfile;

  bool _isUpdating = false;
  bool get isUpdating => _isUpdating;

  /// Local UI flag — profile API has no boarded field; set after successful scan.
  bool _hasBoardedToday = false;
  bool get hasBoardedToday => _hasBoardedToday;

  void markBoardedToday() {
    if (_hasBoardedToday) return;
    _hasBoardedToday = true;
    notifyListeners();
  }

  void clearBoardedToday() {
    if (!_hasBoardedToday) return;
    _hasBoardedToday = false;
    notifyListeners();
  }

  ReturnIntentModel _returnIntent = const ReturnIntentModel(
    intent: ReturnIntentKind.home,
  );
  ReturnIntentModel get returnIntent => _returnIntent;

  List<ReturnIntentOptionModel> _earlierOptions = const [];
  List<ReturnIntentOptionModel> get earlierOptions => _earlierOptions;

  bool _isUpdatingIntent = false;
  bool get isUpdatingIntent => _isUpdatingIntent;

  String? _intentErrorMessage;
  String? get intentErrorMessage => _intentErrorMessage;

  String? get earlierOptionLabel {
    final target = _returnIntent.targetBatchId;
    if (target == null || target.isEmpty) return null;
    for (final option in _earlierOptions) {
      if (option.id == target) return option.label;
    }
    return 'Batch $target';
  }

  Future<void> fetchCommuterProfile() async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _commuterRepository.getCommuterProfile();

    if (result.isSuccess) {
      _commuterProfile = result.data;
      _state = ViewState.success;
      await _loadReturnIntentState();
    } else {
      _errorMessage = result.failure?.message;
      _state = ViewState.error;
    }
    notifyListeners();
  }

  Future<void> _loadReturnIntentState() async {
    final intentResult = await _returnBatchRepository.getReturnIntent();
    if (intentResult.isSuccess && intentResult.data != null) {
      _returnIntent = intentResult.data!;
      _intentErrorMessage = null;
    } else {
      _intentErrorMessage = intentResult.failure?.message;
    }

    final optionsResult =
        await _returnBatchRepository.getReturnIntentOptions();
    if (optionsResult.isSuccess && optionsResult.data != null) {
      _earlierOptions = optionsResult.data!;
    }
  }

  Future<bool> updateIsComing(bool isComing) async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _commuterRepository.updateIsComing(isComing);

    if (result.isSuccess) {
      if (_commuterProfile != null) {
        _commuterProfile!.isComing = isComing;
      }
      if (!isComing) {
        _hasBoardedToday = false;
      }
    } else {
      _errorMessage = result.failure?.message;
    }

    _isUpdating = false;
    notifyListeners();
    return result.isSuccess;
  }

  Future<bool> setReturnIntent(ReturnIntentModel intent) async {
    _isUpdatingIntent = true;
    _intentErrorMessage = null;
    notifyListeners();

    final result = await _returnBatchRepository.setReturnIntent(intent);

    if (result.isSuccess && result.data != null) {
      _returnIntent = result.data!;
    } else {
      _intentErrorMessage = result.failure?.message;
    }

    _isUpdatingIntent = false;
    notifyListeners();
    return result.isSuccess;
  }

  Future<bool> selectHomeIntent() {
    return setReturnIntent(
      const ReturnIntentModel(intent: ReturnIntentKind.home),
    );
  }

  Future<bool> selectSkipIntent() {
    return setReturnIntent(
      const ReturnIntentModel(intent: ReturnIntentKind.skip),
    );
  }

  Future<bool> selectEarlierIntent(String targetBatchId) {
    return setReturnIntent(
      ReturnIntentModel(
        intent: ReturnIntentKind.earlier,
        targetBatchId: targetBatchId,
      ),
    );
  }

  bool _isJoiningWaiting = false;
  bool get isJoiningWaiting => _isJoiningWaiting;

  String? _joinWaitingError;
  String? get joinWaitingError => _joinWaitingError;

  /// Commuter self-serve: join FCFS return waiting line for home batch.
  Future<String?> joinReturnWaitingLine() async {
    final profile = _commuterProfile;
    final userId = profile?.userId?.id?.toString();
    final batchId = profile?.batchId?.id?.toString();
    if (userId == null || batchId == null) {
      _joinWaitingError = 'Profile or batch not loaded.';
      notifyListeners();
      return _joinWaitingError;
    }

    _isJoiningWaiting = true;
    _joinWaitingError = null;
    notifyListeners();

    final result = await _returnBatchRepository.joinReturnWaiting(
      userId,
      batchId,
    );

    _isJoiningWaiting = false;
    if (result.isFailure) {
      _joinWaitingError = result.failure?.message;
      notifyListeners();
      return _joinWaitingError;
    }

    notifyListeners();
    return result.data;
  }
}
