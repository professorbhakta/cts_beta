import 'package:cts/theme/cts_colors.dart';
import 'package:cts/appManager/snackbar_service.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:cts/appManager/functions_and_tools.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/batches/models/return_intent_model.dart';
import 'package:cts/features/commuters/models/commuter_model.dart';
import 'package:cts/features/commuters/providers/commuter_home_provider.dart';
import 'package:cts/widgets/confirmation_dialog.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

enum _HeroMode { notComing, scan, boarded }

class CommuterHomePage extends StatefulWidget {
  const CommuterHomePage({super.key});

  @override
  State<CommuterHomePage> createState() => _CommuterHomePageState();
}

class _CommuterHomePageState extends State<CommuterHomePage> {
  static const double _maxContentWidth = 720;
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommuterHomeProvider>().fetchCommuterProfile();
    });
  }

  String _formatBatchTime(String? batchTime) {
    if (batchTime == null || batchTime.isEmpty) return '—';
    if (batchTime.length >= 5) return batchTime.substring(0, 5);
    return batchTime;
  }

  /// Quiet human time for the hero, e.g. "7:40 this morning".
  String _humanTripTime(String? batchTime) {
    final raw = _formatBatchTime(batchTime);
    if (raw == '—') return 'Time TBD';
    final parts = raw.split(':');
    if (parts.length < 2) return raw;
    final hour = int.tryParse(parts[0]);
    final minute = parts[1];
    if (hour == null) return raw;
    final period = hour < 12
        ? 'this morning'
        : hour < 17
            ? 'this afternoon'
            : 'this evening';
    return '$hour:$minute $period';
  }

  _HeroMode _heroMode(CommuterHomeProvider provider) {
    final coming = provider.commuterProfile?.isComing ?? false;
    if (!coming) return _HeroMode.notComing;
    if (provider.hasBoardedToday) return _HeroMode.boarded;
    return _HeroMode.scan;
  }

  Future<void> _openTrackCab(CommuterModel commuter) async {
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

    await context.push(
      Uri(path: RouteName.trackCabScreen, queryParameters: params).toString(),
    );
  }

  Future<void> _openBoardingScan(CommuterHomeProvider provider) async {
    final coming = provider.commuterProfile?.isComing ?? false;
    if (!coming) {
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

  Future<void> _onBottomNavTap(int index, CommuterHomeProvider provider) async {
    final profile = provider.commuterProfile;
    if (index == 0) {
      setState(() => _navIndex = 0);
      return;
    }
    if (profile == null) return;
    if (index == 1) {
      setState(() => _navIndex = 1);
      await _openBoardingScan(provider);
      if (mounted) setState(() => _navIndex = 0);
      return;
    }
    if (index == 2) {
      setState(() => _navIndex = 2);
      await _openTrackCab(profile);
      if (mounted) setState(() => _navIndex = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final cts = context.cts;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHighest,
      body: SafeArea(
        bottom: false,
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
          return NavigationBar(
            backgroundColor: scheme.surfaceContainerHighest,
            indicatorColor: cts.yellow.withValues(alpha: 0.35),
            selectedIndex: _navIndex,
            onDestinationSelected: (i) => _onBottomNavTap(i, provider),
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: cts.navy),
                selectedIcon: Icon(Icons.home_rounded, color: cts.navy),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.qr_code_scanner_outlined, color: cts.navy),
                selectedIcon: Icon(Icons.qr_code_scanner, color: cts.navy),
                label: 'Scan',
              ),
              NavigationDestination(
                icon: Icon(Icons.my_location_outlined, color: cts.navy),
                selectedIcon: Icon(Icons.my_location_rounded, color: cts.navy),
                label: 'Track',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final cts = context.cts;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      child: Row(
        children: [
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
                color: context.scheme.onSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, CommuterHomeProvider provider) {
    final commuter = provider.commuterProfile!;
    final mode = _heroMode(provider);

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
                    _buildHeader(context),
                    const SizedBox(height: 8),
                    _buildHeroCard(context, provider, commuter, mode),
                    const SizedBox(height: 14),
                    _buildQuietComingToggle(context, provider, commuter),
                    if (provider.isUpdating) ...[
                      const SizedBox(height: 10),
                      const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    _buildQuietReturnSection(context, provider),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    CommuterHomeProvider provider,
    CommuterModel commuter,
    _HeroMode mode,
  ) {
    final cts = context.cts;
    final theme = Theme.of(context);
    final scheme = context.scheme;
    final gate = commuter.popId?.pickUpPointName ?? 'Pickup TBD';
    final cab = commuter.cabId?.regNumber ?? 'Cab TBD';
    final timeLabel = _humanTripTime(commuter.batchId?.batchTime);
    final meta = '$gate · $cab';
    final adminMobile = commuter.adminCode?.userId?.mobileNumber;

    // Hero CTA is Scan or Track only — Coming is controlled solely by the Switch.
    late final String headline;
    late final String ctaLabel;
    late final VoidCallback? onCta;

    switch (mode) {
      case _HeroMode.notComing:
        headline = 'Heading in today?';
        ctaLabel = 'Scan QR';
        onCta = () => _openBoardingScan(provider);
      case _HeroMode.scan:
        headline = 'Ready to board';
        ctaLabel = 'Scan QR';
        onCta = () => _openBoardingScan(provider);
      case _HeroMode.boarded:
        headline = 'You’re on the cab';
        ctaLabel = 'Track cab';
        onCta = () => _openTrackCab(commuter);
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 18),
      decoration: BoxDecoration(
        color: cts.navy,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  timeLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSecondary.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
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
                    color: scheme.onSecondary.withValues(alpha: 0.75),
                    size: 18,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            headline,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: scheme.onSecondary,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            meta,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSecondary.withValues(alpha: 0.82),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onCta,
              style: FilledButton.styleFrom(
                backgroundColor: cts.yellow,
                foregroundColor: scheme.onPrimary,
                disabledBackgroundColor: cts.yellow.withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                ctaLabel,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuietComingToggle(
    BuildContext context,
    CommuterHomeProvider provider,
    CommuterModel commuter,
  ) {
    final cts = context.cts;
    final theme = Theme.of(context);
    final isComing = commuter.isComing ?? false;

    return Row(
      children: [
        Expanded(
          child: Text(
            'Riding today',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: cts.navy,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Switch(
          value: isComing,
          onChanged: provider.isUpdating
              ? null
              : (newValue) {
                  _showConfirmationDialog(context, provider, newValue);
                },
        ),
      ],
    );
  }

  Widget _buildQuietReturnSection(
    BuildContext context,
    CommuterHomeProvider provider,
  ) {
    final cts = context.cts;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final selected = provider.returnIntent.intent;
    final busy = provider.isUpdatingIntent;
    final earlierLabel = provider.earlierOptionLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Need a ride home?',
          style: theme.textTheme.titleMedium?.copyWith(
            color: cts.navy,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _returnChoice(
                context,
                label: 'Yes',
                selected: selected == ReturnIntentKind.home,
                enabled: !busy,
                onSelected: () => _saveIntent(
                  context,
                  provider,
                  () => provider.selectHomeIntent(),
                  successMessage: 'Return intent set to Home',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _returnChoice(
                context,
                label: 'Not today',
                selected: selected == ReturnIntentKind.skip,
                enabled: !busy,
                onSelected: () => _saveIntent(
                  context,
                  provider,
                  () => provider.selectSkipIntent(),
                  successMessage: 'Return trip skipped for today',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _returnChoice(
                context,
                label: 'Earlier',
                selected: selected == ReturnIntentKind.earlier,
                enabled: !busy,
                onSelected: () => _pickEarlierBatch(context, provider),
              ),
            ),
          ],
        ),
        if (selected == ReturnIntentKind.earlier && earlierLabel != null) ...[
          const SizedBox(height: 8),
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
          const SizedBox(height: 10),
          const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ],
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: (busy || provider.isJoiningWaiting)
                ? null
                : () => _offerJoinReturnWaiting(context, provider),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Cab full? Get in line',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cts.navy.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: cts.navy.withValues(alpha: 0.45),
                ),
              ),
            ),
          ),
        ),
        if (provider.joinWaitingError != null) ...[
          const SizedBox(height: 6),
          Text(
            provider.joinWaitingError!,
            style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
          ),
        ],
      ],
    );
  }

  Widget _returnChoice(
    BuildContext context, {
    required String label,
    required bool selected,
    required bool enabled,
    required VoidCallback onSelected,
  }) {
    final cts = context.cts;
    final scheme = context.scheme;
    final theme = Theme.of(context);

    return Material(
      color: selected ? cts.yellow : scheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? onSelected : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? cts.navy.withValues(alpha: 0.35)
                  : cts.navy.withValues(alpha: 0.18),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge?.copyWith(
              color: cts.navy,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
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
    final scheme = Theme.of(context).colorScheme;
    final placeholder = scheme.surfaceContainerHighest;

    return Shimmer.fromColors(
      baseColor: scheme.outline.withValues(alpha: 0.2),
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
                    height: 28,
                    width: 64,
                    decoration: BoxDecoration(
                      color: placeholder,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      color: placeholder,
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: placeholder,
                      borderRadius: BorderRadius.circular(14),
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
