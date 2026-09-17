import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/trip_report/models/trip_report_models.dart';
import 'package:cts/features/trip_report/repositories/trip_report_repository.dart';
import 'package:flutter/foundation.dart';

class TripReportProvider with ChangeNotifier {
  TripReportProvider(this._repository);

  final TripReportRepository _repository;

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _saving = false;
  bool get saving => _saving;

  String? _editError;
  String? get editError => _editError;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  TripReportResponse? _report;
  TripReportResponse? get report => _report;
  List<TripReportBatchItem> get items => _report?.items ?? const [];

  static String formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  String get selectedDateIso => formatDate(_selectedDate);

  Future<void> load({DateTime? date}) async {
    if (date != null) {
      _selectedDate = DateTime(date.year, date.month, date.day);
    }
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.fetchReport(date: selectedDateIso);
    if (result.isSuccess) {
      _report = result.data;
      _state = ViewState.success;
      _errorMessage = null;
    } else {
      _state = ViewState.error;
      _errorMessage = result.failure?.message ?? 'Failed to load trip report';
    }
    notifyListeners();
  }

  Future<void> setDate(DateTime date) => load(date: date);

  Future<bool> editEndKm({
    required String batchId,
    required TripReportLegKind leg,
    required int endKm,
  }) async {
    _saving = true;
    _editError = null;
    notifyListeners();

    final result = await _repository.editEndKm(
      batchId: batchId,
      leg: leg,
      endKm: endKm,
      date: selectedDateIso,
    );

    _saving = false;
    if (result.isFailure) {
      _editError = result.failure?.message ?? 'Failed to edit end_km';
      notifyListeners();
      return false;
    }

    notifyListeners();
    await load();
    return true;
  }

  void clearEditError() {
    if (_editError == null) return;
    _editError = null;
    notifyListeners();
  }
}
