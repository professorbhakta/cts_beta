import 'package:cts/appManager/app_class.dart';
import 'package:cts/features/batches/models/return_boarding_role_policy.dart';
import 'package:cts/features/batches/models/return_trip_log_placeholders.dart';
import 'package:cts/theme/cts_colors.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';

/// Return-trip boarding **scan** entry — visual shell matching morning
/// `BoardingScanScreen` (cream / navy chrome), without calling morning
/// `POST /d2d/boarding_scan/` or binding morning DTODLOG / CList.
///
/// TODO(Dock): when return trip log + **RCList** scan contract is in
/// `docs/API_CONTRACTS.md` gap-list, wire [ReturnBoardingRepository.scanReturnBoarding].
/// Do not invent camelCase fields. UI stays the same; variables update on schema lock.
class ReturnBoardingScanScreen extends StatelessWidget {
  const ReturnBoardingScanScreen({super.key, this.batchId});

  /// Optional batch context for future RCList binding.
  final String? batchId;

  @override
  Widget build(BuildContext context) {
    final role = SessionRole.userType;
    final allowed = ReturnBoardingRolePolicy.canScan(role);
    final scheme = context.scheme;
    final cts = context.cts;
    final theme = Theme.of(context);

    // Placeholder only — documents future RCList target without fake fields.
    final rclist = batchId == null || batchId!.isEmpty
        ? null
        : RclistRef(batchId: batchId!);

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHighest,
      appBar: AppBar(
        title: const Text('Scan return boarding QR'),
      ),
      body: !allowed
          ? const StatusMessage(
              icon: Icons.lock_outline,
              title: 'Scan not available',
              message: 'Staff and commuters scan the return boarding QR.',
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'RETURN TRIP',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cts.navy,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Same scan UX as morning',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: cts.navy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Camera scan will board into the future RCList once Dock '
                      'locks the return trip log contract. '
                      'Morning BoardingScanScreen remains morning-only.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cts.navy.withValues(alpha: 0.65),
                      ),
                    ),
                    if (rclist != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        // Identity handle only — not a wire field.
                        'RCList target batch #${rclist.batchId}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: cts.navy.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          border: Border.all(
                            color: cts.navy.withValues(alpha: 0.2),
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.qr_code_scanner,
                                  size: 72,
                                  color: cts.navy.withValues(alpha: 0.35),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Awaiting Dock scan contract',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: cts.navy,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'TODO: ReturnBoardingRepository.scanReturnBoarding '
                                  '→ return trip log / RCList. '
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
