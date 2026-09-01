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
                    _buildCompactTripStrip(context, commuter),
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 20),
                    TextButton.icon(
                      onPressed: () => _openTrackCab(commuter),
                      icon: Icon(
                        Icons.my_location_rounded,
                        color: context.cts.navy,
                      ),
                      label: Text(
                        'Track your cab',
                        style: TextStyle(
                          color: context.cts.navy,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  Widget _buildHeroCard(
    BuildContext context,
    CommuterHomeProvider provider,
    CommuterModel commuter,
    _HeroMode mode,
  ) {
    final cts = context.cts;
    final theme = Theme.of(context);
    final batchName = commuter.batchId?.batchName ?? 'No batch';
    final gate = commuter.popId?.pickUpPointName ?? 'Pickup TBD';
    final cab = commuter.cabId?.regNumber ?? 'Cab TBD';
    final time = _formatBatchTime(commuter.batchId?.batchTime);
    final meta = '$batchName · $gate · $cab';

    late final String headline;
    late final String ctaLabel;
    late final String statusLine;
    late final VoidCallback? onCta;

    switch (mode) {
      case _HeroMode.notComing:
        headline = 'Mark coming to ride';
        ctaLabel = "I'm coming today";
        statusLine = "You're not marked coming";
        onCta = provider.isUpdating
            ? null
            : () => _showConfirmationDialog(context, provider, true);
      case _HeroMode.scan:
        headline = 'Scan to board';
        ctaLabel = 'Scan boarding QR';
        statusLine = "You're marked coming";
        onCta = () => _openBoardingScan(provider);
      case _HeroMode.boarded:
        headline = "You're on board";
        ctaLabel = 'Track your cab';
        statusLine = 'Boarded · track your ride';
        onCta = () => _openTrackCab(commuter);
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: cts.navy,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: cts.yellow,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                'TODAY · $time',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: context.scheme.onPrimary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            headline,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: context.scheme.onSecondary,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            meta,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: context.scheme.onSecondary.withValues(alpha: 0.88),
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
                foregroundColor: context.scheme.onPrimary,
                disabledBackgroundColor: cts.yellow.withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                ctaLabel,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: context.scheme.onPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            statusLine,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: context.scheme.onSecondary.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTripStrip(BuildContext context, CommuterModel commuter) {
    final scheme = context.scheme;
    final cts = context.cts;
    final theme = Theme.of(context);
    final batch = commuter.batchId?.batchName ?? '—';
    final time = _formatBatchTime(commuter.batchId?.batchTime);
    final pop = commuter.popId?.pickUpPointName ?? '—';
    final cab = commuter.cabId?.regNumber ?? '—';
    final adminMobile = commuter.adminCode?.userId?.mobileNumber;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cts.navy.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$batch · $time · $pop · $cab',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cts.navy,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (adminMobile != null && adminMobile.isNotEmpty)
            IconButton(
              tooltip: 'Call admin',
              visualDensity: VisualDensity.compact,
              onPressed: () => calling(adminMobile),
              icon: Icon(Icons.call_rounded, color: cts.navy, size: 20),
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
            'Coming today',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cts.navy.withValues(alpha: 0.75),
              fontWeight: FontWeight.w500,
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
          'Return tonight',
          style: theme.textTheme.titleSmall?.copyWith(
            color: cts.navy.withValues(alpha: 0.7),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Home, skip, or earlier — optional',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 10),
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
        const SizedBox(height: 8),
        TextButton(
          onPressed: (busy || provider.isJoiningWaiting)
              ? null
              : () => _offerJoinReturnWaiting(context, provider),
          child: Text(
            'Join return waiting line',
            style: TextStyle(
              color: cts.navy.withValues(alpha: 0.75),
              fontWeight: FontWeight.w600,
            ),
          ),
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
    required bool selected,
    required bool enabled,
    required VoidCallback onSelected,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final cts = context.cts;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: enabled ? (_) => onSelected() : null,
      selectedColor: cts.yellow.withValues(alpha: 0.55),
      checkmarkColor: scheme.onPrimary,
      labelStyle: TextStyle(
        color: cts.navy,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      side: BorderSide(color: cts.navy.withValues(alpha: 0.2)),
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
