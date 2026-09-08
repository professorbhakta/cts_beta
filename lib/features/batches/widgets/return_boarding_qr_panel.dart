import 'package:cts/features/batches/models/return_trip_log_placeholders.dart';
import 'package:cts/theme/cts_colors.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Return-trip boarding QR chrome — **visual parity** with morning
/// `BoardingQrPanel` (cream board, navy QR, compact hero).
///
/// Does **not** call morning `D2dRepository.getBoardingQr` and does **not**
/// bind to morning DTODLOG `return_*` columns.
///
/// TODO(Dock): when return trip log + RCList contract lands (see
/// `docs/setup/RETURN_QR_UI_PREP.md` + `docs/API_CONTRACTS.md` gap-list),
/// feed [viewModel.qrPayload] from [ReturnBoardingRepository].
/// RCList = user-ID list on the return trip log row (like CList), not
/// row-per-rider; live UI binds that ID list. Do not invent camelCase wire fields.
class ReturnBoardingQrPanel extends StatelessWidget {
  const ReturnBoardingQrPanel({
    super.key,
    required this.batchId,
    this.enabled = true,
    this.compact = true,
    this.viewModel,
  });

  final String batchId;

  /// When false, clears QR chrome.
  final bool enabled;

  /// Matches morning driver live compact hero QR.
  final bool compact;

  /// Optional prep binding. Null or null [qrPayload] → await-Dock stub.
  final ReturnBoardingQrViewModel? viewModel;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return const SizedBox.shrink();

    final payload = viewModel?.qrPayload?.trim() ?? '';
    if (payload.isEmpty) {
      return _ReturnQrAwaitingContractStub(compact: compact);
    }

    // Visual reuse of morning QR face (same qr_flutter chrome / navy ink).
    return _ReturnQrFace(payload: payload, compact: compact);
  }
}

/// Presentation-only QR face — mirrors morning compact/legacy card layout.
class _ReturnQrFace extends StatelessWidget {
  const _ReturnQrFace({required this.payload, required this.compact});

  final String payload;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final cts = context.cts;
    final theme = Theme.of(context);
    final hairline = cts.navy.withValues(alpha: 0.2);

    final qr = LayoutBuilder(
      builder: (context, constraints) {
        final size = compact
            ? (constraints.maxWidth * 0.94).clamp(240.0, 340.0)
            : 220.0;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surface,
            border: Border.all(color: hairline),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: QrImageView(
              data: payload,
              version: QrVersions.auto,
              size: size - 32,
              backgroundColor: scheme.surface,
              eyeStyle: QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: cts.navy,
              ),
              dataModuleStyle: QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: cts.navy,
              ),
            ),
          ),
        );
      },
    );

    if (compact) return qr;

    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            const SizedBox(height: 4),
            Text(
              'Commuters scan this code to board. Same UX as morning.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cts.navy.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 12),
            Center(child: qr),
          ],
        ),
      ),
    );
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
                  'Same UX as morning. Binds to future return trip log + RCList '
                  '(user-ID list on log row, like CList). '
                  'See docs/setup/RETURN_QR_UI_PREP.md.',
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
