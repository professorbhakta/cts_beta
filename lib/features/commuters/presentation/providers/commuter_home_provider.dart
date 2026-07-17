import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/commuters/domain/repositories/commuter_repository.dart';
import 'package:cts/features/commuters/domain/models/commuter_model.dart';
import 'package:flutter/material.dart';

class CommuterHomeProvider with ChangeNotifier {
  final CommuterRepository _commuterRepository;

  CommuterHomeProvider(this._commuterRepository);

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  CommuterModel? _commuterProfile;
  CommuterModel? get commuterProfile => _commuterProfile;

  bool _isUpdating = false;
  bool get isUpdating => _isUpdating;

  Future<void> fetchCommuterProfile() async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _commuterRepository.getCommuterProfile();

    if (result.isSuccess) {
      _commuterProfile = result.data;
      _state = ViewState.success;
    } else {
      _errorMessage = result.failure?.message;
      _state = ViewState.error;
    }
    notifyListeners();
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
    } else {
      _errorMessage = result.failure?.message;
    }

    _isUpdating = false;
    notifyListeners();
    return result.isSuccess;
  }
}
