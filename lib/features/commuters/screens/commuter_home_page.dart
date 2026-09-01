import 'package:cts/theme/cts_colors.dart';
import 'package:cts/appManager/snackbar_service.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:cts/appManager/functions_and_tools.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/batches/models/return_intent_model.dart';
import 'package:cts/features/commuters/models/commuter_model.dart';
import 'package:cts/features/commuters/providers/commuter_home_provider.dart';
import 'package:cts/widgets/brand_app_bar.dart';
import 'package:cts/widgets/confirmation_dialog.dart';
import 'package:cts/widgets/role_bottom_nav.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  Future<void> _openScan(CommuterHomeProvider provider, CommuterModel commuter) async {
    final isComing = commuter.isComing ?? false;
    if (!isComing) {
      SnackBarService.showErrorSnackbar(
        'Mark Coming first, then scan the boarding QR.',
      );
      return;
    }
    final boarded = await context.push<bool>(RouteName.boardingScan);
    if (!mounted) return;
    if (boarded == true) {
      provider.markBoardedToday();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandAppBar(automaticallyImplyLeading: false),
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
                _ when provider.commuterProfile == null => ListView(
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
      bottomNavigationBar: Consumer<CommuterHomeProvider>(
        builder: (context, provider, _) {
          final commuter = provider.commuterProfile;
          return RoleBottomNav(
            selected: RoleBottomNavTab.home,
            onScan: commuter == null
                ? null
                : () => _openScan(provider, commuter),
            onTrack: commuter == null ? null : () => _openTrackCab(commuter),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, CommuterHomeProvider provider) {
    final commuter = provider.commuterProfile!;

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
                    _buildMorningHero(context, provider, commuter),
                    const SizedBox(height: 16),
                    _buildComingToggle(context, provider, commuter),
                    const SizedBox(height: 20),
                    _buildReturnIntentSection(context, provider),
                    if (provider.isUpdating) ...[
                      const SizedBox(height: 16),
                      const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
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

  Widget _buildMorningHero(
    BuildContext context,
    CommuterHomeProvider provider,
    CommuterModel commuter,
  ) {
    final scheme = context.scheme;
    final cts = context.cts;
    final theme = context.theme;
    final isComing = commuter.isComing ?? false;
    final boarded = provider.hasBoardedToday;
    final batchName = commuter.batchId?.batchName ?? 'No batch';
    final startTime = _formatBatchTime(commuter.batchId?.batchTime);
    final pickup = commuter.popId?.pickUpPointName ?? 'Pickup TBD';
    final cabNumber = commuter.cabId?.regNumber ?? 'Cab TBD';
    final adminMobile = commuter.adminCode?.userId?.mobileNumber;

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
          const SizedBox(height: 12),
          Text(
            startTime,
            style: theme.textTheme.displaySmall?.copyWith(
              color: scheme.onSecondary,
              fontWeight: FontWeight.w800,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 16),
          _heroDetailRow(
            context,
            icon: Icons.location_on_rounded,
            label: 'Pickup',
            value: pickup,
          ),
          const SizedBox(height: 10),
          _heroDetailRow(
            context,
            icon: Icons.directions_car_rounded,
            label: 'Cab',
            value: cabNumber,
          ),
          const SizedBox(height: 20),
          _buildPrimaryTripAction(context, provider, commuter, isComing, boarded),
        ],
      ),
    );
  }

  Widget _heroDetailRow(
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryTripAction(
    BuildContext context,
    CommuterHomeProvider provider,
    CommuterModel commuter,
    bool isComing,
    bool boarded,
  ) {
    final scheme = context.scheme;
    final theme = context.theme;

    if (!isComing) {
      return FilledButton(
        onPressed: provider.isUpdating
            ? null
            : () => _showConfirmationDialog(context, provider, true),
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          'Coming today',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: scheme.onPrimary,
          ),
        ),
      );
    }

    if (boarded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: scheme.onSecondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_rounded,
                    color: context.cts.success, size: 22),
                const SizedBox(width: 8),
                Text(
                  "You're on board",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.onSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _openTrackCab(commuter),
            icon: Icon(Icons.my_location_rounded, color: scheme.onSecondary),
            label: Text(
              'Track cab',
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
        ],
      );
    }

    return FilledButton.icon(
      onPressed: () => _openScan(provider, commuter),
      icon: Icon(Icons.qr_code_scanner_rounded, color: scheme.onPrimary),
      label: Text(
        'Scan to board',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: scheme.onPrimary,
        ),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _buildComingToggle(
    BuildContext context,
    CommuterHomeProvider provider,
    CommuterModel commuter,
  ) {
    final scheme = context.scheme;
    final cts = context.cts;
    final theme = context.theme;
    final isComing = commuter.isComing ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isComing
                  ? cts.success.withValues(alpha: 0.15)
                  : scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.groups_rounded,
              color: isComing ? cts.success : scheme.onSurfaceVariant,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isComing ? 'Coming' : 'Not coming',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  isComing
                      ? "You're coming to office."
                      : 'Turn on when you plan to ride.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isComing,
            activeThumbColor: scheme.onSecondary,
            activeTrackColor: cts.success,
            onChanged: provider.isUpdating
                ? null
                : (newValue) {
                    _showConfirmationDialog(context, provider, newValue);
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildReturnIntentSection(
    BuildContext context,
    CommuterHomeProvider provider,
  ) {
    final theme = context.theme;
    final scheme = context.scheme;
    final selected = provider.returnIntent.intent;
    final busy = provider.isUpdatingIntent;
    final earlierLabel = provider.earlierOptionLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Return this evening',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Let us know your plans.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _intentChip(
              context,
              label: 'Home',
              icon: Icons.home_outlined,
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
              icon: Icons.fast_forward_outlined,
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
              label: earlierLabel == null ? 'Earlier' : 'Earlier',
              icon: Icons.schedule_outlined,
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
            style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
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
        TextButton.icon(
          onPressed: (busy || provider.isJoiningWaiting)
              ? null
              : () => _offerJoinReturnWaiting(context, provider),
          icon: const Icon(Icons.hourglass_top_rounded, size: 18),
          label: const Text('Join return waiting line'),
        ),
        if (provider.joinWaitingError != null) ...[
          Text(
            provider.joinWaitingError!,
            style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
          ),
        ],
      ],
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
    required IconData icon,
    required bool selected,
    required bool enabled,
    required VoidCallback onSelected,
  }) {
    final scheme = context.scheme;
    final cts = context.cts;
    return FilterChip(
      avatar: Icon(
        icon,
        size: 18,
        color: selected ? scheme.onPrimary : cts.navy,
      ),
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: enabled ? (_) => onSelected() : null,
      selectedColor: scheme.primary,
      backgroundColor: scheme.surface,
      side: BorderSide(
        color: selected
            ? scheme.primary
            : scheme.outline.withValues(alpha: 0.45),
      ),
      labelStyle: TextStyle(
        color: selected ? scheme.onPrimary : scheme.onSurface,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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
                      ? const Icon(Icons.check_rounded)
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

  Widget _buildSkeleton(BuildContext context) {
    final scheme = context.scheme;
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
                children: [
                  Container(
                    height: 260,
                    decoration: BoxDecoration(
                      color: placeholder,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 72,
                    decoration: BoxDecoration(
                      color: placeholder,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 16,
                    width: 180,
                    decoration: BoxDecoration(
                      color: placeholder,
                      borderRadius: BorderRadius.circular(4),
                    ),
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
