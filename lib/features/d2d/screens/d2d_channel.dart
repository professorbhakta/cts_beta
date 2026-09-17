import 'package:cts/theme/cts_colors.dart';
import 'package:cts/appManager/app_class.dart';
import 'package:cts/appManager/functions_and_tools.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/admin_home/providers/admin_provider.dart';
import 'package:cts/features/batches/providers/running_batch_provider.dart';
import 'package:cts/features/commuters/repositories/commuter_repository.dart';
import 'package:cts/features/d2d/helpers/d2d_batch_membership.dart';
import 'package:cts/features/d2d/helpers/d2d_batch_membership_loader.dart';
import 'package:cts/features/d2d/helpers/d2d_board_beep.dart';
import 'package:cts/features/d2d/models/d2d_channel_role_policy.dart';
import 'package:cts/features/d2d/models/odometer_models.dart';
import 'package:cts/features/d2d/providers/d2d_channel_provider.dart';
import 'package:cts/features/d2d/repositories/d2d_repository.dart';
import 'package:cts/features/d2d/widgets/d2d_action_error_listener.dart';
import 'package:cts/features/d2d/widgets/d2d_add_commuter_sheet.dart';
import 'package:cts/features/d2d/widgets/d2d_cream_trip_body.dart';
import 'package:cts/features/d2d/widgets/d2d_live_widgets.dart';
import 'package:cts/features/d2d/widgets/odometer_km_sheet.dart';
import 'package:cts/widgets/app_drawer.dart';
import 'package:cts/widgets/brand_app_bar.dart';
import 'package:cts/widgets/cts_brand_logo.dart';
import 'package:cts/widgets/loading_indicator.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Admin / Supervisor morning live monitor — cream stacked UI (shared body).
///
/// No boarding QR. Add = ADMIN/SUPERVISOR only. Leave = disconnect only.
class D2dChannel extends StatefulWidget {
  final String batchId;
  const D2dChannel({super.key, required this.batchId});

  @override
  State<D2dChannel> createState() => _D2dChannelState();
}

class _D2dChannelState extends State<D2dChannel> {
  D2dChannelProvider? _d2dProvider;
  bool _didSyncAfterTripEnd = false;
  D2dBatchMembershipLoader? _membershipLoader;
  D2dBatchMembership _membership = D2dBatchMembership.empty();
  Set<int> _seenAlreadyInIds = {};
  bool _alreadyInHydrated = false;
  bool _startKmPrompted = false;
  bool _startKmSheetOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _membershipLoader ??=
          D2dBatchMembershipLoader(context.read<CommuterRepository>());
      _d2dProvider?.connect(widget.batchId);
      final membership = await _membershipLoader!.ensureLoaded();
      if (!mounted) return;
      setState(() => _membership = membership);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _membershipLoader ??=
        D2dBatchMembershipLoader(context.read<CommuterRepository>());
    final provider = context.read<D2dChannelProvider>();
    attachD2dActionErrorListener(
      current: _d2dProvider,
      next: provider,
      listener: _onD2dProviderChanged,
    );
    _d2dProvider = provider;
  }

  void _onD2dProviderChanged() {
    if (!mounted) return;
    handleD2dActionError(context, _d2dProvider);
    _syncRunningListIfTripEnded();
    _maybePromptStartKm();
    _beepNewAlreadyIn();
  }

  void _beepNewAlreadyIn() {
    final provider = _d2dProvider;
    if (provider == null) return;
    final current = provider.alreadyInCommuters
        .map((c) => c.id)
        .whereType<int>()
        .toSet();
    final newcomers = d2dNewAlreadyInIds(
      previous: _seenAlreadyInIds,
      current: current,
      skipBecauseInitialHydrate: !_alreadyInHydrated,
    );
    _seenAlreadyInIds = current;
    _alreadyInHydrated = true;
    final kind = d2dBoardBeepForNewcomers(
      newcomers: newcomers,
      isOtherBatch: (id) {
        String? knownHome;
        for (final c in provider.alreadyInCommuters) {
          if (c.id == id) {
            knownHome = c.homeBatchId;
            break;
          }
        }
        return _membership.isOtherBatch(
          id,
          widget.batchId,
          knownHomeBatchId: knownHome,
        );
      },
    );
    if (kind != null) {
      D2dBoardBeep.instance.play(kind);
    }
  }

  void _syncRunningListIfTripEnded() {
    if (_didSyncAfterTripEnd) return;
    if (_d2dProvider?.isTripEnded != true) return;
    _didSyncAfterTripEnd = true;
    context.read<RunningBatchProvider>().fetchOnce();
    context.read<AdminProvider>().refreshRunningBatches();
  }

  void _maybePromptStartKm() {
    final provider = _d2dProvider;
    if (provider == null ||
        _startKmPrompted ||
        _startKmSheetOpen ||
        provider.isTripEnded) {
      return;
    }
    // Admin/Supervisor may record KM; SUPER_ADMIN monitor may also open sheet.
    final tripReady = provider.state == ViewState.success ||
        provider.tripStatus == D2dTripStatus.active ||
        (provider.connectedBatchId != null && !provider.isTripEnded);
    if (!tripReady) return;

    _startKmPrompted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showStartKmSheet();
    });
  }

  Future<void> _showStartKmSheet() async {
    if (_startKmSheetOpen || !mounted) return;
    _startKmSheetOpen = true;
    try {
      final repo = context.read<D2dRepository>();
      final existing = await repo.getOdometer(widget.batchId);
      if (!mounted) return;
      if (existing.isSuccess && existing.data?.morning.startKm != null) {
        return;
      }
      final provider = _d2dProvider;
      if (provider == null || provider.isTripEnded) return;
      await OdometerKmSheet.show(
        context,
        batchId: widget.batchId,
        mode: OdometerSheetMode.start,
        leg: OdometerLeg.morning,
      );
    } finally {
      _startKmSheetOpen = false;
    }
  }

  @override
  void dispose() {
    _d2dProvider?.removeListener(_onD2dProviderChanged);
    _d2dProvider?.disconnect(notify: false);
    super.dispose();
  }

  void _leaveChannel() {
    context.read<RunningBatchProvider>().fetchOnce();
    context.read<AdminProvider>().refreshRunningBatches();
    _d2dProvider?.disconnect(notify: false);
    Navigator.of(context).pop();
  }

  Future<void> _callDriver(D2dChannelProvider provider) async {
    final mobile = provider.driverMobile;
    if (mobile == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Driver contact is not available for this batch yet.'),
        ),
      );
      return;
    }

    final launched = await calling(mobile);
    if (!mounted || launched) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open the phone dialer.')),
    );
  }

  Future<void> _callCommuter(String? mobile) async {
    if (mobile == null || mobile.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commuter contact is not available.')),
      );
      return;
    }
    final launched = await calling(mobile);
    if (!mounted || launched) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open the phone dialer.')),
    );
  }

  String _batchLabel(D2dChannelProvider provider) {
    final name = provider.driverName;
    if (name != null && name.isNotEmpty) {
      return 'Batch #${widget.batchId} · $name';
    }
    return 'Batch #${widget.batchId}';
  }

  List<Widget> _buildAppBarActions(
    BuildContext context,
    D2dChannelProvider provider,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fg = theme.appBarTheme.foregroundColor ?? scheme.onInverseSurface;
    final isLive = provider.isChannelLive;

    return [
      Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Center(
          child: D2dLiveStatusChip(
            isLive: isLive,
            prominent: true,
            onAppBar: true,
          ),
        ),
      ),
      TextButton(
        onPressed: () => _callDriver(provider),
        style: TextButton.styleFrom(
          foregroundColor: fg,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'CALL',
          style: theme.textTheme.labelLarge?.copyWith(
            color: fg,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
      ),
      const SizedBox(width: 4),
    ];
  }

  void _openAdd(D2dChannelProvider provider) {
    final liveCommuterIds =
        provider.commuters.map((c) => c.id).whereType<int>().toSet();
    final alreadyInIds =
        provider.alreadyInCommuters.map((c) => c.id).whereType<int>().toSet();
    D2dAddCommuterSheet.show(
      context,
      batchId: widget.batchId,
      d2dProvider: provider,
      liveCommuterIds: liveCommuterIds,
      alreadyInCommuterIds: alreadyInIds,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final cts = context.cts;
    final canAdd = D2dChannelRolePolicy.can(
      SessionRole.userType,
      D2dChannelAction.addCommuter,
    );

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHighest,
      drawer: const AppDrawer(),
      appBar: PreferredSize(
        preferredSize: const BrandAppBar().preferredSize,
        child: Consumer<D2dChannelProvider>(
          builder: (context, provider, _) {
            final theme = Theme.of(context);
            final scheme = theme.colorScheme;
            final fg =
                theme.appBarTheme.foregroundColor ?? scheme.onInverseSurface;

            return AppBar(
              centerTitle: BrandAppBar.platformCentersTitle,
              backgroundColor: theme.appBarTheme.backgroundColor,
              foregroundColor: fg,
              iconTheme: IconThemeData(color: fg),
              actionsIconTheme: IconThemeData(color: fg),
              leading: Builder(
                builder: (btnContext) => IconButton(
                  tooltip: 'Menu',
                  icon: Icon(Icons.menu, color: fg),
                  onPressed: () => Scaffold.of(btnContext).openDrawer(),
                ),
              ),
              title: const CtsBrandLogo(height: 32),
              actions: _buildAppBarActions(context, provider),
            );
          },
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Consumer<D2dChannelProvider>(
          builder: (context, provider, _) {
            if (provider.isTripEnded) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'LIVE COMMUTER LOG · TRIP ENDED',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.error,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _batchLabel(provider),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: cts.navy,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 16),
                  StatusMessage.error(
                    title: provider.errorMessage ?? 'This trip has ended.',
                    onRetry: null,
                  ),
                  TextButton(
                    onPressed: _leaveChannel,
                    child: const Text('Go back'),
                  ),
                ],
              );
            }

            final showInitialLoading = provider.state == ViewState.loading &&
                !provider.connectionLost &&
                provider.commuters.isEmpty &&
                provider.alreadyInCommuters.isEmpty &&
                provider.tripStatus == D2dTripStatus.unknown;

            if (showInitialLoading) {
              return const LoadingIndicator(height: 280);
            }

            if (provider.state == ViewState.error &&
                provider.commuters.isEmpty &&
                provider.alreadyInCommuters.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StatusMessage.error(
                    title:
                        provider.errorMessage ?? 'Unable to connect to channel.',
                    onRetry: provider.isTripEnded
                        ? null
                        : () => provider.connect(widget.batchId),
                  ),
                  TextButton(
                    onPressed: _leaveChannel,
                    child: const Text('Go back'),
                  ),
                ],
              );
            }

            return D2dCreamTripBody(
              batchId: widget.batchId,
              provider: provider,
              batchLabel: _batchLabel(provider),
              membership: _membership,
              onCallCommuter: _callCommuter,
              showQr: false,
              // Add is FAB-only on admin channel (avoid cream + FAB duplicate).
              showAddCommuter: false,
              showStartKmAction: true,
              bottomPadding: canAdd ? 100 : 88,
            );
          },
        ),
      ),
      floatingActionButton: Consumer<D2dChannelProvider>(
        builder: (context, provider, _) {
          if (!canAdd ||
              provider.isTripEnded ||
              provider.tripStatus == D2dTripStatus.ended) {
            return FloatingActionButton.extended(
              heroTag: 'd2dCloseChannel',
              onPressed: _leaveChannel,
              backgroundColor: scheme.error,
              foregroundColor: scheme.surface,
              icon: const Icon(Icons.close_rounded),
              label: const Text('Close channel'),
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: 'd2dAddCommuter',
                tooltip: 'Add commuter',
                backgroundColor: scheme.surface,
                foregroundColor: cts.navy,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: BorderSide(color: cts.navy.withValues(alpha: 0.45)),
                ),
                onPressed: () => _openAdd(provider),
                child: const Icon(Icons.person_add),
              ),
              const SizedBox(height: 12),
              FloatingActionButton.extended(
                heroTag: 'd2dCloseChannel',
                onPressed: _leaveChannel,
                backgroundColor: scheme.error,
                foregroundColor: scheme.surface,
                icon: const Icon(Icons.close_rounded),
                label: const Text('Close channel'),
              ),
            ],
          );
        },
      ),
    );
  }
}
