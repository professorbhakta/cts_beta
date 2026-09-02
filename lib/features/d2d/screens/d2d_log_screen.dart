import 'package:cts/theme/cts_colors.dart';
import 'package:cts/appManager/app_class.dart';
import 'package:cts/appManager/colors.dart';
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
import 'package:cts/models/d2d_commuter_model.dart';
import 'package:cts/widgets/app_drawer.dart';
import 'package:cts/widgets/brand_app_bar.dart';
import 'package:cts/widgets/cts_brand_logo.dart';
import 'package:cts/widgets/loading_indicator.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Driver D2D live trip — all beta controls kept; cream stacked visual system.
///
/// Checklist (do not omit): BrandAppBar+drawer, Live Commuter Log, Batch #,
/// LIVE=`isChannelLive`, TRIP ACTIVE/ENDED, Call Admin, Sort Asc/Desc,
/// connection-lost+Retry, BoardingQrPanel+Refresh, Start KM sheet (modal only),
/// Remaining list+count, rider call/Board/swipe, Waiting line, Already IN,
/// Add commuter, STOP TRIP bar, End KM sheet on stop.
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
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<BoardingQrPanelState> _qrKey =
      GlobalKey<BoardingQrPanelState>();

  @override
  void dispose() {
    _searchController.dispose();
    _d2dProvider?.removeListener(_onD2dProviderChanged);
    _d2dProvider?.disconnect(notify: false);
    super.dispose();
  }

  List<D2dCommuterModel> _filteredRemaining(
    List<D2dCommuterModel> remaining,
  ) {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return remaining;
    return remaining.where((c) {
      final haystack = [
        c.username,
        c.mobileNumber,
        c.popId?.pickUpPointName,
      ].whereType<String>().join(' ').toLowerCase();
      return haystack.contains(q);
    }).toList();
  }
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

  void _openAddCommuter(D2dChannelProvider provider) {
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

  void _refreshQr() {
    _qrKey.currentState?.refresh();
  }

  /// After live channel opens (or REST confirms active trip): prompt start KM once.
  /// Modal only — never rendered as a live-canvas KM label.
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

  String _tripStatusLabel(D2dTripStatus tripStatus) {
    switch (tripStatus) {
      case D2dTripStatus.active:
        return 'TRIP ACTIVE';
      case D2dTripStatus.ended:
        return 'TRIP ENDED';
      case D2dTripStatus.none:
      case D2dTripStatus.unknown:
        return '';
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

    // Dense AppBar: LIVE + CALL only (Sort lives in remaining list header).
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

  Widget _buildTripContent(BuildContext context, D2dChannelProvider provider) {
    final cts = context.cts;
    final theme = Theme.of(context);
    final tripLabel = _tripStatusLabel(provider.tripStatus);
    final canAdd = D2dChannelRolePolicy.can(
      SessionRole.userType,
      D2dChannelAction.addCommuter,
    );
    final qrEnabled = !provider.isTripEnded &&
        provider.tripStatus != D2dTripStatus.ended;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
      children: [
        // 08 Connection lost + Retry
        D2dConnectionLostBanner(
          provider: provider,
          batchId: widget.batchId,
        ),
        // 02 + 05 Live Commuter Log · TRIP ACTIVE
        Text(
          tripLabel.isEmpty
              ? 'LIVE COMMUTER LOG'
              : 'LIVE COMMUTER LOG · $tripLabel',
          style: theme.textTheme.labelSmall?.copyWith(
            color: cts.navy.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        // 03 Batch # + 09 QR refresh
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                _batchLabel(context),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: cts.navy,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
            ),
            if (qrEnabled)
              TextButton(
                onPressed: _refreshQr,
                style: TextButton.styleFrom(
                  foregroundColor: cts.navy,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'QR refresh',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: cts.navy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        // 09 Boarding QR panel (+ Refresh inside panel / QR refresh above)
        BoardingQrPanel(
          key: _qrKey,
          batchId: widget.batchId,
          compact: true,
          enabled: qrEnabled,
        ),
        const SizedBox(height: 12),
        // Counts: Remaining | waiting hourglass | On board (dialogs, not inline)
        D2dTripCountsRow(
          remainingCount: provider.commuters.length,
          waitingLineCount: provider.waitingCommuters.length,
          onBoardCount: provider.alreadyInCommuters.length,
          onWaitingLineTap: provider.waitingCommuters.isEmpty
              ? null
              : () => showD2dWaitingLineDialog(
                    context,
                    commuters: provider.waitingCommuters,
                    onCall: (c) => _callCommuter(c.mobileNumber),
                  ),
          onOnBoardTap: provider.alreadyInCommuters.isEmpty
              ? null
              : () => showD2dAlreadyInDialog(
                    context,
                    commuters: provider.alreadyInCommuters,
                    onCall: (c) => _callCommuter(c.mobileNumber),
                  ),
        ),
        const SizedBox(height: 8),
        // Riders title + hairline search + Sort
        Row(
          children: [
            Text(
              'Riders',
              style: theme.textTheme.titleSmall?.copyWith(
                color: cts.navy,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _RidersHairlineSearch(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
            const SizedBox(width: 4),
            TextButton.icon(
              onPressed: provider.toggleSortOrder,
              icon: Icon(Icons.sort, color: cts.navy, size: 18),
              label: Text(
                provider.isAscending ? 'Asc' : 'Desc',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: cts.navy,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: cts.navy.withValues(alpha: 0.12),
        ),
        // Remaining riders (local search filter — does not mutate provider)
        Builder(
          builder: (context) {
            final remaining = provider.commuters;
            final visible = _filteredRemaining(remaining);
            if (remaining.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: StatusMessage(
                  icon: Icons.hourglass_empty,
                  title: 'No riders waiting pickup',
                  message: 'Remaining commuters will appear here.',
                ),
              );
            }
            if (visible.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: StatusMessage(
                  icon: Icons.search_off,
                  title: 'No matches',
                  message: 'No remaining riders match “$_searchQuery”.',
                ),
              );
            }
            return Column(
              children: [
                for (var i = 0; i < visible.length; i++)
                  D2dDriverCommuterTile(
                    commuter: visible[i],
                    provider: provider,
                    onCall: () => _callCommuter(visible[i].mobileNumber),
                    showDivider: i < visible.length - 1,
                  ),
              ],
            );
          },
        ),
        // 15 Add also available as text when FAB hidden by role
        if (canAdd) ...[
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _openAddCommuter(provider),
              icon: Icon(Icons.person_add_outlined, color: cts.navy, size: 18),
              label: Text(
                'Add commuter',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: cts.navy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
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
      // 01 App bar + drawer. Title = original c2s mark (CtsBrandLogo).
      // Actions: LIVE + CALL only (Sort in remaining list header).
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

            return _buildTripContent(context, provider);
          },
        ),
      ),
      // 15 Add commuter FAB
      floatingActionButton: Consumer<D2dChannelProvider>(
        builder: (context, provider, _) {
          final canAdd = D2dChannelRolePolicy.can(
            SessionRole.userType,
            D2dChannelAction.addCommuter,
          );
          if (!canAdd ||
              provider.isTripEnded ||
              provider.tripStatus == D2dTripStatus.ended) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton(
            heroTag: 'd2dDriverAddCommuter',
            tooltip: 'Add commuter',
            backgroundColor: scheme.surface,
            foregroundColor: cts.navy,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: BorderSide(color: cts.navy.withValues(alpha: 0.45)),
            ),
            onPressed: () => _openAddCommuter(provider),
            child: const Icon(Icons.person_add),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // 16 STOP TRIP (+ 17 End KM sheet inside _stopTrip)
      bottomNavigationBar: Consumer<D2dChannelProvider>(
        builder: (context, provider, _) =>
            _buildStopTripBar(context, provider),
      ),
    );
  }
}

/// Compact hairline search on the Riders row — no grey boxed field.
class _RidersHairlineSearch extends StatelessWidget {
  const _RidersHairlineSearch({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final cts = context.cts;
    final idle = cts.navy.withValues(alpha: 0.2);

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return TextField(
          controller: controller,
          onChanged: onChanged,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cts.navy,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: scheme.primary,
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Search',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: cts.navy.withValues(alpha: 0.35),
            ),
            prefixIcon: Icon(
              Icons.search,
              size: 18,
              color: cts.navy.withValues(alpha: 0.45),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 28,
              minHeight: 28,
            ),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                    icon: Icon(
                      Icons.close,
                      size: 16,
                      color: cts.navy.withValues(alpha: 0.45),
                    ),
                  ),
            border: InputBorder.none,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: idle, width: 1),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: scheme.primary, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        );
      },
    );
  }
}
