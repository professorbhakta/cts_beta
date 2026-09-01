import 'package:cts/theme/cts_colors.dart';
import 'package:cts/appManager/snackbar_service.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:cts/appManager/functions_and_tools.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/batches/models/return_intent_model.dart';
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
                    const SizedBox(height: 12),
                    _buildScanBoardingButton(context, commuter),
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
                      title: 'Return today',
                      subtitle:
                          'Tell the pool if you need home, skip, or an earlier cab',
                    ),
                    const SizedBox(height: 12),
                    _buildReturnIntentSection(context, provider),
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
                      icon: Icon(Icons.my_location_rounded),
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
    final scheme = context.scheme;
    final cts = context.cts;

    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cts.yellowDark, scheme.primary],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cts.yellowDark.withValues(alpha: 0.22),
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
                    color: scheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: scheme.onSurface,
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
                    color: scheme.onSurface.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.85),
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
    final cts = context.cts;

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final statusColor = isComing ? cts.success : scheme.error;
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
              color: scheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
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

  Widget _buildScanBoardingButton(BuildContext context, CommuterModel commuter) {
    final scheme = context.scheme;
    final cts = context.cts;
    final isComing = commuter.isComing ?? false;
    return FilledButton.icon(
      onPressed: () {
        if (!isComing) {
          SnackBarService.showErrorSnackbar(
            'Mark Coming first, then scan the boarding QR.',
          );
          return;
        }
        context.push(RouteName.boardingScan);
      },
      icon: Icon(Icons.qr_code_scanner),
      label: const Text('Scan boarding QR'),
      style: FilledButton.styleFrom(
        backgroundColor: cts.yellowDark,
        foregroundColor: scheme.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }

  Widget _buildStatusToggle(
    BuildContext context,
    CommuterHomeProvider provider,
    CommuterModel commuter,
  ) {
    final cts = context.cts;

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final isComing = commuter.isComing ?? false;
    final accent = isComing ? cts.success : scheme.error;

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

  Widget _buildReturnIntentSection(
    BuildContext context,
    CommuterHomeProvider provider,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final selected = provider.returnIntent.intent;
    final busy = provider.isUpdatingIntent;
    final earlierLabel = provider.earlierOptionLabel;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isLight ? scheme.surface : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _intentChip(
                context,
                label: 'Home',
                selected: selected == ReturnIntentKind.home,
                enabled: !busy,
                onSelected: () => _saveIntent(
                  context,
                  provider,
                  () => provider.selectHomeIntent(),
                  successMessage: 'Return intent set to Home',
                ),
              ),
              _intentChip(
                context,
                label: 'Skip',
                selected: selected == ReturnIntentKind.skip,
                enabled: !busy,
                onSelected: () => _saveIntent(
                  context,
                  provider,
                  () => provider.selectSkipIntent(),
                  successMessage: 'Return trip skipped for today',
                ),
              ),
              _intentChip(
                context,
                label: earlierLabel == null ? 'Earlier…' : 'Earlier',
                selected: selected == ReturnIntentKind.earlier,
                enabled: !busy,
                onSelected: () => _pickEarlierBatch(context, provider),
              ),
            ],
          ),
          if (selected == ReturnIntentKind.earlier && earlierLabel != null) ...[
            const SizedBox(height: 10),
            Text(
              'Target: $earlierLabel',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
          if (provider.intentErrorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              provider.intentErrorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.error,
              ),
            ),
          ],
          if (busy) ...[
            const SizedBox(height: 12),
            const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ],
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: (busy || provider.isJoiningWaiting)
                ? null
                : () => _offerJoinReturnWaiting(context, provider),
            icon: const Icon(Icons.hourglass_top_rounded),
            label: const Text('Join return waiting line'),
          ),
          if (provider.joinWaitingError != null) ...[
            const SizedBox(height: 8),
            Text(
              provider.joinWaitingError!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _offerJoinReturnWaiting(
    BuildContext context,
    CommuterHomeProvider provider,
  ) async {
    final wantsJoin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Join return waiting line?'),
        content: const Text(
          'If return seats are full, you can join the FCFS waiting line. '
          'You will be auto-confirmed when a seat opens.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Join waiting line'),
          ),
        ],
      ),
    );
    if (wantsJoin != true || !context.mounted) return;

    final message = await provider.joinReturnWaitingLine();
    if (!context.mounted) return;
    if (message != null && provider.joinWaitingError == null) {
      SnackBarService.showsSuccessSnackbar(message, '');
    } else if (provider.joinWaitingError != null) {
      SnackBarService.showErrorSnackbar(provider.joinWaitingError!);
    }
  }

  Widget _intentChip(
    BuildContext context, {
    required String label,
    required bool selected,
    required bool enabled,
    required VoidCallback onSelected,
  }) {

    final scheme = Theme.of(context).colorScheme;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: enabled ? (_) => onSelected() : null,
      selectedColor: scheme.primary.withValues(alpha: 0.55),
      checkmarkColor: scheme.onSurface,
      labelStyle: TextStyle(
        color: selected ? scheme.onSurface : scheme.onSurface,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      ),
    );
  }

  Future<void> _saveIntent(
    BuildContext context,
    CommuterHomeProvider provider,
    Future<bool> Function() action, {
    required String successMessage,
  }) async {
    final ok = await action();
    if (!context.mounted) return;
    if (ok) {
      SnackBarService.showsSuccessSnackbar(successMessage, '');
    } else {
      SnackBarService.showErrorSnackbar(
        provider.intentErrorMessage ?? 'Could not save return intent',
      );
    }
  }

  Future<void> _pickEarlierBatch(
    BuildContext context,
    CommuterHomeProvider provider,
  ) async {
    final options = provider.earlierOptions;
    if (options.isEmpty) {
      SnackBarService.showErrorSnackbar(
        'No earlier return batches are available for your org.',
      );
      return;
    }

    final selectedId = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {

        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  'Choose an earlier return',
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              for (final option in options)
                ListTile(
                  title: Text(option.batchName),
                  subtitle: option.endTime == null
                      ? null
                      : Text('Return ${option.endTime}'),
                  trailing: provider.returnIntent.targetBatchId == option.id
                      ? Icon(Icons.check_rounded)
                      : null,
                  onTap: () => Navigator.of(sheetContext).pop(option.id),
                ),
            ],
          ),
        );
      },
    );

    if (selectedId == null || !context.mounted) return;
    await _saveIntent(
      context,
      provider,
      () => provider.selectEarlierIntent(selectedId),
      successMessage: 'Earlier return preference saved',
    );
  }

  Widget _buildTripSummaryCard(BuildContext context, CommuterModel commuter) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final cts = context.cts;
    final isLight = theme.brightness == Brightness.light;
    final batchName = commuter.batchId?.batchName ?? 'No batch assigned';
    final collegeName = commuter.collegeName;
    final adminMobile = commuter.adminCode?.userId?.mobileNumber;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isLight ? scheme.surface : scheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLight
              ? scheme.outline.withValues(alpha: 0.35)
              : scheme.primary.withValues(alpha: 0.3),
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
              color: scheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
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
                backgroundColor: cts.success.withValues(alpha: 0.12),
                foregroundColor: cts.success,
              ),
              icon: Icon(Icons.call_rounded, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildTripInfoGrid(BuildContext context, CommuterModel commuter) {
    final scheme = context.scheme;
    final cts = context.cts;
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
        color: scheme.primary,
      ),
      _TripInfoTile(
        icon: Icons.location_on_rounded,
        label: 'Pick-up Point',
        value: popName,
        color: cts.orangeWarm,
      ),
      _TripInfoTile(
        icon: Icons.route_rounded,
        label: 'Route',
        value: routeName,
        color: cts.yellowBright,
      ),
      _TripInfoTile(
        icon: Icons.directions_car_rounded,
        label: 'Cab',
        value: cabNumber,
        color: cts.orangeBright,
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
                color: cts.yellowDark,
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
              color: cts.yellowDark,
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
