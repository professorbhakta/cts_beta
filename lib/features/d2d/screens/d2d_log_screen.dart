import 'package:cts/theme/cts_colors.dart';
import 'package:cts/appManager/app_class.dart';
import 'package:cts/appManager/colors.dart';
import 'package:cts/appManager/functions_and_tools.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:go_router/go_router.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/commuters/repositories/commuter_repository.dart';
import 'package:cts/features/d2d/helpers/client_pack_feedback.dart';
import 'package:cts/features/d2d/helpers/d2d_batch_membership.dart';
import 'package:cts/features/d2d/helpers/d2d_batch_membership_loader.dart';
import 'package:cts/features/d2d/helpers/d2d_board_beep.dart';
import 'package:cts/features/d2d/models/d2d_channel_role_policy.dart';
import 'package:cts/features/d2d/models/odometer_models.dart';
import 'package:cts/features/d2d/providers/d2d_channel_provider.dart';
import 'package:cts/features/d2d/repositories/d2d_repository.dart';
import 'package:cts/features/d2d/widgets/boarding_qr_panel.dart';
import 'package:cts/features/d2d/widgets/d2d_action_error_listener.dart';
import 'package:cts/features/d2d/widgets/d2d_cream_trip_body.dart';
import 'package:cts/features/d2d/widgets/d2d_live_widgets.dart';
import 'package:cts/features/d2d/widgets/odometer_km_sheet.dart';
import 'package:cts/features/drivers/providers/driver_home_provider.dart';
import 'package:cts/widgets/app_drawer.dart';
import 'package:cts/widgets/brand_app_bar.dart';
import 'package:cts/widgets/cts_brand_logo.dart';
import 'package:cts/widgets/loading_indicator.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Driver D2D live trip — cream stacked visual system (shared body widgets).
///
/// Driver: QR + KM + STOP + Board/Remove + Call Admin. No Add Commuter.
class D2DLogScreen extends StatefulWidget {
  const D2DLogScreen({super.key, required this.batchId});

  final String batchId;

  @override
  State<D2DLogScreen> createState() => _D2DLogScreenState();
}

class _D2DLogScreenState extends State<D2DLogScreen> {
  D2dChannelProvider? _d2dProvider;
  bool _startKmPrompted = false;
  bool _startKmSheetOpen = false;
  bool _stopping = false;
  final GlobalKey<BoardingQrPanelState> _qrKey =
      GlobalKey<BoardingQrPanelState>();
  D2dBatchMembershipLoader? _membershipLoader;
  D2dBatchMembership _membership = D2dBatchMembership.empty();
  Set<int> _seenAlreadyInIds = {};
  bool _alreadyInHydrated = false;

  @override
  void dispose() {
    _d2dProvider?.removeListener(_onD2dProviderChanged);
    _d2dProvider?.disconnect(notify: false);
    super.dispose();
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final driverHome = context.read<DriverHomeProvider>();
      if (driverHome.driverProfile == null) {
        driverHome.fetchDriverProfile();
      }
      _membershipLoader ??=
          D2dBatchMembershipLoader(context.read<CommuterRepository>());
      _d2dProvider?.fetchTripStatus(widget.batchId);
      _d2dProvider?.connect(widget.batchId);
      final membership = await _membershipLoader!.ensureLoaded();
      if (!mounted) return;
      setState(() => _membership = membership);
    });
  }

  String? _adminMobile(BuildContext context) {
    final driverProfile = context.read<DriverHomeProvider>().driverProfile;
    final fromProfile = driverProfile?.adminCode?.userId?.mobileNumber;
    if (fromProfile != null && fromProfile.isNotEmpty) {
      return fromProfile;
    }

    final fromChannel =
        context.read<D2dChannelProvider>().driver?.adminCode?.userId?.mobileNumber;
    if (fromChannel != null && fromChannel.isNotEmpty) {
      return fromChannel;
    }

    return null;
  }

  String _batchLabel(BuildContext context) {
    final fromDriver =
        context.read<DriverHomeProvider>().driverProfile?.batchId?.batchName;
    if (fromDriver != null && fromDriver.trim().isNotEmpty) {
      return fromDriver.trim();
    }
    return 'Batch #${widget.batchId}';
  }

  Future<void> _callAdmin() async {
    final mobile = _adminMobile(context);
    if (mobile == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin contact is not available yet.'),
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

  void _refreshQr() {
    _qrKey.currentState?.refresh();
  }

  void _maybePromptStartKm() {
    final provider = _d2dProvider;
    if (provider == null ||
        _startKmPrompted ||
        _startKmSheetOpen ||
        provider.isTripEnded) {
      return;
    }
    final canDrive = D2dChannelRolePolicy.can(
      SessionRole.userType,
      D2dChannelAction.stopTrip,
    );
    if (!canDrive) return;

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
      if (provider == null || provider.isTripEnded) {
        return;
      }
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

  Future<void> _stopTrip() async {
    if (_stopping) return;
    _stopping = true;
    try {
      final repo = context.read<D2dRepository>();
      final existing = await repo.getOdometer(widget.batchId);
      if (!mounted) return;

      var recorded =
          existing.isSuccess && existing.data?.morning.endKm != null;

      if (!recorded) {
        recorded = await OdometerKmSheet.show(
              context,
              batchId: widget.batchId,
              mode: OdometerSheetMode.end,
              leg: OdometerLeg.morning,
            ) ==
            true;
      }

      if (!mounted) return;
      if (!recorded) {
        final force = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('End KM not recorded'),
            content: const Text(
              'Stop the trip anyway? You can still stop without end KM '
              '(soft stop).',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Stop anyway'),
              ),
            ],
          ),
        );
        if (force != true || !mounted) return;
        ClientPackFeedback.showError(
          'Trip stopped without end KM. Record later if needed.',
        );
      }

      _d2dProvider?.stopTrip();
      if (!mounted) return;
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(RouteName.driverHomeScreen);
      }
    } finally {
      _stopping = false;
    }
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
        onPressed: _callAdmin,
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

  Widget _buildStopTripBar(BuildContext context, D2dChannelProvider provider) {
    final scheme = context.scheme;
    final canStop = D2dChannelRolePolicy.can(
      SessionRole.userType,
      D2dChannelAction.stopTrip,
    );
    if (!canStop ||
        provider.isTripEnded ||
        provider.tripStatus == D2dTripStatus.ended) {
      return const SizedBox.shrink();
    }

    return Material(
      color: AppColors.acBlack,
      child: SafeArea(
        top: false,
        child: InkWell(
          onTap: _stopping ? null : _stopTrip,
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: Center(
              child: _stopping
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.surface,
                      ),
                    )
                  : Text(
                      'STOP TRIP',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: scheme.surface,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final cts = context.cts;

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
          builder: (context, provider, child) {
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
                    _batchLabel(context),
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
                ],
              );
            }

            final showInitialLoading = provider.state == ViewState.loading &&
                !provider.connectionLost &&
                provider.commuters.isEmpty &&
                provider.alreadyInCommuters.isEmpty &&
                provider.tripStatus == D2dTripStatus.unknown;

            if (showInitialLoading) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'LIVE COMMUTER LOG',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cts.navy.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                  ),
                  const SizedBox(height: 24),
                  const LoadingIndicator(),
                ],
              );
            }

            return D2dCreamTripBody(
              batchId: widget.batchId,
              provider: provider,
              batchLabel: _batchLabel(context),
              membership: _membership,
              onCallCommuter: _callCommuter,
              showQr: true,
              qrKey: _qrKey,
              onRefreshQr: _refreshQr,
              showAddCommuter: false,
              showStartKmAction: false,
            );
          },
        ),
      ),
      bottomNavigationBar: Consumer<D2dChannelProvider>(
        builder: (context, provider, _) =>
            _buildStopTripBar(context, provider),
      ),
    );
  }
}
