import 'package:cts/theme/cts_colors.dart';
import 'package:cts/appManager/colors.dart';
import 'package:cts/appManager/functions_and_tools.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/batches/providers/return_batch_provider.dart';
import 'package:cts/features/commuters/models/commuter_model.dart';
import 'package:cts/widgets/app_drawer.dart';
import 'package:cts/widgets/brand_app_bar.dart';
import 'package:cts/widgets/loading_indicator.dart';
import 'package:cts/widgets/search_bar_widget.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class ReturnCommuterListScreen extends StatefulWidget {
  const ReturnCommuterListScreen({
    super.key,
    required this.batchId,
    this.readOnly = false,
    this.canConfirmAvailable = true,
    this.canRemoveConfirmed = false,
    this.canEndTrip = false,
  });

  final String batchId;
  final bool readOnly;
  final bool canConfirmAvailable;
  final bool canRemoveConfirmed;
  final bool canEndTrip;

  @override
  State<ReturnCommuterListScreen> createState() =>
      _ReturnCommuterListScreenState();
}

class _ReturnCommuterListScreenState extends State<ReturnCommuterListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<ReturnBatchProvider>().beginReturnTripLoad(widget.batchId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ReturnBatchProvider>().loadReturnTrip(widget.batchId);
    });
  }

  @override
  void didUpdateWidget(covariant ReturnCommuterListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.batchId != widget.batchId) {
      context.read<ReturnBatchProvider>().beginReturnTripLoad(widget.batchId);
      context.read<ReturnBatchProvider>().loadReturnTrip(widget.batchId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    context.read<ReturnBatchProvider>().clearActiveBatch();
    super.dispose();
  }

  Future<void> _refresh() async {
    await context.read<ReturnBatchProvider>().loadReturnTrip(
      widget.batchId,
      keepExistingData: true,
    );
  }

  Future<void> _confirmCommuter(
    ReturnBatchProvider provider,
    CommuterModel commuter,
  ) async {
    final userId = commuter.userId?.id?.toString();
    if (userId == null) return;

    final message = await provider.confirmCommuter(userId, widget.batchId);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message ?? 'Commuter confirmed for return')),
    );
  }

  Future<void> _removeCommuter(
    ReturnBatchProvider provider,
    CommuterModel commuter,
  ) async {
    final userId = commuter.userId?.id?.toString();
    if (userId == null) return;

    final message = await provider.removeCommuter(userId, widget.batchId);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message ?? 'Commuter removed from return list')),
    );
  }

  Future<void> _endReturnTrip(ReturnBatchProvider provider) async {
    final scheme = context.scheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('End return trip?'),
        content: const Text(
          'This clears today\'s confirmed return list. Commuters can be confirmed again after refresh.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: scheme.error),
            child: const Text('End trip'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final error = await provider.endReturnTrip(widget.batchId);
    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Return trip ended')));
    Navigator.of(context).pop();
  }

  String _headline() {
    return 'Return list';
  }

  String _emptyMessage({
    required String defaultMessage,
    required bool isActive,
  }) {
    if (!widget.readOnly || isActive) return defaultMessage;
    return 'Today\'s return trip is not active. Pull to refresh for updates.';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHighest,
      appBar: const BrandAppBar(),
      drawer: const AppDrawer(),
      body: SafeArea(
        bottom: false,
        child: Consumer<ReturnBatchProvider>(
          builder: (context, provider, _) {
            if (!provider.isDisplayingBatch(widget.batchId)) {
              return const LoadingIndicator();
            }

            if (provider.state == ViewState.loading &&
                !provider.hasTripData) {
              return const LoadingIndicator();
            }

            if (provider.state == ViewState.error) {
              return StatusMessage.error(
                title: provider.errorMessage ?? 'Unable to load return trip',
                onRetry: _refresh,
              );
            }

            final capacity = provider.capacity;
            final remaining = capacity?.remainingCapacity ?? 0;
            final total = capacity?.totalCapacity ?? 0;
            final status = provider.statusForBatch(widget.batchId);
            final isActive = capacity?.isActive ?? status?.isActive ?? false;
            final cts = context.cts;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _headline(),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: cts.navy,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Batch #${widget.batchId}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: cts.navy.withValues(alpha: 0.65),
                                  ),
                            ),
                            const SizedBox(height: 12),
                            _CapacityBanner(
                              remaining: remaining,
                              total: total,
                              confirmedCount: capacity?.confirmedCount ?? 0,
                              isActive: isActive,
                              homeHold: status?.homeHold,
                              overflowConfirmed: status?.overflowConfirmed,
                              overflowRemaining: status?.overflowRemaining,
                              cutoffApplied: status?.cutoffApplied ?? false,
                            ),
                          ],
                        ),
                      ),
                      if (provider.waitingCommuters.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: _ReturnWaitingSection(
                            commuters: provider.waitingCommuters,
                          ),
                        ),
                      TabBar(
                        controller: _tabController,
                        labelColor: cts.navy,
                        unselectedLabelColor: cts.navy.withValues(alpha: 0.5),
                        indicatorColor: cts.navy,
                        tabs: [
                          Tab(
                            text:
                                'Available (${provider.availableCommuters.length})',
                          ),
                          Tab(
                            text:
                                'Confirmed (${provider.confirmedCommuters.length})',
                          ),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _AvailableListTab(
                              home: provider.homeCommuters,
                              overflow: provider.overflowCommuters,
                              emptyMessage: _emptyMessage(
                                defaultMessage:
                                    'Commuters marked Coming today appear here. Home shows this batch, Overflow shows other-batch riders.',
                                isActive: isActive,
                              ),
                              onConfirm: (commuter) =>
                                  _confirmCommuter(provider, commuter),
                              onRefresh: _refresh,
                              actionInProgress: provider.actionInProgress,
                              readOnly: widget.readOnly,
                              canConfirm: widget.canConfirmAvailable,
                              overflowConfirmAllowed: status == null ||
                                  !status.hasPoolExtras ||
                                  (status.overflowRemaining ?? 0) > 0,
                            ),
                            _CommuterListTab(
                              commuters: provider.confirmedCommuters,
                              emptyTitle: 'No confirmed commuters',
                              emptyMessage: _emptyMessage(
                                defaultMessage:
                                    'Confirm riders from the Available tab. The driver can then manage the confirmed list.',
                                isActive: isActive,
                              ),
                              actionLabel: 'Remove',
                              actionColor: scheme.error,
                              actionIcon: Icons.remove_circle_outline,
                              onAction: (commuter) =>
                                  _removeCommuter(provider, commuter),
                              onRefresh: _refresh,
                              actionInProgress: provider.actionInProgress,
                              readOnly: widget.readOnly ||
                                  !widget.canRemoveConfirmed,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.canEndTrip &&
                    !widget.readOnly &&
                    provider.state == ViewState.success)
                  Material(
                    color: AppColors.acBlack,
                    child: SafeArea(
                      top: false,
                      child: InkWell(
                        onTap: provider.actionInProgress
                            ? null
                            : () => _endReturnTrip(provider),
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: Center(
                            child: Text(
                              'END RETURN',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: scheme.surface,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.8,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AvailableListTab extends StatefulWidget {
  const _AvailableListTab({
    required this.home,
    required this.overflow,
    required this.emptyMessage,
    required this.onConfirm,
    required this.onRefresh,
    required this.actionInProgress,
    required this.canConfirm,
    required this.overflowConfirmAllowed,
    this.readOnly = false,
  });

  final List<CommuterModel> home;
  final List<CommuterModel> overflow;
  final String emptyMessage;
  final ValueChanged<CommuterModel> onConfirm;
  final Future<void> Function() onRefresh;
  final bool actionInProgress;
  final bool canConfirm;
  final bool overflowConfirmAllowed;
  final bool readOnly;

  @override
  State<_AvailableListTab> createState() => _AvailableListTabState();
}

class _AvailableListTabState extends State<_AvailableListTab> {
  String _searchQuery = '';

  List<CommuterModel> _filter(List<CommuterModel> commuters) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return commuters;
    return commuters.where((commuter) {
      final haystack = [
        commuter.userId?.username,
        commuter.userId?.mobileNumber,
        commuter.popId?.pickUpPointName,
        commuter.batchId?.batchName,
      ].whereType<String>().join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {

    final home = _filter(widget.home);
    final overflow = _filter(widget.overflow);
    final isEmpty = widget.home.isEmpty && widget.overflow.isEmpty;

    if (isEmpty) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            StatusMessage(
              icon: Icons.people_outline,
              title: 'No commuters available',
              message: widget.emptyMessage,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        SearchBarWidget(
          hintText: 'Search name, mobile, batch, or POP...',
          debounceDuration: const Duration(milliseconds: 200),
          onSearchChanged: (query) {
            setState(() => _searchQuery = query);
          },
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: widget.onRefresh,
            child: home.isEmpty && overflow.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      StatusMessage(
                        icon: Icons.search_off,
                        title: 'No commuters match your search',
                      ),
                    ],
                  )
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _sectionHeader(context, 'Home', home.length),
                      if (home.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text('No Coming-today commuters for this batch.'),
                        )
                      else
                        for (final commuter in home)
                          _availableTile(
                            commuter,
                            confirmAllowed: true,
                          ),
                      _sectionHeader(context, 'Overflow', overflow.length),
                      if (overflow.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text('No other-batch Coming-today commuters waiting.'),
                        )
                      else
                        for (final commuter in overflow)
                          _availableTile(
                            commuter,
                            confirmAllowed: widget.overflowConfirmAllowed,
                          ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(BuildContext context, String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        '$title ($count)',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _availableTile(
    CommuterModel commuter, {
    required bool confirmAllowed,
  }) {
    final cts = context.cts;
    final mobile = commuter.userId?.mobileNumber ?? '';
    final pop = commuter.popId?.pickUpPointName ?? 'N/A';
    final batch = commuter.batchId?.batchName;
    final subtitle = batch == null || batch.isEmpty ? pop : '$pop • $batch';
    final tile = ListTile(
      title: Text(commuter.userId?.username ?? 'N/A'),
      subtitle: Text(subtitle),
      trailing: IconButton(
        tooltip: 'Call commuter',
        icon: Icon(Icons.call),
        onPressed: mobile.isEmpty ? null : () => calling(mobile),
      ),
    );

    if (widget.readOnly || !widget.canConfirm || !confirmAllowed) {
      return tile;
    }

    return Slidable(
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: widget.actionInProgress
                ? null
                : (_) => widget.onConfirm(commuter),
            backgroundColor: cts.success,
            foregroundColor: context.scheme.onInverseSurface,
            icon: Icons.check_circle_outline,
            label: 'Confirm',
          ),
        ],
      ),
      child: tile,
    );
  }
}

class _CapacityBanner extends StatelessWidget {
  const _CapacityBanner({
    required this.remaining,
    required this.total,
    required this.confirmedCount,
    required this.isActive,
    this.homeHold,
    this.overflowConfirmed,
    this.overflowRemaining,
    this.cutoffApplied = false,
  });

  final int remaining;
  final int total;
  final int confirmedCount;
  final bool isActive;
  final int? homeHold;
  final int? overflowConfirmed;
  final int? overflowRemaining;
  final bool cutoffApplied;

  bool get _hasPoolExtras =>
      homeHold != null &&
      overflowConfirmed != null &&
      overflowRemaining != null;

  @override
  Widget build(BuildContext context) {
    final cts = context.cts;
    final theme = Theme.of(context);
    final hairline = cts.navy.withValues(alpha: 0.12);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: hairline),
          bottom: BorderSide(color: hairline),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$remaining of $total seats remaining',
              style: theme.textTheme.titleSmall?.copyWith(
                color: cts.navy,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$confirmedCount confirmed${isActive ? ' · trip active' : ''}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cts.navy.withValues(alpha: 0.65),
              ),
            ),
            if (_hasPoolExtras)
              Text(
                'Home hold $homeHold · Overflow in $overflowConfirmed · Overflow open $overflowRemaining'
                '${cutoffApplied ? ' · Holds released (T−15)' : ''}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cts.navy.withValues(alpha: 0.55),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}

class _CommuterListTab extends StatefulWidget {
  const _CommuterListTab({
    required this.commuters,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.actionLabel,
    required this.actionColor,
    required this.actionIcon,
    required this.onAction,
    required this.onRefresh,
    required this.actionInProgress,
    this.readOnly = false,
  });

  final List<CommuterModel> commuters;
  final String emptyTitle;
  final String emptyMessage;
  final String actionLabel;
  final Color actionColor;
  final IconData actionIcon;
  final ValueChanged<CommuterModel> onAction;
  final Future<void> Function() onRefresh;
  final bool actionInProgress;
  final bool readOnly;

  @override
  State<_CommuterListTab> createState() => _CommuterListTabState();
}

class _CommuterListTabState extends State<_CommuterListTab> {
  String _searchQuery = '';

  List<CommuterModel> get _visibleCommuters {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return widget.commuters;
    return widget.commuters.where((commuter) {
      final haystack = [
        commuter.userId?.username,
        commuter.userId?.mobileNumber,
        commuter.popId?.pickUpPointName,
        commuter.batchId?.batchName,
      ].whereType<String>().join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {

    if (widget.commuters.isEmpty) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            StatusMessage(
              icon: Icons.people_outline,
              title: widget.emptyTitle,
              message: widget.emptyMessage,
            ),
          ],
        ),
      );
    }

    final visible = _visibleCommuters;

    return Column(
      children: [
        SearchBarWidget(
          hintText: 'Search name, mobile, batch, or POP...',
          debounceDuration: const Duration(milliseconds: 200),
          onSearchChanged: (query) {
            setState(() => _searchQuery = query);
          },
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: widget.onRefresh,
            child: visible.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      StatusMessage(
                        icon: Icons.search_off,
                        title: 'No commuters match your search',
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final commuter = visible[index];
                      final mobile = commuter.userId?.mobileNumber ?? '';
                      final pop = commuter.popId?.pickUpPointName ?? 'N/A';
                      final batch = commuter.batchId?.batchName;
                      final subtitle = batch == null || batch.isEmpty
                          ? pop
                          : '$pop • $batch';

                      final tile = ListTile(
                        title: Text(commuter.userId?.username ?? 'N/A'),
                        subtitle: Text(subtitle),
                        trailing: IconButton(
                          tooltip: 'Call commuter',
                          icon: Icon(Icons.call),
                          onPressed: mobile.isEmpty
                              ? null
                              : () => calling(mobile),
                        ),
                      );

                      if (widget.readOnly) return tile;

                      return Slidable(
                        endActionPane: ActionPane(
                          motion: const StretchMotion(),
                          children: [
                            SlidableAction(
                              onPressed: widget.actionInProgress
                                  ? null
                                  : (_) => widget.onAction(commuter),
                              backgroundColor: widget.actionColor,
                              icon: widget.actionIcon,
                              label: widget.actionLabel,
                            ),
                          ],
                        ),
                        child: tile,
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _ReturnWaitingSection extends StatelessWidget {
  const _ReturnWaitingSection({required this.commuters});

  final List<CommuterModel> commuters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;
    final hairline = cts.navy.withValues(alpha: 0.12);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Waiting line · ${commuters.length}',
          style: theme.textTheme.labelLarge?.copyWith(
            color: cts.navy.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'First come, first served — auto-confirmed when a seat opens.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: cts.navy.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 8),
        Divider(height: 1, thickness: 1, color: hairline),
        for (var i = 0; i < commuters.length; i++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '${i + 1}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: cts.navy.withValues(alpha: 0.55),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        commuters[i].userId?.username ?? 'N/A',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: cts.navy,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        commuters[i].popId?.pickUpPointName ??
                            'Waiting for seat',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cts.navy.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Call commuter',
                  icon: Icon(Icons.call_outlined, color: cts.navy, size: 18),
                  onPressed: () {
                    final mobile = commuters[i].userId?.mobileNumber ?? '';
                    if (mobile.isNotEmpty) calling(mobile);
                  },
                ),
              ],
            ),
          ),
          if (i < commuters.length - 1)
            Divider(height: 1, thickness: 1, color: hairline),
        ],
      ],
    );
  }
}
