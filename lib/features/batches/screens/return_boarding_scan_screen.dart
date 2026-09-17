import 'package:cts/features/d2d/screens/boarding_scan_screen.dart';
import 'package:flutter/material.dart';

/// Return-trip boarding **scan** — same `POST /d2d/boarding_scan/` as morning.
///
/// Token from return mint (`?trip=return`) carries leg `return` and boards into
/// RCList on the return trip log. No FE archive UI.
class ReturnBoardingScanScreen extends StatelessWidget {
  const ReturnBoardingScanScreen({super.key, this.batchId});

  /// Optional batch context (routing / future live list); scan API uses token only.
  final String? batchId;

  @override
  Widget build(BuildContext context) {
    return const BoardingScanScreen(
      title: 'Scan return boarding QR',
      hint:
          'Scan to board the return trip. Waiting line is via return batch '
          'Join waiting — not this QR scan.',
      allowJoinWaiting: false,
    );
  }
}
