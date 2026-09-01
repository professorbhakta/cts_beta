import 'package:cts/theme/cts_colors.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:cts/offline_temp/offline_auto_redirect.dart';
import 'package:cts/appManager/functions_and_tools.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/drivers/models/driver_model.dart';
import 'package:cts/features/drivers/providers/driver_home_provider.dart';
import 'package:cts/widgets/app_drawer.dart';
import 'package:cts/widgets/loading_indicator.dart';
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

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _formatBatchTime(String? batchTime) {
    if (batchTime == null || batchTime.isEmpty) return 'N/A';
    if (batchTime.length >= 5) return batchTime.substring(0, 5);
    return batchTime;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return OfflineAutoRedirect(
      child: Scaffold(
        backgroundColor: scheme.surfaceContainerHighest,
        drawer: const AppDrawer(),
        body: SafeArea(
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
      ),
    );
  }

  Widget _buildContent(BuildContext context, DriverHomeProvider provider) {
    final driverProfile = provider.driverProfile!;
    final adminMobile = driverProfile.adminCode?.userId?.mobileNumber;
    final batchId = driverProfile.batchId?.id;
    final driverName = driverProfile.userId?.username ?? 'Driver';

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 600 ? 20.0 : 16.0;

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            8,
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
                    _buildHeader(context, driverName),
                    const SizedBox(height: 16),
                    _buildAssignmentCard(context, driverProfile, adminMobile),
                    const SizedBox(height: 20),
                    _buildStartTripButton(context, batchId?.toString()),
                    if (batchId != null) ...[
                      const SizedBox(height: 12),
                      _buildReturnListButton(context, batchId.toString()),
                    ],
                    if (batchId == null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'No batch assigned yet. Contact admin if this looks wrong.',
                        textAlign: TextAlign.center,
                        style: context.texts.bodySmall?.copyWith(
                          color: context.scheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, String name) {
    final scheme = context.scheme;
    final cts = context.cts;
    final theme = context.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Menu',
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: Icon(Icons.menu_rounded, color: cts.navy),
            ),
            Text(
              'c2s',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: cts.navy,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                height: 1,
              ),
            ),
            const Spacer(),
            IconButton(
              tooltip: 'Profile',
              onPressed: () => context.push(RouteName.profileScreen),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              icon: CircleAvatar(
                radius: 18,
                backgroundColor: cts.navy,
                child: Icon(
                  Icons.person_rounded,
                  color: scheme.onSecondary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting(),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: cts.navy.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: cts.navy,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAssignmentCard(
    BuildContext context,
    DriverModel driverProfile,
    String? adminMobile,
  ) {
    final cts = context.cts;
    final scheme = context.scheme;
    final theme = context.theme;
    final batchName = driverProfile.batchId?.batchName ?? 'No batch assigned';
    final startTime = _formatBatchTime(driverProfile.batchId?.batchTime);
    final cabNumber = driverProfile.cabId?.regNumber ?? 'N/A';
    final dateLabel = DateFormat.yMMMEd().format(DateTime.now());

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
      decoration: BoxDecoration(
        color: cts.navy,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: cts.yellow,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  'READY',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const Spacer(),
              if (adminMobile != null && adminMobile.isNotEmpty)
                IconButton(
                  tooltip: 'Call admin',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  onPressed: () => calling(adminMobile),
                  icon: Icon(
                    Icons.call_rounded,
                    color: scheme.onSecondary.withValues(alpha: 0.85),
                    size: 18,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            batchName,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: scheme.onSecondary,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            dateLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSecondary.withValues(alpha: 0.78),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          _assignmentMetaRow(
            context,
            label: 'Start',
            value: startTime,
          ),
          const SizedBox(height: 8),
          _assignmentMetaRow(
            context,
            label: 'Cab',
            value: cabNumber,
          ),
        ],
      ),
    );
  }

  Widget _assignmentMetaRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final scheme = context.scheme;
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.onSecondary.withValues(alpha: 0.65),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.onSecondary,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStartTripButton(BuildContext context, String? batchId) {
    final cts = context.cts;
    final scheme = context.scheme;
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: batchId == null
            ? null
            : () => context.push('${RouteName.d2dLog}/$batchId'),
        style: FilledButton.styleFrom(
          backgroundColor: cts.yellow,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: cts.yellow.withValues(alpha: 0.45),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          'START TRIP',
          style: theme.textTheme.titleMedium?.copyWith(
            color: scheme.onPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }

  Widget _buildReturnListButton(BuildContext context, String batchId) {
    final cts = context.cts;
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => context.push(
          '${RouteName.driverReturnCommuter}/$batchId',
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: cts.navy,
          side: BorderSide(color: cts.navy.withValues(alpha: 0.45), width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          'RETURN LIST',
          style: theme.textTheme.titleSmall?.copyWith(
            color: cts.navy,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}
