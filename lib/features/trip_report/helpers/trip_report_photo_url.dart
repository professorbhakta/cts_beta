import 'package:cts/api/api_list.dart';
import 'package:cts/features/trip_report/models/trip_report_models.dart';

/// Resolves an odometer photo URL for trip report thumbnails.
///
/// Prefer wire field **A** (`start_photo_url` / `end_photo_url`) when non-null /
/// non-empty; otherwise build interim fallback **B** via
/// [ApiUrl.odometerPhoto] from [batchId] + [leg] + [kind].
///
/// Returns `null` only when neither A nor B can be formed (e.g. empty batch id).
String? resolveTripReportPhotoUrl({
  String? wirePhotoUrl,
  required String batchId,
  required TripReportLegKind leg,
  required String kind,
}) {
  final a = wirePhotoUrl?.trim();
  if (a != null && a.isNotEmpty && a.toLowerCase() != 'null') {
    return a;
  }
  final b = batchId.trim();
  final k = kind.trim().toLowerCase();
  if (b.isEmpty || k.isEmpty) return null;
  if (k != 'start' && k != 'end') return null;
  return ApiUrl.odometerPhoto(b, leg.apiValue, k);
}
