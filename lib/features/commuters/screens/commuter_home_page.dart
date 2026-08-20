import 'package:cts/appManager/snackbar_service.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:cts/appManager/colors.dart';
import 'package:cts/appManager/functions_and_tools.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/commuters/models/commuter_model.dart';
import 'package:cts/features/commuters/providers/commuter_home_provider.dart';
import 'package:cts/widgets/app_drawer.dart';
import 'package:cts/widgets/brand_app_bar.dart';
import 'package:cts/widgets/common_button.dart';
import 'package:cts/widgets/confirmation_dialog.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class CommuterHomePage extends StatefulWidget {
  const CommuterHomePage({super.key});

  @override
  State<CommuterHomePage> createState() => _CommuterHomePageState();
}

class _CommuterHomePageState extends State<CommuterHomePage> {
  static const double _maxContentWidth = 720;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommuterHomeProvider>().fetchCommuterProfile();
    });
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _formatBatchTime(String? batchTime) {
    if (batchTime == null || batchTime.isEmpty) return 'N/A';
    if (batchTime.length >= 5) return batchTime.substring(0, 5);
    return batchTime;
  }

  void _openTrackCab(CommuterModel commuter) {
    if (commuter.cabId == null) {
      SnackBarService.showErrorSnackbar(
        'No cab assigned to your profile yet. Contact admin.',
      );
      return;
    }

    final params = <String, String>{};
    final trackingId = commuter.cabTrackingVehicleId;
    if (trackingId != null) {
      params['vehicleId'] = trackingId;
    }
    final reg = commuter.cabId?.regNumber?.trim();
    if (reg != null && reg.isNotEmpty) {
      params['cabReg'] = reg;
    }

    context.push(
      Uri(path: RouteName.trackCabScreen, queryParameters: params).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandAppBar(),
      drawer: const AppDrawer(),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () =>
              context.read<CommuterHomeProvider>().fetchCommuterProfile(),
          child: Consumer<CommuterHomeProvider>(
            builder: (context, provider, child) {
              return switch (provider.state) {
                ViewState.loading => _buildSkeleton(context),
                ViewState.error => ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      StatusMessage.error(
                        title: provider.errorMessage ?? 'An error occurred',
                        onRetry: () => provider.fetchCommuterProfile(),
                      ),
                    ],
                  ),
                _ when provider.commuterProfile == null =>
                  ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      StatusMessage(
                        icon: Icons.person_outline,
                        title: 'Could not load your profile.',
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
    );
  }

  Widget _buildContent(BuildContext context, CommuterHomeProvider provider) {
    final commuter = provider.commuterProfile!;
    final commuterName = commuter.userId?.username ?? 'Commuter';

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
                    _buildWelcomeSection(context, commuterName),
                    const SizedBox(height: 28),
                    _buildSectionHeader(
                      context,
                      title: 'Today\'s Status',
                      subtitle: 'Confirm whether you\'re riding today',
                    ),
                    const SizedBox(height: 12),
                    _buildDateStrip(context, commuter.isComing ?? false),
                    const SizedBox(height: 10),
                    _buildStatusToggle(context, provider, commuter),
                    if (provider.isUpdating) ...[
                      const SizedBox(height: 12),
                      const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    _buildSectionHeader(
                      context,
                      title: 'Trip Details',
                      subtitle: 'Your assigned batch and route info',
                    ),
                    const SizedBox(height: 12),
                    _buildTripSummaryCard(context, commuter),
                    const SizedBox(height: 12),
                    _buildTripInfoGrid(context, commuter),
                    const SizedBox(height: 28),
                    CommonPrimaryButton(
                      width: double.infinity,
                      label: 'Track your Cab',
                      radius: 12,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      icon: const Icon(Icons.my_location_rounded),
                      onPressed: () => _openTrackCab(commuter),
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

  Widget _buildWelcomeSection(BuildContext context, String name) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.acYellowDark, AppColors.acYellowWarm],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.acYellowDark.withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.acBlack.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppColors.acBlack,
                    fontWeight: FontWeight.bold,
                    height: 1.15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  'Update your status and review today\'s trip.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.acBlack.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.acWhite.withValues(alpha: 0.85),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/images/c2s.png',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    String? subtitle,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDateStrip(BuildContext context, bool isComing) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final statusColor = isComing ? AppColors.acGreen : AppColors.acRed;
    final statusLabel = isComing ? 'COMING' : 'NOT COMING';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isLight ? scheme.surface : statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLight
              ? scheme.outline.withValues(alpha: 0.35)
              : statusColor.withValues(alpha: 0.3),
        ),
        boxShadow: isLight
            ? [
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.acYellowWarm,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              DateFormat.yMMMEd().format(DateTime.now()),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: isLight ? 0.12 : 0.2),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: statusColor.withValues(alpha: 0.35)),
            ),
            child: Text(
              statusLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusToggle(
    BuildContext context,
    CommuterHomeProvider provider,
    CommuterModel commuter,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final isComing = commuter.isComing ?? false;
    final accent = isComing ? AppColors.acGreen : AppColors.acRed;

    return Container(
      decoration: BoxDecoration(
        color: isLight ? scheme.surface : accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLight
              ? scheme.outline.withValues(alpha: 0.35)
              : accent.withValues(alpha: 0.3),
        ),
        boxShadow: isLight
            ? [
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
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
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isComing
                            ? Icons.check_circle_rounded
                            : Icons.cancel_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Coming today',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Let admin know if you\'re riding today.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: isComing,
                      onChanged: provider.isUpdating
                          ? null
                          : (newValue) {
                              _showConfirmationDialog(
                                context,
                                provider,
                                newValue,
                              );
                            },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripSummaryCard(BuildContext context, CommuterModel commuter) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final batchName = commuter.batchId?.batchName ?? 'No batch assigned';
    final collegeName = commuter.collegeName;
    final adminMobile = commuter.adminCode?.userId?.mobileNumber;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isLight ? scheme.surface : AppColors.acYellowWarm.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLight
              ? scheme.outline.withValues(alpha: 0.35)
              : AppColors.acYellowWarm.withValues(alpha: 0.3),
        ),
        boxShadow: isLight
            ? [
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.acYellowWarm,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_bus_filled_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  batchName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  collegeName?.isNotEmpty == true
                      ? collegeName!
                      : 'Your assigned trip for today',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (adminMobile != null && adminMobile.isNotEmpty)
            IconButton(
              tooltip: 'Call admin',
              onPressed: () => calling(adminMobile),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.acGreen.withValues(alpha: 0.12),
                foregroundColor: AppColors.acGreen,
              ),
              icon: const Icon(Icons.call_rounded, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildTripInfoGrid(BuildContext context, CommuterModel commuter) {
    final batchName = commuter.batchId?.batchName ?? 'N/A';
    final startTime = _formatBatchTime(commuter.batchId?.batchTime);
    final popName = commuter.popId?.pickUpPointName ?? 'N/A';
    final routeName = commuter.popId?.routeId?.routeName ?? 'N/A';
    final cabNumber = commuter.cabId?.regNumber ?? 'N/A';

    final tiles = [
      _TripInfoTile(
        icon: Icons.access_time_rounded,
        label: 'Start',
        value: startTime,
        color: AppColors.acYellowWarm,
      ),
      _TripInfoTile(
        icon: Icons.location_on_rounded,
        label: 'Pick-up Point',
        value: popName,
        color: AppColors.acOrangeWarm,
      ),
      _TripInfoTile(
        icon: Icons.route_rounded,
        label: 'Route',
        value: routeName,
        color: AppColors.acYellowBright,
      ),
      _TripInfoTile(
        icon: Icons.directions_car_rounded,
        label: 'Cab',
        value: cabNumber,
        color: AppColors.acOrangeBright,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 480) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: tiles[0]),
                  const SizedBox(width: 10),
                  Expanded(child: tiles[1]),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: tiles[2]),
                  const SizedBox(width: 10),
                  Expanded(child: tiles[3]),
                ],
              ),
              const SizedBox(height: 10),
              _TripInfoTile(
                icon: Icons.event_rounded,
                label: 'Batch',
                value: batchName,
                color: AppColors.acYellowDark,
                fullWidth: true,
              ),
            ],
          );
        }

        return Column(
          children: [
            Row(
              children: [
                for (var i = 0; i < tiles.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(child: tiles[i]),
                ],
              ],
            ),
            const SizedBox(height: 10),
            _TripInfoTile(
              icon: Icons.event_rounded,
              label: 'Batch',
              value: batchName,
              color: AppColors.acYellowDark,
              fullWidth: true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final placeholder = scheme.surfaceContainerHighest;

    return Shimmer.fromColors(
      baseColor: scheme.surfaceContainerHighest,
      highlightColor: scheme.surface,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: placeholder,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    height: 16,
                    width: 130,
                    decoration: BoxDecoration(
                      color: placeholder,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: placeholder,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 72,
                    decoration: BoxDecoration(
                      color: placeholder,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    height: 16,
                    width: 110,
                    decoration: BoxDecoration(
                      color: placeholder,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 76,
                    decoration: BoxDecoration(
                      color: placeholder,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 72,
                          decoration: BoxDecoration(
                            color: placeholder,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 72,
                          decoration: BoxDecoration(
                            color: placeholder,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showConfirmationDialog(
    BuildContext context,
    CommuterHomeProvider provider,
    bool newValue,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => ConfirmationDialog(
        title: 'Confirm Change',
        message: newValue
            ? 'Mark yourself as coming today?'
            : 'Mark yourself as not coming today?',
        confirmLabel: 'CONFIRM',
        cancelLabel: 'CANCEL',
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final success = await provider.updateIsComing(newValue);
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            newValue ? 'You are marked as coming today' : 'Status updated',
          ),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'Failed to update status',
          ),
        ),
      );
    }
  }
}

class _TripInfoTile extends StatelessWidget {
  const _TripInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.fullWidth = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isLight ? scheme.surface : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLight
              ? scheme.outline.withValues(alpha: 0.35)
              : color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
