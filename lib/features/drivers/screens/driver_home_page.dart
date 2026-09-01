import 'package:cts/theme/cts_colors.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:cts/offline_temp/offline_auto_redirect.dart';
import 'package:cts/appManager/functions_and_tools.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/drivers/models/driver_model.dart';
import 'package:cts/features/drivers/providers/driver_home_provider.dart';
import 'package:cts/widgets/brand_app_bar.dart';
import 'package:cts/widgets/loading_indicator.dart';
import 'package:cts/widgets/role_bottom_nav.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  static const double _maxContentWidth = 720;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverHomeProvider>().fetchDriverProfile();
    });
  }

  String _formatBatchTime(String? batchTime) {
    if (batchTime == null || batchTime.isEmpty) return 'N/A';
    if (batchTime.length >= 5) return batchTime.substring(0, 5);
    return batchTime;
  }

  void _openReturnList(String? batchId) {
    if (batchId == null) return;
    context.push('${RouteName.driverReturnCommuter}/$batchId');
  }

  @override
  Widget build(BuildContext context) {
    return OfflineAutoRedirect(
      child: Scaffold(
        appBar: const BrandAppBar(automaticallyImplyLeading: false),
        body: SafeArea(
          top: false,
          child: RefreshIndicator(
            onRefresh: () =>
                context.read<DriverHomeProvider>().fetchDriverProfile(),
            child: Consumer<DriverHomeProvider>(
              builder: (context, provider, child) {
                return switch (provider.state) {
                  ViewState.loading => ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 200, child: LoadingIndicator()),
                      ],
                    ),
                  ViewState.error => ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        StatusMessage.error(
                          title: provider.errorMessage ?? 'An error occurred',
                          onRetry: () => provider.fetchDriverProfile(),
                        ),
                      ],
                    ),
                  _ when provider.driverProfile == null => ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        StatusMessage(
                          icon: Icons.assignment_outlined,
                          title: 'No assignment details found.',
                          message: 'Pull to refresh.',
                        ),
                      ],
                    ),
                  _ => _buildContent(context, provider),
                };
              },
            ),
          ),
        ),
        bottomNavigationBar: Consumer<DriverHomeProvider>(
          builder: (context, provider, _) {
            final batchId = provider.driverProfile?.batchId?.id?.toString();
            return RoleBottomNav(
              selected: RoleBottomNavTab.home,
              onReturnList: batchId == null
                  ? null
                  : () => _openReturnList(batchId),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, DriverHomeProvider provider) {
    final driverProfile = provider.driverProfile!;
    final adminMobile = driverProfile.adminCode?.userId?.mobileNumber;
    final batchId = driverProfile.batchId?.id?.toString();
    final driverName = driverProfile.userId?.username ?? 'Driver';

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 600 ? 20.0 : 16.0;

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            16,
            horizontalPadding,
            24,
          ),
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Hi, $driverName',
                      style: context.theme.textTheme.titleMedium?.copyWith(
                        color: context.scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat.yMMMEd().format(DateTime.now()),
                      style: context.theme.textTheme.bodySmall?.copyWith(
                        color: context.scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAssignmentHero(
                      context,
                      driverProfile,
                      adminMobile,
                      batchId,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAssignmentHero(
    BuildContext context,
    DriverModel driverProfile,
    String? adminMobile,
    String? batchId,
  ) {
    final scheme = context.scheme;
    final cts = context.cts;
    final theme = context.theme;
    final batchName = driverProfile.batchId?.batchName ?? 'No batch assigned';
    final startTime = _formatBatchTime(driverProfile.batchId?.batchTime);
    final cabNumber = driverProfile.cabId?.regNumber ?? 'N/A';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cts.navy,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cts.navy.withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.onSecondary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  batchName,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              if (adminMobile != null && adminMobile.isNotEmpty)
                IconButton(
                  tooltip: 'Call admin',
                  onPressed: () => calling(adminMobile),
                  style: IconButton.styleFrom(
                    foregroundColor: scheme.onSecondary,
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.call_rounded, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Today\'s assignment',
            style: theme.textTheme.titleLarge?.copyWith(
              color: scheme.onSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          _detailRow(
            context,
            icon: Icons.access_time_rounded,
            label: 'Start',
            value: startTime,
          ),
          const SizedBox(height: 10),
          _detailRow(
            context,
            icon: Icons.directions_car_rounded,
            label: 'Cab',
            value: cabNumber,
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: batchId != null
                ? () => context.push('${RouteName.d2dLog}/$batchId')
                : null,
            icon: Icon(Icons.play_arrow_rounded, color: scheme.onPrimary),
            label: Text(
              'START TRIP',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: scheme.onPrimary,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              disabledBackgroundColor:
                  scheme.primary.withValues(alpha: 0.35),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          if (batchId != null) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _openReturnList(batchId),
              icon: Icon(
                Icons.assignment_return_outlined,
                color: scheme.onSecondary,
              ),
              label: Text(
                'RETURN LIST',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.onSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: scheme.onSecondary.withValues(alpha: 0.45),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            Text(
              'No batch assigned yet. Contact admin if this looks wrong.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSecondary.withValues(alpha: 0.75),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final scheme = context.scheme;
    final theme = context.theme;
    return Row(
      children: [
        Icon(icon, color: scheme.onSecondary.withValues(alpha: 0.85), size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSecondary.withValues(alpha: 0.7),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.onSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
