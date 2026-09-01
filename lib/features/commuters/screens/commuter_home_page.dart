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

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHighest,
      drawer: const AppDrawer(),
      body: SafeArea(
        bottom: false,
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
              _ => Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => provider.fetchCommuterProfile(),
                        child: _buildBoard(context, provider),
                      ),
                    ),
                    _buildStickyActions(context, provider),
                  ],
                ),
            };
          },
        ),
      ),
    );
  }

  Widget _buildStickyActions(
    BuildContext context,
    CommuterHomeProvider provider,
  ) {
    final cts = context.cts;
    final scheme = context.scheme;
    final theme = Theme.of(context);
    final mode = _heroMode(provider);
    final profile = provider.commuterProfile;

    final ctaLabel = mode == _HeroMode.boarded
        ? 'TRACK YOUR CAB'
        : 'SCAN BOARDING QR';

    return Material(
      color: scheme.surfaceContainerHighest,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: Material(
                color: cts.yellow,
                child: InkWell(
                  onTap: profile == null
                      ? null
                      : () {
                          if (mode == _HeroMode.boarded) {
                            _openTrackCab(profile);
                          } else {
                            _openBoardingScan(provider);
                          }
                        },
                  child: Center(
                    child: Text(
                      ctaLabel,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
              child: Row(
                children: [
                  for (final entry in [
                    (0, 'Home'),
                    (1, 'Scan'),
                    (2, 'Track'),
                  ])
                    Expanded(
                      child: InkWell(
                        onTap: () => _onBottomNavTap(entry.$1, provider),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            entry.$2,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: cts.navy.withValues(
                                alpha: _navIndex == entry.$1 ? 1 : 0.55,
                              ),
                              fontWeight: _navIndex == entry.$1
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final cts = context.cts;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 4, 8),
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

  Widget _buildBoard(BuildContext context, CommuterHomeProvider provider) {
    final commuter = provider.commuterProfile!;
    final cts = context.cts;
    final theme = Theme.of(context);
    final time = _formatBatchTime(commuter.batchId?.batchTime);
    final pickup = commuter.popId?.pickUpPointName ?? 'Pickup TBD';
    final batchName = commuter.batchId?.batchName ?? 'No batch';
    final cab = commuter.cabId?.regNumber ?? 'Cab TBD';
    final adminMobile = commuter.adminCode?.userId?.mobileNumber;

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
                    _buildHeader(context),
                    const SizedBox(height: 20),
                    Text(
                      'TODAY',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cts.navy.withValues(alpha: 0.55),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
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
                      pickup,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: cts.navy,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$batchName · $cab',
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
                    const SizedBox(height: 28),
                    Divider(height: 1, thickness: 1, color: cts.navy.withValues(alpha: 0.12)),
                    _buildQuietComingToggle(context, provider, commuter),
                    if (provider.isUpdating)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                    Divider(height: 1, thickness: 1, color: cts.navy.withValues(alpha: 0.12)),
                    const SizedBox(height: 16),
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

  Widget _buildQuietComingToggle(
    BuildContext context,
    CommuterHomeProvider provider,
    CommuterModel commuter,
  ) {
    final cts = context.cts;
    final theme = Theme.of(context);
    final scheme = context.scheme;
    final isComing = commuter.isComing ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
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
      ),
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
                  onSelected: () => _saveIntent(
                    context,
                    provider,
                    () => provider.selectHomeIntent(),
                    successMessage: 'Return intent set to Home',
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: cts.navy.withValues(alpha: 0.28),
              ),
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
              Container(
                width: 1,
                height: 40,
                color: cts.navy.withValues(alpha: 0.28),
              ),
              Expanded(
                child: _returnSegment(
                  context,
                  label: 'Earlier',
                  selected: selected == ReturnIntentKind.earlier,
                  enabled: !busy,
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
              width: 18,
              height: 18,
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
  }) {
    final cts = context.cts;
    final theme = Theme.of(context);

    return Material(
      color: selected ? cts.navy.withValues(alpha: 0.08) : Colors.transparent,
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
                      ? const Icon(Icons.check)
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
    final placeholder = scheme.outline.withValues(alpha: 0.15);

    return Shimmer.fromColors(
      baseColor: scheme.outline.withValues(alpha: 0.2),
      highlightColor: scheme.surface,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(height: 24, width: 64, color: placeholder),
          const SizedBox(height: 24),
          Container(height: 72, width: 180, color: placeholder),
          const SizedBox(height: 16),
          Container(height: 22, width: 220, color: placeholder),
          const SizedBox(height: 8),
          Container(height: 16, width: 160, color: placeholder),
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
