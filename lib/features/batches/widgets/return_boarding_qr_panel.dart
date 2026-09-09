import 'package:cts/api/api_list.dart';
import 'package:cts/features/d2d/widgets/boarding_qr_panel.dart';
import 'package:flutter/material.dart';

/// Return-trip boarding QR — wraps morning [BoardingQrPanel] with
/// `?trip=return` mint (Dock Phase 2).
///
/// Binds to return trip log / RCList via BE token + `return_trip_id` — **not**
/// morning DTODLOG `return_*` columns. See docs/setup/RETURN_TRIP_API_GAP.md.
class ReturnBoardingQrPanel extends StatelessWidget {
  const ReturnBoardingQrPanel({
    super.key,
    required this.batchId,
    this.enabled = true,
    this.compact = true,
  });

  final String batchId;
  final bool enabled;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return BoardingQrPanel(
      batchId: batchId,
      enabled: enabled,
      compact: compact,
      trip: ApiUrl.boardingTripReturn,
    );
  }
}
