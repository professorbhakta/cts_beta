import 'package:cts/features/trip_report/models/trip_report_month_models.dart';
import 'package:cts/features/trip_report/repositories/trip_report_repository.dart';
import 'package:flutter/foundation.dart';

/// One day that needs Admin/Supervisor review (from month index flags).
class TripAttentionItem {
  const TripAttentionItem({
    required this.date,
    this.anyIncomplete = false,
    this.anyAutoClosed = false,
    this.anyEdited = false,
  });

  final String date;
  final bool anyIncomplete;
  final bool anyAutoClosed;
  final bool anyEdited;

  factory TripAttentionItem.fromMonthDay(TripReportMonthDay day) {
    return TripAttentionItem(
      date: day.date,
      anyIncomplete: day.anyIncomplete,
      anyAutoClosed: day.anyAutoClosed,
      anyEdited: day.anyEdited,
    );
  }
}

/// Step 4 attention inbox + Path A today banner — client-derive from month index.
/// No FCM. Feeds Admin/Supervisor home list/badge.
class TripReviewAlertProvider with ChangeNotifier {
  TripReviewAlertProvider(this._repository);

  final TripReportRepository _repository;

  bool _loading = false;
  bool get loading => _loading;

  /// Path A: today has incomplete/auto_closed (from month flags).
  bool _needsReview = false;
  bool get needsReview => _needsReview;

  String? _dateIso;
  String? get dateIso => _dateIso;

  List<TripAttentionItem> _inbox = const [];
  List<TripAttentionItem> get inbox => _inbox;

  int get badgeCount => _inbox.length;

  static String formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${y}-${m}-${day}';
  }

  /// Loads current + previous month indexes; builds flagged-day inbox.
  Future<void> loadToday({DateTime? now}) async {
    await loadAttention(now: now);
  }

  Future<void> loadAttention({DateTime? now}) async {
    _loading = true;
    notifyListeners();

    final when = now ?? DateTime.now();
    _dateIso = formatDate(when);

    final months = <(int, int)>[
      (when.year, when.month),
      _prevMonth(when.year, when.month),
    ];

    final flagged = <TripAttentionItem>[];
    for (final (y, m) in months) {
      final result = await _repository.fetchMonth(year: y, month: m);
      if (!result.isSuccess || result.data == null) continue;
      for (final day in result.data!.days) {
        if (day.anyIncomplete || day.anyAutoClosed || day.anyEdited) {
          flagged.add(TripAttentionItem.fromMonthDay(day));
        }
      }
    }

    flagged.sort((a, b) => b.date.compareTo(a.date));
    _inbox = flagged;
    // Path A banner: today incomplete or auto_closed (edited alone stays in list).
    final today = flagged.where((i) => i.date == _dateIso).toList();
    if (today.isEmpty) {
      _needsReview = false;
    } else {
      final row = today.first;
      _needsReview = row.anyIncomplete || row.anyAutoClosed;
    }

    _loading = false;
    notifyListeners();
  }

  static (int, int) _prevMonth(int year, int month) {
    if (month <= 1) return (year - 1, 12);
    return (year, month - 1);
  }
}
