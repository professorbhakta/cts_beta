import 'package:cts/offline_temp/offline_auto_redirect.dart';
import 'package:cts/appManager/colors.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/admin_home/providers/admin_provider.dart';
import 'package:cts/features/batches/models/batch_model.dart';
import 'package:cts/utils/sort_utils.dart';
import 'package:cts/widgets/dashboard_shell.dart';
import 'package:cts/widgets/dashboard_stat_card.dart';
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
      // Call the new detailed data loading method
      if (context.read<AdminProvider>().state != ViewState.loading) {
        context.read<AdminProvider>().loadDetailedDashboardData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return OfflineAutoRedirect(
      child: DashboardShell(
        title: 'Dashboard',
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(context),
            const SizedBox(height: 32),

            // Main Statistics Cards
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 600;
                final batchCard = DashboardStatCard(
                  title: 'Batches',
                  value: provider.batchCount.toString(),
                  icon: Icons.directions_bus,
                  subtitle: '${provider.runningBatchCount} active',
                  onTap: () => context.push(RouteName.batchScreen),
                  color: AppColors.acYellowWarm,
                );
                final commuterCard = DashboardStatCard(
                  title: 'Commuters',
                  value: provider.commuterCount.toString(),
                  icon: Icons.people_alt,
                  subtitle: '${provider.isComingCount} coming today',
                  onTap: () => context.push(RouteName.commuterScreen),
                  color: AppColors.acOrangeWarm,
                );

                if (isCompact) {
                  return Column(
                    children: [
                      batchCard,
                      const SizedBox(height: 12),
                      commuterCard,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: batchCard),
                    const SizedBox(width: 16),
                    Expanded(child: commuterCard),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // Secondary Statistics — 2×2 on phone, single row on tablet+
            LayoutBuilder(
              builder: (context, constraints) {
                final cards = [
                  CompactStatCard(
                    title: 'Routes',
                    value: provider.routeCount.toString(),
                    subtitle: 'Active',
                    icon: Icons.route_outlined,
                    onTap: () =>
                        context.push(RouteName.routeScreen),
                    color: AppColors.acYellowWarm,
                  ),
                  CompactStatCard(
                    title: 'Pick-up Points',
                    value: provider.popCount.toString(),
                    subtitle: 'Locations',
                    icon: Icons.location_on_outlined,
                    onTap: () =>
                        context.push(RouteName.popScreen),
                    color: AppColors.acOrangeWarm,
                  ),
                  CompactStatCard(
                    title: 'Cabs',
                    value: provider.cabCount.toString(),
                    subtitle: 'Vehicles',
                    icon: Icons.directions_car_outlined,
                    onTap: () =>
                        context.push(RouteName.cabScreen),
                    color: AppColors.acYellowBright,
                  ),
                  CompactStatCard(
                    title: 'Drivers',
                    value: provider.driverCount.toString(),
                    subtitle: 'Active',
                    icon: Icons.person_outline,
                    onTap: () =>
                        context.push(RouteName.driverScreen),
                    color: AppColors.acOrangeBright,
                  ),
                ];
                if (constraints.maxWidth < 600) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: cards[0]),
                          const SizedBox(width: 12),
                          Expanded(child: cards[1]),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: cards[2]),
                          const SizedBox(width: 12),
                          Expanded(child: cards[3]),
                        ],
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      Expanded(child: cards[i]),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // Live running batches — tap to open D2D WebSocket channel
            _buildRunningBatchesSection(context, provider),
            const SizedBox(height: 32),

            // Quick Actions Section
            _buildQuickActionsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.acYellowDark, AppColors.acYellowWarm],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.acYellowDark.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Dark overlay for better text contrast
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          // Content
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppColors.acWhite,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Welcome Back!',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: AppColors.acWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your transportation system efficiently',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.acWhite.withValues(alpha: 0.95),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: AppColors.acWhite.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/images/c2s.png',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRunningBatchesSection(
    BuildContext context,
    AdminProvider provider,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final batches = sortListAZ<RunningBatches>(
      provider.runningBatches,
      (batch) => batch.batchId?.batchName ?? '',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Running Batches',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap a live batch to open its door-to-door channel.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 16),
        if (batches.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: isLight ? scheme.surface : scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: scheme.outline.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.directions_bus_outlined,
                  size: 36,
                  color: scheme.onSurface.withValues(alpha: 0.45),
                ),
                const SizedBox(height: 12),
                Text(
                  'No running batches right now',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'When a batch goes live, it will appear here.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
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
      ],
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final crossAxisCount = width >= 900 ? 4 : (width >= 600 ? 3 : 2);
            final aspectRatio = crossAxisCount == 2 ? 2.6 : 2.35;

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: aspectRatio,
              children: [
            QuickActionButton(
              icon: Icons.add_circle_outline,
              label: 'Add Batch',
              onTap: () {
                context.push(RouteName.batchForm);
              },
              color: AppColors.acYellowWarm,
            ),
            QuickActionButton(
              icon: Icons.person_add_outlined,
              label: 'Add Commuter',
              onTap: () {
                context.push(RouteName.commuterForm);
              },
              color: AppColors.acOrangeWarm,
            ),
            QuickActionButton(
              icon: Icons.drive_eta_outlined,
              label: 'Add Driver',
              onTap: () {
                context.push(RouteName.driverForm);
              },
              color: AppColors.acYellowBright,
            ),
            QuickActionButton(
              icon: Icons.directions_car_outlined,
              label: 'Add Cab',
              onTap: () {
                context.push(RouteName.cabForm);
              },
              color: AppColors.acOrangeBright,
            ),
            QuickActionButton(
              icon: Icons.route_outlined,
              label: 'Add Route',
              onTap: () {
                context.push(RouteName.routeForm);
              },
              color: AppColors.acYellowWarm,
            ),
            QuickActionButton(
              icon: Icons.location_on_outlined,
              label: 'Add POP',
              onTap: () {
                context.push(RouteName.popForm);
              },
              color: AppColors.acOrangeWarm,
            ),
            QuickActionButton(
              icon: Icons.play_circle_outline,
              label: 'Running Batches',
              onTap: () {
                context.push(RouteName.runningBatchScreen);
              },
              color: AppColors.acYellowBright,
            ),
            QuickActionButton(
              icon: Icons.assignment_returned_outlined,
              label: 'Return Batches',
              onTap: () {
                context.push(RouteName.returnBatchScreen);
              },
              color: AppColors.acOrangeBright,
            ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDashboardSkeleton(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: scheme.surfaceContainerHighest,
      highlightColor: scheme.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome skeleton
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 32),
            // Stats skeleton
            Column(
              children: [
                Container(
                  height: 96,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 96,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Compact cards skeleton
            Row(
              children: List.generate(
                4,
                (index) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index < 3 ? 12 : 0),
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Running batches skeleton
            Container(
              height: 20,
              width: 160,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 88,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(height: 32),
            // Quick actions skeleton
            Container(
              height: 20,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.6,
              children: List.generate(
                8,
                (index) => Container(
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    const liveColor = AppColors.acGreen;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 72),
          decoration: BoxDecoration(
            color: isLight ? scheme.surface : liveColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isLight
                  ? scheme.outline.withValues(alpha: 0.35)
                  : liveColor.withValues(alpha: 0.35),
            ),
            boxShadow: isLight
                ? [
                    BoxShadow(
                      color: scheme.shadow.withValues(alpha: 0.07),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: liveColor,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(14),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: liveColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.sensors_rounded,
                            color: liveColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: liveColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                    child: Text(
                                      'LIVE',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: liveColor,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      batchName,
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              if (driverName != null && driverName!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Driver: $driverName',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurface.withValues(alpha: 0.6),
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
                          color: scheme.onSurface.withValues(alpha: 0.45),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



