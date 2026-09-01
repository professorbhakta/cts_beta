import 'package:cts/theme/cts_colors.dart';
import 'package:cts/appManager/snackbar_service.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:cts/appManager/functions_and_tools.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/batches/models/return_intent_model.dart';
import 'package:cts/features/commuters/models/commuter_model.dart';
import 'package:cts/features/commuters/providers/commuter_home_provider.dart';
import 'package:cts/widgets/app_drawer.dart';
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
      drawer: const AppDrawer(),
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
            indicatorColor: Colors.transparent,
            elevation: 0,
            height: 64,
            selectedIndex: _navIndex,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (i) => _onBottomNavTap(i, provider),
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: cts.navy, size: 22),
                selectedIcon: Icon(Icons.home, color: cts.navy, size: 22),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.qr_code_scanner, color: cts.navy, size: 22),
                selectedIcon:
                    Icon(Icons.qr_code_scanner, color: cts.navy, size: 22),
                label: 'Scan',
              ),
              NavigationDestination(
                icon: Icon(Icons.my_location_outlined, color: cts.navy, size: 22),
                selectedIcon:
                    Icon(Icons.my_location, color: cts.navy, size: 22),
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
      padding: const EdgeInsets.fromLTRB(0, 4, 4, 8),
      child: Row(
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
    final batchName = commuter.batchId?.batchName ?? 'No batch';
    final gate = commuter.popId?.pickUpPointName ?? 'Pickup TBD';
    final cab = commuter.cabId?.regNumber ?? 'Cab TBD';
    final time = _formatBatchTime(commuter.batchId?.batchTime);
    final meta = '$batchName · $gate · $cab';
    final adminMobile = commuter.adminCode?.userId?.mobileNumber;

    late final String headline;
    late final String ctaLabel;
    late final VoidCallback? onCta;

    switch (mode) {
      case _HeroMode.notComing:
        headline = 'Scan to board';
        ctaLabel = 'Scan boarding QR';
        onCta = () => _openBoardingScan(provider);
      case _HeroMode.scan:
        headline = 'Scan to board';
        ctaLabel = 'Scan boarding QR';
        onCta = () => _openBoardingScan(provider);
      case _HeroMode.boarded:
        headline = "You're on board";
        ctaLabel = 'Track your cab';
        onCta = () => _openTrackCab(commuter);
    }

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
                'TODAY · $time',
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
            headline,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: scheme.onSecondary,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            meta,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSecondary.withValues(alpha: 0.8),
              fontWeight: FontWeight.w400,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: FilledButton(
              onPressed: onCta,
              style: FilledButton.styleFrom(
                backgroundColor: cts.yellow,
                foregroundColor: scheme.onPrimary,
                disabledBackgroundColor: cts.yellow.withValues(alpha: 0.5),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(
                ctaLabel,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.w600,
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
    final scheme = context.scheme;
    final isComing = commuter.isComing ?? false;

    return Row(
      children: [
        Expanded(
          child: Text(
            'Coming today',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cts.navy,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Switch(
          value: isComing,
          activeThumbColor: scheme.surface,
          activeTrackColor: cts.navy,
          inactiveThumbColor: scheme.surface,
          inactiveTrackColor: cts.navy.withValues(alpha: 0.25),
          trackOutlineColor: WidgetStatePropertyAll(
            cts.navy.withValues(alpha: 0.35),
          ),
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
          'Return today',
          style: theme.textTheme.titleMedium?.copyWith(
            color: cts.navy,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: cts.navy.withValues(alpha: 0.28)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _returnSegment(
                  context,
                  label: 'Home',
                  selected: selected == ReturnIntentKind.home,
                  enabled: !busy,
                  isFirst: true,
                  onSelected: () => _saveIntent(
                    context,
                    provider,
                    () => provider.selectHomeIntent(),
                    successMessage: 'Return intent set to Home',
                  ),
                ),
              ),
              Container(width: 1, height: 40, color: cts.navy.withValues(alpha: 0.28)),
              Expanded(
                child: _returnSegment(
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
              ),
              Container(width: 1, height: 40, color: cts.navy.withValues(alpha: 0.28)),
              Expanded(
                child: _returnSegment(
                  context,
                  label: 'Earlier',
                  selected: selected == ReturnIntentKind.earlier,
                  enabled: !busy,
                  isLast: true,
                  onSelected: () => _pickEarlierBatch(context, provider),
                ),
              ),
            ],
          ),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Join return waiting line',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cts.navy,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                  decorationColor: cts.navy.withValues(alpha: 0.4),
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

  Widget _returnSegment(
    BuildContext context, {
    required String label,
    required bool selected,
    required bool enabled,
    required VoidCallback onSelected,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final cts = context.cts;
    final theme = Theme.of(context);

    return Material(
      color: selected ? cts.navy.withValues(alpha: 0.08) : Colors.transparent,
      borderRadius: BorderRadius.horizontal(
        left: isFirst ? const Radius.circular(3) : Radius.zero,
        right: isLast ? const Radius.circular(3) : Radius.zero,
      ),
      child: InkWell(
        onTap: enabled ? onSelected : null,
        child: SizedBox(
          height: 40,
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: cts.navy,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
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
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: placeholder,
                      borderRadius: BorderRadius.circular(8),
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
