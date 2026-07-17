import 'package:cts/offline_temp/offline_auto_redirect.dart';
import 'package:cts/appManager/colors.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/controllers/admin_controller.dart';
import 'package:cts/shared/widgets/dashboard_shell.dart';
import 'package:cts/shared/widgets/dashboard_stat_card.dart';
import 'package:cts/shared/widgets/quick_action_button.dart';
import 'package:cts/shared/widgets/status_message.dart';
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

            // Main Statistics Cards (Large)
            Row(
              children: [
                Expanded(
                  child: DashboardStatCard(
                    title: 'Batches',
                    value: provider.batchCount.toString(),
                    icon: Icons.directions_bus,
                    subtitle: '${provider.runningBatchCount} active',
                    onTap: () =>
                        context.push(RouteName.batchScreen),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.acYellowWarm,
                        AppColors.acYellowBright,
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DashboardStatCard(
                    title: 'Commuters',
                    value: provider.commuterCount.toString(),
                    icon: Icons.people_alt,
                    subtitle: '${provider.isComingCount} coming today',
                    onTap: () =>
                        context.push(RouteName.commuterScreen),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.acOrangeWarm,
                        AppColors.acOrangeBright,
                      ],
                    ),
                  ),
                ),
              ],
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
            final crossAxisCount = constraints.maxWidth >= 600 ? 4 : 2;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: crossAxisCount == 2 ? 1.4 : 1.1,
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
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
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
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: List.generate(
                8,
                (index) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
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


