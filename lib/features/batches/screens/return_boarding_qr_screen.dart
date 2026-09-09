import 'package:cts/appManager/app_class.dart';
import 'package:cts/features/batches/models/return_boarding_role_policy.dart';
import 'package:cts/features/batches/widgets/return_boarding_qr_panel.dart';
import 'package:cts/theme/cts_colors.dart';
import 'package:cts/widgets/app_drawer.dart';
import 'package:cts/widgets/brand_app_bar.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';

/// Driver/admin-like **show** screen for return-trip boarding QR.
///
/// Cream-board layout. Mints via `GET …/boarding_qr/<batch>/?trip=return`
/// (return trip log / RCList) — not morning DTODLOG `return_*`.
class ReturnBoardingQrScreen extends StatelessWidget {
  const ReturnBoardingQrScreen({
    super.key,
    required this.batchId,
  });

  final String batchId;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final cts = context.cts;
    final theme = Theme.of(context);
    final role = SessionRole.userType;
    final allowed = ReturnBoardingRolePolicy.canShowQr(role);

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHighest,
      appBar: const BrandAppBar(),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: !allowed
            ? const StatusMessage(
                icon: Icons.lock_outline,
                title: 'Boarding QR not available',
                message:
                    'Only drivers (and admin/supervisor monitors) can show the return boarding QR.',
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final maxW =
                      constraints.maxWidth >= 720 ? 520.0 : double.infinity;
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxW),
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
                              const SizedBox(height: 6),
                              Text(
                                'Boarding QR',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: cts.navy,
                                  fontWeight: FontWeight.w700,
                                  height: 1.15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Commuters scan this code to board — same flow as morning.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cts.navy.withValues(alpha: 0.55),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Batch #$batchId',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: cts.navy.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ReturnBoardingQrPanel(
                                batchId: batchId,
                                compact: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
