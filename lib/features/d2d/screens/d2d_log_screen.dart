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
import 'package:cts/widgets/brand_app_bar.dart';
import 'package:cts/widgets/loading_indicator.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
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
    });
  }

  @override
  void dispose() {
    _d2dProvider?.removeListener(_onD2dProviderChanged);
    _d2dProvider?.disconnect(notify: false);
    super.dispose();
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
        return;
      }

      // Prompt once: Close/Skip → continue trip without KM; Confirm → recorded.
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

  Widget _buildPreConnectBadge(BuildContext context, D2dTripStatus tripStatus) {
    final scheme = context.scheme;
    final cts = context.cts;

    if (tripStatus == D2dTripStatus.unknown ||
        tripStatus == D2dTripStatus.none) {
      return const SizedBox.shrink();
    }

    final isEnded = tripStatus == D2dTripStatus.ended;
    final color = isEnded ? scheme.error : cts.success;
    final label = isEnded ? 'TRIP ENDED TODAY' : 'TRIP ACTIVE';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildTripContent(
    BuildContext context,
    D2dChannelProvider provider,
  ) {
    final scheme = context.scheme;
    final isLive = provider.commuters.isNotEmpty;
    final liveCommuterIds = provider.commuters
        .map((c) => c.id)
        .whereType<int>()
        .toSet();
    final alreadyInIds = provider.alreadyInCommuters
        .map((c) => c.id)
        .whereType<int>()
        .toSet();
    final canAdd = D2dChannelRolePolicy.can(
      SessionRole.userType,
      D2dChannelAction.addCommuter,
    );

    return Stack(
      children: [
        ListView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + (canAdd ? 72 : 0)),
      children: [
        D2dConnectionLostBanner(
          provider: provider,
          batchId: widget.batchId,
        ),
        D2dTripHeader(
          title: 'Live trip',
          subtitle: 'Batch #${widget.batchId}',
          isLive: isLive,
        ),
        _buildPreConnectBadge(context, provider.tripStatus),
        D2dLiveControlsBar(
          callLabel: 'Call Admin',
          onCall: _callAdmin,
          isLive: isLive,
          isAscending: provider.isAscending,
          onToggleSort: provider.toggleSortOrder,
        ),
        const SizedBox(height: 16),
        BoardingQrPanel(
          batchId: widget.batchId,
          enabled: !provider.isTripEnded &&
              provider.tripStatus != D2dTripStatus.ended,
        ),
        const SizedBox(height: 16),
        Text(
          'Remaining',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        if (provider.commuters.isEmpty)
          const StatusMessage(
            icon: Icons.hourglass_empty_rounded,
            title: 'No riders waiting pickup',
            message: 'Remaining commuters will appear here.',
          )
        else ...[
          Row(
            children: [
              Text(
                '${provider.commuters.length} remaining',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.secondary,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '${provider.commuters.length}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onSecondary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < provider.commuters.length; i++) ...[
            D2dDriverCommuterTile(
              commuter: provider.commuters[i],
              provider: provider,
              onCall: () => _callCommuter(provider.commuters[i].mobileNumber),
            ),
            if (i < provider.commuters.length - 1) const SizedBox(height: 8),
          ],
        ],
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
        if (canAdd)
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              heroTag: 'd2dDriverAddCommuter',
              tooltip: 'Add commuter',
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              onPressed: () => D2dAddCommuterSheet.show(
                context,
                batchId: widget.batchId,
                d2dProvider: provider,
                liveCommuterIds: liveCommuterIds,
                alreadyInCommuterIds: alreadyInIds,
              ),
              child: Icon(Icons.person_add_rounded),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandAppBar(automaticallyImplyLeading: true),
      body: SafeArea(
        top: false,
        child: Consumer<D2dChannelProvider>(
          builder: (context, provider, child) {
            if (provider.isTripEnded) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  D2dTripHeader(
                    title: 'Live trip',
                    subtitle: 'Batch #${widget.batchId}',
                    isLive: false,
                  ),
                  _buildPreConnectBadge(context, provider.tripStatus),
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
                  D2dTripHeader(
                    title: 'Live trip',
                    subtitle: 'Batch #${widget.batchId}',
                    isLive: false,
                  ),
                  _buildPreConnectBadge(context, provider.tripStatus),
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
        builder: (context, provider, _) {
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
          return SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: _stopping ? null : _stopTrip,
                  icon: Icon(
                    Icons.stop_circle_outlined,
                    color: scheme.onError,
                  ),
                  label: Text(
                    'STOP TRIP',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: scheme.onError,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.error,
                    foregroundColor: scheme.onError,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
