import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/admin_bootstrap/models/admin_bootstrap_response.dart';
import 'package:cts/features/admin_bootstrap/repositories/admin_bootstrap_repository.dart';
import 'package:flutter/foundation.dart';

/// Provider-only (no Riverpod). No UI screen — sync after login / on demand.
class AdminBootstrapProvider with ChangeNotifier {
  AdminBootstrapProvider(this._repository);

  final AdminBootstrapRepository _repository;

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AdminBootstrapResponse? _last;
  AdminBootstrapResponse? get last => _last;

  bool get hasSynced => _last != null;

  Future<void> sync() async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.sync();
    if (result.isSuccess) {
      _last = result.data;
      _state = ViewState.success;
    } else {
      _errorMessage = result.failure?.message;
      _state = ViewState.error;
    }
    notifyListeners();
  }

  Future<void> hydrateFromCache() async {
    _last = await _repository.readCachedMeta();
    notifyListeners();
  }

  Future<void> clearLocal() async {
    await _repository.clearLocal();
    _last = null;
    _state = ViewState.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
