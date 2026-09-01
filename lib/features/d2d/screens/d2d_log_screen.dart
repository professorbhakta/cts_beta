import 'package:cts/theme/cts_colors.dart';
import 'package:cts/appManager/app_class.dart';
import 'package:cts/appManager/functions_and_tools.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:go_router/go_router.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/d2d/helpers/client_pack_feedback.dart';
import 'package:cts/features/d2d/models/d2d_channel_role_policy.dart';
import 'package:cts/features/d2d/models/odometer_models.dart';
import 'package:cts/features/d2d/providers/d2d_channel_provider.dart';
import 'package:cts/features/d2d/repositories/d2d_repository.dart';
import 'package:cts/features/d2d/widgets/boarding_qr_panel.dart';
import 'package:cts/features/d2d/widgets/d2d_action_error_listener.dart';
import 'package:cts/features/d2d/widgets/d2d_add_commuter_sheet.dart';
import 'package:cts/features/d2d/widgets/d2d_live_widgets.dart';
import 'package:cts/features/d2d/widgets/odometer_km_sheet.dart';
import 'package:cts/features/drivers/providers/driver_home_provider.dart';
import 'package:cts/widgets/loading_indicator.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
  int? _startKm;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final driverHome = context.read<DriverHomeProvider>();
      if (driverHome.driverProfile == null) {
        driverHome.fetchDriverProfile();
      }
      _d2dProvider?.fetchTripStatus(widget.batchId);
      _d2dProvider?.connect(widget.batchId);
      _refreshStartKm();
    });
  }

  @override
  void dispose() {
    _d2dProvider?.removeListener(_onD2dProviderChanged);
    _d2dProvider?.disconnect(notify: false);
    super.dispose();
  }

  Future<void> _refreshStartKm() async {
    try {
      final repo = context.read<D2dRepository>();
      final existing = await repo.getOdometer(widget.batchId);
      if (!mounted) return;
      if (existing.isSuccess) {
        setState(() => _startKm = existing.data?.morning.startKm);
      }
    } catch (_) {}
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
    return 'Batch ${widget.batchId}';
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

  /// After live channel opens (or REST confirms active trip): prompt start KM once.
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

    // Do not wait for a WS frame — KM is REST; WS drop must not block the sheet.
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
      if (existing.isSuccess &&
          existing.data?.morning.startKm != null) {
        setState(() => _startKm = existing.data?.morning.startKm);
        return;
      }

      // Prompt once: Close/Skip → continue trip without KM; Confirm → recorded.
      final provider = _d2dProvider;
      if (provider == null || provider.isTripEnded) {
        return;
      }
      final recorded = await OdometerKmSheet.show(
        context,
        batchId: widget.batchId,
        mode: OdometerSheetMode.start,
        leg: OdometerLeg.morning,
      );
      if (recorded == true) {
        await _refreshStartKm();
      }
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

      // Skip noisy end sheet when end KM already recorded.
      var recorded = existing.isSuccess &&
          existing.data?.morning.endKm != null;

      if (!recorded) {
        // Prefer end-KM sheet; soft STOP if driver dismisses without submit.
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

  Widget _buildKmChip(BuildContext context) {
    final cts = context.cts;
    final scheme = context.scheme;
    final theme = Theme.of(context);
    final km = _startKm;
    final kmText = km == null
        ? 'Start —'
        : 'Start ${NumberFormat('#,###').format(km)} km';

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: scheme.inverseSurface,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              'KM',
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onInverseSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            kmText,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cts.navy,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Call admin',
            onPressed: _callAdmin,
            icon: Icon(Icons.call_rounded, color: cts.navy),
          ),
          IconButton(
            tooltip: 'Sort',
            onPressed: () => context.read<D2dChannelProvider>().toggleSortOrder(),
            icon: Icon(Icons.sort_rounded, color: cts.navy),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context, {
    required bool canAdd,
    required bool isLive,
  }) {
    final cts = context.cts;
    final theme = Theme.of(context);
    final provider = context.read<D2dChannelProvider>();
    final liveCommuterIds = provider.commuters
        .map((c) => c.id)
        .whereType<int>()
        .toSet();
    final alreadyInIds = provider.alreadyInCommuters
        .map((c) => c.id)
        .whereType<int>()
        .toSet();

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back',
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(RouteName.driverHomeScreen);
              }
            },
            icon: Icon(Icons.arrow_back_rounded, color: cts.navy),
          ),
          Expanded(
            child: Text(
              'Live trip · ${_batchLabel(context)}',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: cts.navy,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          D2dLiveStatusChip(isLive: isLive, prominent: true),
          const SizedBox(width: 4),
          if (canAdd)
            IconButton(
              tooltip: 'Add commuter',
              onPressed: () => D2dAddCommuterSheet.show(
                context,
                batchId: widget.batchId,
                d2dProvider: provider,
                liveCommuterIds: liveCommuterIds,
                alreadyInCommuterIds: alreadyInIds,
              ),
              icon: Icon(Icons.person_add_rounded, color: cts.navy),
            )
          else
            const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildStickyLiveTop(BuildContext context, D2dChannelProvider provider) {
    final canAdd = D2dChannelRolePolicy.can(
      SessionRole.userType,
      D2dChannelAction.addCommuter,
    );
    final isLive = provider.isChannelLive;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, canAdd: canAdd, isLive: isLive),
          D2dConnectionLostBanner(
            provider: provider,
            batchId: widget.batchId,
          ),
          BoardingQrPanel(
            batchId: widget.batchId,
            compact: true,
            enabled: !provider.isTripEnded &&
                provider.tripStatus != D2dTripStatus.ended,
          ),
          const SizedBox(height: 10),
          // High-contrast Live status ABOVE the queue — never behind the QR.
          D2dLiveStatusStrip(
            isLive: isLive,
            remainingCount: provider.commuters.length,
            boardedCount: provider.alreadyInCommuters.length,
          ),
          const SizedBox(height: 10),
          D2dTripCountsRow(
            waitingCount: provider.commuters.length,
            onBoardCount: provider.alreadyInCommuters.length,
          ),
        ],
      ),
    );
  }

  Widget _buildTripContent(BuildContext context, D2dChannelProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStickyLiveTop(context, provider),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              _buildKmChip(context),
              const SizedBox(height: 4),
              if (provider.commuters.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: StatusMessage(
                    icon: Icons.hourglass_empty_rounded,
                    title: 'No riders waiting pickup',
                    message: 'Remaining commuters will appear here.',
                  ),
                )
              else
                for (var i = 0; i < provider.commuters.length; i++)
                  D2dBoardRow(
                    commuter: provider.commuters[i],
                    provider: provider,
                    onCall: () =>
                        _callCommuter(provider.commuters[i].mobileNumber),
                    showDivider: i < provider.commuters.length - 1,
                  ),
              if (provider.waitingCommuters.isNotEmpty) ...[
                const SizedBox(height: 20),
                D2dWaitingSection(
                  commuters: provider.waitingCommuters,
                  onCall: (commuter) => _callCommuter(commuter.mobileNumber),
                ),
              ],
              if (provider.alreadyInCommuters.isNotEmpty) ...[
                const SizedBox(height: 20),
                D2dAlreadyInSection(
                  commuters: provider.alreadyInCommuters,
                  onCall: (commuter) => _callCommuter(commuter.mobileNumber),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEndTripBar(BuildContext context, D2dChannelProvider provider) {
    final cts = context.cts;
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
      color: cts.navy,
      child: SafeArea(
        top: false,
        child: InkWell(
          onTap: _stopping ? null : _stopTrip,
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: Center(
              child: _stopping
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.onSecondary,
                      ),
                    )
                  : Text(
                      'End trip',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: scheme.onSecondary,
                            fontWeight: FontWeight.w800,
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

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHighest,
      body: SafeArea(
        bottom: false,
        child: Consumer<D2dChannelProvider>(
          builder: (context, provider, child) {
            if (provider.isTripEnded) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildHeader(
                    context,
                    canAdd: false,
                    isLive: provider.isChannelLive,
                  ),
                  const SizedBox(height: 24),
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
                  _buildHeader(
                    context,
                    canAdd: false,
                    isLive: provider.isChannelLive,
                  ),
                  const SizedBox(height: 24),
                  const LoadingIndicator(),
                ],
              );
            }

            return _buildTripContent(context, provider);
          },
        ),
      ),
      bottomNavigationBar: Consumer<D2dChannelProvider>(
        builder: (context, provider, _) => _buildEndTripBar(context, provider),
      ),
    );
  }
}
