import 'package:cts/theme/cts_colors.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:cts/offline_temp/offline_auto_redirect.dart';
import 'package:cts/appManager/functions_and_tools.dart';
import 'package:cts/appManager/view_state.dart';
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
    if (batchTime == null || batchTime.isEmpty) return '—';
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
                  _ => _buildBoard(context, provider),
                };
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryActions(
    BuildContext context,
    DriverHomeProvider provider,
  ) {
    final cts = context.cts;
    final scheme = context.scheme;
    final theme = Theme.of(context);
    final batchId = provider.driverProfile?.batchId?.id?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: Material(
            color: cts.yellow,
            child: InkWell(
              onTap: batchId == null
                  ? null
                  : () => context.push('${RouteName.d2dLog}/$batchId'),
              child: Center(
                child: Text(
                  'START TRIP',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (batchId != null)
          SizedBox(
            width: double.infinity,
            height: 44,
            child: InkWell(
              onTap: () => context.push(
                '${RouteName.driverReturnCommuter}/$batchId',
              ),
              child: Center(
                child: Text(
                  'RETURN LIST',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: cts.navy,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
          ),
      ],
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
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
          child: Text(
            '${_greeting()}, $name',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cts.navy.withValues(alpha: 0.65),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBoard(BuildContext context, DriverHomeProvider provider) {
    final driverProfile = provider.driverProfile!;
    final cts = context.cts;
    final theme = context.theme;
    final adminMobile = driverProfile.adminCode?.userId?.mobileNumber;
    final batchId = driverProfile.batchId?.id;
    final driverName = driverProfile.userId?.username ?? 'Driver';
    final time = _formatBatchTime(driverProfile.batchId?.batchTime);
    final batchName = driverProfile.batchId?.batchName ?? 'No batch assigned';
    final cabNumber = driverProfile.cabId?.regNumber ?? 'N/A';
    final dateLabel = DateFormat.yMMMEd().format(DateTime.now());

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 600 ? 24.0 : 20.0;

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            4,
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
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Text(
                          'READY',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cts.navy.withValues(alpha: 0.55),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          dateLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cts.navy.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: cts.navy,
                        fontSize: 72,
                        fontWeight: FontWeight.w500,
                        height: 0.95,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        letterSpacing: -1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      batchName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: cts.navy,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Cab $cabNumber',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cts.navy.withValues(alpha: 0.65),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        if (adminMobile != null && adminMobile.isNotEmpty)
                          IconButton(
                            tooltip: 'Call admin',
                            visualDensity: VisualDensity.compact,
                            onPressed: () => calling(adminMobile),
                            icon: Icon(Icons.call, color: cts.navy, size: 18),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildPrimaryActions(context, provider),
                    if (batchId == null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'No batch assigned yet. Contact admin if this looks wrong.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cts.navy.withValues(alpha: 0.55),
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
}
