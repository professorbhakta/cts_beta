import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/batches/domain/repositories/return_batch_repository.dart';
import 'package:cts/features/commuters/domain/models/commuter_model.dart';
import 'package:flutter/foundation.dart';

class ReturnBatchProvider with ChangeNotifier {
  final ReturnBatchRepository _repository;

  ReturnBatchProvider(this._repository);

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<CommuterModel> _returnCommuters = [];
  List<CommuterModel> get returnCommuters => _returnCommuters;

  List<CommuterModel> _confirmedCommuters = [];
  List<CommuterModel> get confirmedCommuters => _confirmedCommuters;

  Future<void> fetchReturnCommuters(String batchId) async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getReturnCommuters(batchId);

    if (result.isSuccess) {
      _returnCommuters = result.data ?? [];
      _state = ViewState.success;
    } else {
      _errorMessage = result.failure?.message;
      _state = ViewState.error;
    }
    notifyListeners();
  }

  Future<void> fetchConfirmedCommuters(String batchId) async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getConfirmedCommuters(batchId);

    if (result.isSuccess) {
      _confirmedCommuters = result.data ?? [];
      _state = ViewState.success;
    } else {
      _errorMessage = result.failure?.message;
      _state = ViewState.error;
    }
    notifyListeners();
  }

  Future<bool> addCommuterToConfirmList(
    String commuterId,
    String batchId,
  ) async {
    final result = await _repository.addCommuterToConfirmList(
      commuterId,
      batchId,
    );
    if (result.isSuccess) {
      return true;
    } else {
      _errorMessage = result.failure?.message;
      notifyListeners();
      return false;
    }
  }
}
