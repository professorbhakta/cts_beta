import 'package:cts/appManager/app_class.dart';
import 'package:cts/theme/cts_colors.dart';
import 'package:cts/offline_temp/offline_auto_redirect.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/admin_home/providers/admin_provider.dart';
import 'package:cts/features/batches/models/batch_model.dart';
import 'package:cts/features/batches/providers/batch_form_provider.dart';
import 'package:cts/features/cabs/providers/cab_form_provider.dart';
import 'package:cts/features/commuters/providers/commuter_form_provider.dart';
import 'package:cts/features/drivers/providers/driver_form_provider.dart';
import 'package:cts/features/pops/providers/pop_form_provider.dart';
import 'package:cts/features/routes/providers/route_form_provider.dart';
import 'package:cts/utils/sort_utils.dart';
import 'package:cts/widgets/dashboard_shell.dart';
import 'package:cts/widgets/dashboard_stat_card.dart'
    show CompactStatCard;
import 'package:cts/widgets/cts_brand_logo.dart';
import 'package:cts/widgets/quick_action_button.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AdminProvider>().state != ViewState.loading) {
        context.read<AdminProvider>().loadDetailedDashboardData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cts = context.cts;
    final theme = Theme.of(context);

    return OfflineAutoRedirect(
      child: DashboardShell(
        title: 'c2s',
        quietBrandAppBar: true,
        titleWidget: Text(
          'c2s',
          style: theme.textTheme.titleLarge?.copyWith(
            color: cts.navy,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            height: 1,
          ),
        ),
        child: Consumer<AdminProvider>(
          builder: (context, provider, child) {
            switch (provider.state) {
              case ViewState.loading:
                return _buildDashboardSkeleton(context);
              case ViewState.error:
                return StatusMessage.error(
                  title:
                      provider.errorMessage ?? 'Failed to load dashboard data.',
                  message: 'Please check your connection and try again.',
                  onRetry: () => provider.loadDetailedDashboardData(),
                );
              case ViewState.success:
              case ViewState.idle:
                return _buildDashboard(context, provider);
            }
          },
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, AdminProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.loadDetailedDashboardData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (provider.hasPartialError) ...[
              _buildPartialLoadBanner(context, provider),
              const SizedBox(height: 16),
            ],
            _buildGreetingSection(context),
            const SizedBox(height: 28),
            _buildRunningBatchesSection(context, provider),
            const SizedBox(height: 28),
            _buildOverviewSection(context, provider),
            const SizedBox(height: 28),
            _buildQuickActionsSection(context),
          ],
        ),
      ),
    );
  }

  String _timeOfDayGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  /// Same source as the admin drawer header.
  String _displayUserName() {
    final name = AppManager.instance.getString(ManagerKey.name);
    final userName = AppManager.instance.getString(ManagerKey.userName);
    if (name.isNotEmpty && name != '0') return name;
    if (userName.isNotEmpty && userName != '0') return userName;
    return SessionRole.roleLabel;
  }

  Widget _buildGreetingSection(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;
    final hairline = cts.navy.withValues(alpha: 0.14);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _timeOfDayGreeting().toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cts.navy,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _displayUserName(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: cts.navy,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: hairline, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: CtsBrandLogo(height: 44),
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(
    BuildContext context,
    String label, {
    String? trailing,
  }) {
    final theme = Theme.of(context);
    final cts = context.cts;
    return Row(
      children: [
        Expanded(
          child: Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: cts.navy,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cts.navy,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _buildOverviewSection(BuildContext context, AdminProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(context, 'Overview'),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = [
              CompactStatCard(
                title: 'Batches',
                value: provider.batchCount.toString(),
                subtitle: '${provider.runningBatchCount} active',
                onTap: () => context.push(RouteName.batchScreen),
              ),
              CompactStatCard(
                title: 'Commuters',
                value: provider.commuterCount.toString(),
                subtitle: '${provider.isComingCount} coming today',
                onTap: () => context.push(RouteName.commuterScreen),
              ),
              CompactStatCard(
                title: 'Routes',
                value: provider.routeCount.toString(),
                subtitle: 'Active',
                onTap: () => context.push(RouteName.routeScreen),
              ),
              CompactStatCard(
                title: 'Pick-up Points',
                value: provider.popCount.toString(),
                subtitle: 'Locations',
                onTap: () => context.push(RouteName.popScreen),
              ),
              CompactStatCard(
                title: 'Cabs',
                value: provider.cabCount.toString(),
                subtitle: 'Vehicles',
                onTap: () => context.push(RouteName.cabScreen),
              ),
              CompactStatCard(
                title: 'Drivers',
                value: provider.driverCount.toString(),
                subtitle: 'Active',
                onTap: () => context.push(RouteName.driverScreen),
              ),
            ];

            // Prefer 3-col board; fall back to 2-col on very narrow widths.
            final crossAxisCount = constraints.maxWidth < 340 ? 2 : 3;
            const gap = 10.0;
            final itemWidth =
                (constraints.maxWidth - gap * (crossAxisCount - 1)) /
                    crossAxisCount;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final card in cards)
                  SizedBox(width: itemWidth, child: card),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildRunningBatchesSection(
    BuildContext context,
    AdminProvider provider,
  ) {
    final theme = Theme.of(context);
    final cts = context.cts;
    final hairline = cts.navy.withValues(alpha: 0.14);
    final batches = sortListAZ<RunningBatches>(
      provider.runningBatches,
      (batch) => batch.batchId?.batchName ?? '',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(
          context,
          'Running Now',
          trailing: '${batches.length} live',
        ),
        const SizedBox(height: 12),
        if (batches.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: hairline, width: 1),
            ),
            child: Column(
              children: [
                Text(
                  'No running batches right now',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: cts.navy,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'When a batch goes live, it will appear here.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cts.navy.withValues(alpha: 0.65),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () =>
                      context.push(RouteName.runningBatchScreen),
                  child: Text(
                    'View running batches',
                    style: TextStyle(
                      color: cts.navy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...batches.map((batch) {
            final batchId = batch.batchId?.id?.toString();
            final batchName = batch.batchId?.batchName ?? 'Unknown batch';
            final user = batch.driver?.userId;
            final driverName = [
              user?.firstName,
              user?.lastName,
            ].whereType<String>().where((n) => n.isNotEmpty).join(' ');

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RunningBatchDashboardTile(
                batchName: batchName,
                driverName: driverName.isEmpty ? null : driverName,
                onTap: batchId == null
                    ? null
                    : () => context.push('${RouteName.d2dChannel}/$batchId'),
              ),
            );
          }),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () =>
                      context.push(RouteName.runningBatchScreen),
                  style: TextButton.styleFrom(
                    foregroundColor: cts.navy,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'RUNNING BATCHES',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cts.navy,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () =>
                      context.push(RouteName.returnBatchScreen),
                  style: TextButton.styleFrom(
                    foregroundColor: cts.navy,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'RETURN BATCHES',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cts.navy,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPartialLoadBanner(
    BuildContext context,
    AdminProvider provider,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.errorContainer,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: scheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                provider.loadWarning ??
                    'Some dashboard data could not be loaded.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onErrorContainer,
                    ),
              ),
            ),
            TextButton(
              onPressed: () => provider.loadDetailedDashboardData(),
              child: Text(
                'Retry',
                style: TextStyle(color: scheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(context, 'Quick Actions'),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final crossAxisCount = width >= 900 ? 4 : 2;
            final aspectRatio = crossAxisCount == 2 ? 3.1 : 2.8;

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: aspectRatio,
              children: [
                QuickActionButton(
                  label: 'Add Batch',
                  emphasized: true,
                  onTap: () {
                    context.read<BatchFormProvider>().clearAll();
                    context.push(RouteName.batchForm);
                  },
                ),
                QuickActionButton(
                  label: 'Add Commuter',
                  onTap: () {
                    context.read<CommuterFormProvider>().clearAll();
                    context.push(RouteName.commuterForm);
                  },
                ),
                QuickActionButton(
                  label: 'Add Driver',
                  onTap: () {
                    context.read<DriverFormProvider>().clearAll();
                    context.push(RouteName.driverForm);
                  },
                ),
                QuickActionButton(
                  label: 'Add Cab',
                  onTap: () {
                    context.read<CabFormProvider>().clearAll();
                    context.push(RouteName.cabForm);
                  },
                ),
                QuickActionButton(
                  label: 'Add Route',
                  onTap: () {
                    context.read<RouteFormProvider>().clearAll();
                    context.push(RouteName.routeForm);
                  },
                ),
                QuickActionButton(
                  label: 'Add POP',
                  onTap: () {
                    context.read<PopFormProvider>().clearAll();
                    context.push(RouteName.popForm);
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDashboardSkeleton(BuildContext context) {
    final cts = context.cts;
    final base = cts.navy.withValues(alpha: 0.08);
    final highlight = cts.navy.withValues(alpha: 0.03);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 12,
                        width: 110,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 28,
                        width: 180,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Container(
              height: 12,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 28),
            Container(
              height: 12,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(
                6,
                (_) => Container(
                  width: (MediaQuery.sizeOf(context).width - 40 - 20) / 3,
                  height: 88,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Container(
              height: 12,
              width: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 3.1,
              children: List.generate(
                6,
                (_) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RunningBatchDashboardTile extends StatelessWidget {
  const _RunningBatchDashboardTile({
    required this.batchName,
    this.driverName,
    this.onTap,
  });

  final String batchName;
  final String? driverName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cts = context.cts;
    final theme = Theme.of(context);
    final hairline = cts.navy.withValues(alpha: 0.14);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: hairline, width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cts.navy,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'LIVE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      batchName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: cts.navy,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (driverName != null && driverName!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Driver: $driverName',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cts.navy.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: cts.navy.withValues(alpha: 0.55),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
