import 'package:cts/appManager/view_state.dart';
import 'package:cts/domain/repositories/authentication_repository.dart';
import 'package:flutter/material.dart';

class SignInProvider with ChangeNotifier {
  final AuthenticationRepository _authRepository;

  SignInProvider(this._authRepository);

  final mobileCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _userType;
  String? get userType => _userType;

  Future<void> login() async {
    _state = ViewState.loading;
    _errorMessage = null;
    _userType = null;
    notifyListeners();

    final result = await _authRepository.login(
      mobileNumber: mobileCtrl.text,
      password: passwordCtrl.text,
    );

    if (result.isSuccess) {
      _state = ViewState.success;
      _userType = result.data;
    } else {
      _errorMessage = result.failure?.message;
      _state = ViewState.error;
    }
    notifyListeners();
  }

  Future<void> logout() async {
    _state = ViewState.loading;
    notifyListeners();

    final result = await _authRepository.logout();

    if (result.isSuccess) {
      _state = ViewState.idle;
    } else {
      _errorMessage = result.failure?.message;
      _state = ViewState.error;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    mobileCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }
}

class SignUpProvider with ChangeNotifier {
  final AuthenticationRepository _authRepository;

  SignUpProvider(this._authRepository);

  final nameCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> signUp() async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.signUp(
      username: nameCtrl.text,
      mobileNumber: mobileCtrl.text,
      password: passwordCtrl.text,
    );

    if (result.isSuccess) {
      _state = ViewState.success;
    } else {
      _errorMessage = result.failure?.message;
      _state = ViewState.error;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    mobileCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }
}

