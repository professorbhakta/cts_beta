import 'package:cts/features/trip_report/helpers/trip_report_review.dart';
import 'package:cts/features/trip_report/repositories/trip_report_repository.dart';
import 'package:flutter/foundation.dart';

/// Loads today's trip_report once for Admin/Supervisor home banner (Path A).
class TripReviewAlertProvider with ChangeNotifier {
  TripReviewAlertProvider(this._repository);

  final TripReportRepository _repository;

  bool _loading = false;
  bool get loading => _loading;

  bool _needsReview = false;
  bool get needsReview => _needsReview;

  String? _dateIso;
  String? get dateIso => _dateIso;

  static String formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${y}-${m}-${day}';
  }

  Future<void> loadToday({DateTime? now}) async {
    _loading = true;
    notifyListeners();

    final when = now ?? DateTime.now();
    _dateIso = formatDate(when);
    final result = await _repository.fetchReport(date: _dateIso!);
    if (result.isSuccess) {
      _needsReview = tripReportNeedsEndKmReview(result.data);
    } else {
      // Silent fail for home banner — report screen still works.
      _needsReview = false;
    }

    _loading = false;
    notifyListeners();
  }
}
