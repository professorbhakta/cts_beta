import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/edit_history/models/edit_record_models.dart';
import 'package:cts/features/edit_history/repositories/edit_history_repository.dart';
import 'package:flutter/foundation.dart';

class EditHistoryProvider with ChangeNotifier {
  EditHistoryProvider(this._repository);

  final EditHistoryRepository _repository;

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  DateTime? _selectedDate = DateTime.now();
  DateTime? get selectedDate => _selectedDate;

  String _userIdFilter = '';
  String get userIdFilter => _userIdFilter;

  String _pathFilter = 'edit_end_km';
  String get pathFilter => _pathFilter;

  EditRecordListResponse? _response;
  EditRecordListResponse? get response => _response;
  List<EditRecordItem> get items => _response?.items ?? const [];

  static String formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  String? get selectedDateIso =>
      _selectedDate == null ? null : formatDate(_selectedDate!);

  void setDate(DateTime? date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setUserIdFilter(String raw) {
    _userIdFilter = raw.trim();
    notifyListeners();
  }

  void setPathFilter(String raw) {
    _pathFilter = raw.trim();
    notifyListeners();
  }

  Future<void> load() async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    int? userId;
    if (_userIdFilter.isNotEmpty) {
      userId = int.tryParse(_userIdFilter);
      if (userId == null) {
        _state = ViewState.error;
        _errorMessage = 'user id must be an integer';
        notifyListeners();
        return;
      }
    }

    final result = await _repository.fetchRecords(
      date: selectedDateIso,
      userId: userId,
      path: _pathFilter.isEmpty ? null : _pathFilter,
    );
    if (result.isSuccess) {
      _response = result.data;
      _state = ViewState.success;
    } else {
      _errorMessage = result.failure?.message ?? 'Failed to load edit history';
      _state = ViewState.error;
    }
    notifyListeners();
  }
}
