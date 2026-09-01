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
              icon: Icon(Icons.menu, color: cts.navy),
            ),
            Text(
              'c2s',
              style: theme.textTheme.titleLarge?.copyWith(
                color: cts.navy,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
                height: 1,
              ),
            ),
            const Spacer(),
            IconButton(
              tooltip: 'Profile',
              onPressed: () => context.push(RouteName.profileScreen),
              icon: Icon(Icons.person_outline, color: cts.navy, size: 22),
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
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cts.navy.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: cts.navy,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: BoxDecoration(
        color: cts.navy,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'READY',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSecondary.withValues(alpha: 0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
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
                    Icons.call,
                    color: scheme.onSecondary.withValues(alpha: 0.75),
                    size: 18,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            batchName,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: scheme.onSecondary,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            dateLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSecondary.withValues(alpha: 0.78),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 14),
          _assignmentMetaRow(
            context,
            label: 'START',
            value: startTime,
          ),
          const SizedBox(height: 8),
          _assignmentMetaRow(
            context,
            label: 'CAB',
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
          width: 56,
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSecondary.withValues(alpha: 0.65),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.onSecondary,
              fontWeight: FontWeight.w600,
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
      height: 44,
      child: FilledButton(
        onPressed: batchId == null
            ? null
            : () => context.push('${RouteName.d2dLog}/$batchId'),
        style: FilledButton.styleFrom(
          backgroundColor: cts.yellow,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: cts.yellow.withValues(alpha: 0.45),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Text(
          'START TRIP',
          style: theme.textTheme.titleSmall?.copyWith(
            color: scheme.onPrimary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
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
      height: 44,
      child: OutlinedButton(
        onPressed: () => context.push(
          '${RouteName.driverReturnCommuter}/$batchId',
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: cts.navy,
          side: BorderSide(color: cts.navy.withValues(alpha: 0.4)),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Text(
          'RETURN LIST',
          style: theme.textTheme.titleSmall?.copyWith(
            color: cts.navy,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}
