import 'package:cts/features/d2d/widgets/boarding_qr_panel.dart';
import 'package:cts/theme/cts_colors.dart';
import 'package:flutter/material.dart';

/// Return-trip boarding QR chrome — **reuses** morning [BoardingQrPanel].
///
/// Product lock: evening trip uses the **same** QR boarding flow as morning.
/// Until Dock green-flags BE, keep [useLiveMorningApi] `false` so we do not
/// hit morning `GET /d2d/boarding_qr/<batch_id>/` against a return-only trip.
///
/// TODO(Dock): when contract confirms shared morning boarding endpoints (see
/// `docs/API_CONTRACTS.md` · client pack QR + `lib/features/d2d/repositories/
/// d2d_repository.dart` `getBoardingQr`), set [useLiveMorningApi] true at the
/// call site. Do **not** invent parallel return-QR URLs or camelCase fields.
class ReturnBoardingQrPanel extends StatelessWidget {
  const ReturnBoardingQrPanel({
    super.key,
    required this.batchId,
    this.enabled = true,
    this.compact = true,
    this.useLiveMorningApi = false,
  });

  final String batchId;

  /// When false, clears live QR / shows stub only.
  final bool enabled;

  /// Matches morning driver live compact hero QR.
  final bool compact;

  /// Wire to morning [BoardingQrPanel] → `D2dRepository.getBoardingQr`.
  /// Default false until Dock green-flags return reuse of morning APIs.
  final bool useLiveMorningApi;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return const SizedBox.shrink();

    if (useLiveMorningApi) {
      return BoardingQrPanel(
        batchId: batchId,
        enabled: enabled,
        compact: compact,
      );
    }

    return _ReturnQrAwaitingContractStub(compact: compact);
  }
}

/// Cream-board placeholder — same visual language as morning QR card, no network.
class _ReturnQrAwaitingContractStub extends StatelessWidget {
  const _ReturnQrAwaitingContractStub({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final cts = context.cts;
    final theme = Theme.of(context);
    final hairline = cts.navy.withValues(alpha: 0.2);

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!compact) ...[
          Row(
            children: [
              Icon(Icons.qr_code_2, color: cts.navy),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Return boarding QR',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cts.navy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surface,
            border: Border.all(color: hairline),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: compact ? 48 : 32,
              horizontal: 16,
            ),
            child: Column(
              children: [
                Icon(
                  Icons.qr_code_2_outlined,
                  size: compact ? 72 : 56,
                  color: cts.navy.withValues(alpha: 0.35),
                ),
                const SizedBox(height: 12),
                Text(
                  'Awaiting Dock boarding contract',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: cts.navy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Same UX as morning. Reuses BoardingQrPanel when live API '
                  'is enabled. See docs/setup/RETURN_QR_UI_PREP.md.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cts.navy.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (compact) return body;

    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: body,
      ),
    );
  }
}
