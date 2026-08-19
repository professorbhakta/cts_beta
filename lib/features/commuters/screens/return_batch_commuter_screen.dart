import 'package:cts/appManager/colors.dart';
import 'package:cts/appManager/functions_and_tools.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/batches/providers/return_batch_provider.dart';
import 'package:cts/features/commuters/models/commuter_model.dart';
import 'package:cts/widgets/brand_app_bar.dart';
import 'package:cts/widgets/headline_widget.dart';
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
    this.canEndTrip = true,
  });

  final String batchId;
  final bool readOnly;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ReturnBatchProvider>().loadReturnTrip(widget.batchId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await context.read<ReturnBatchProvider>().loadReturnTrip(widget.batchId);
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End return trip?'),
        content: const Text(
          'This clears today\'s confirmed return list. Commuters can be confirmed again after refresh.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.acRed),
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
    return 'Return Trip — Batch #${widget.batchId}';
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
    return Scaffold(
      appBar: const BrandAppBar(),
      floatingActionButton: (!widget.canEndTrip || widget.readOnly)
          ? null
          : Consumer<ReturnBatchProvider>(
              builder: (context, provider, _) {
                if (provider.state != ViewState.success) {
                  return const SizedBox.shrink();
                }

                return FloatingActionButton.extended(
                  onPressed: provider.actionInProgress
                      ? null
                      : () => _endReturnTrip(provider),
                  backgroundColor: AppColors.acRed,
                  foregroundColor: AppColors.acWhite,
                  icon: const Icon(Icons.flag_rounded),
                  label: const Text('End return'),
                );
              },
            ),
      body: SafeArea(
        child: Consumer<ReturnBatchProvider>(
          builder: (context, provider, _) {
            if (provider.state == ViewState.loading &&
                provider.availableCommuters.isEmpty &&
                provider.confirmedCommuters.isEmpty) {
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

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Headline(headline: _headline(), fontSize: 21),
                      const SizedBox(height: 12),
                      _CapacityBanner(
                        remaining: remaining,
                        total: total,
                        confirmedCount: capacity?.confirmedCount ?? 0,
                        isActive: isActive,
                        homeHold: status?.homeHold,
                        overflowConfirmed: status?.overflowConfirmed,
                        overflowRemaining: status?.overflowRemaining,
                      ),
                    ],
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(
                      text: 'Available (${provider.availableCommuters.length})',
                    ),
                    Tab(
                      text: 'Confirmed (${provider.confirmedCommuters.length})',
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
                              'Home-batch riders who boarded this morning appear here. Overflow is later-return walk-up.',
                          isActive: isActive,
                        ),
                        onConfirm: (commuter) =>
                            _confirmCommuter(provider, commuter),
                        onRefresh: _refresh,
                        actionInProgress: provider.actionInProgress,
                        readOnly: widget.readOnly,
                        overflowConfirmAllowed:
                            status == null ||
                            !status.hasPoolExtras ||
                            (status.overflowRemaining ?? 0) > 0,
                      ),
                      _CommuterListTab(
                        commuters: provider.confirmedCommuters,
                        emptyTitle: 'No confirmed commuters',
                        emptyMessage: _emptyMessage(
                          defaultMessage:
                              'Confirm riders from the Available tab.',
                          isActive: isActive,
                        ),
                        actionLabel: 'Remove',
                        actionColor: AppColors.acRed,
                        actionIcon: Icons.remove_circle_outline,
                        onAction: (commuter) =>
                            _removeCommuter(provider, commuter),
                        onRefresh: _refresh,
                        actionInProgress: provider.actionInProgress,
                        readOnly: widget.readOnly,
                      ),
                    ],
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
    required this.overflowConfirmAllowed,
    this.readOnly = false,
  });

  final List<CommuterModel> home;
  final List<CommuterModel> overflow;
  final String emptyMessage;
  final ValueChanged<CommuterModel> onConfirm;
  final Future<void> Function() onRefresh;
  final bool actionInProgress;
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
                          child: Text('No home-batch riders waiting.'),
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
                          child: Text('No later-return walk-up riders.'),
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
    final mobile = commuter.userId?.mobileNumber ?? '';
    final pop = commuter.popId?.pickUpPointName ?? 'N/A';
    final batch = commuter.batchId?.batchName;
    final subtitle = batch == null || batch.isEmpty ? pop : '$pop • $batch';
    final tile = ListTile(
      title: Text(commuter.userId?.username ?? 'N/A'),
      subtitle: Text(subtitle),
      trailing: IconButton(
        tooltip: 'Call commuter',
        icon: const Icon(Icons.call),
        onPressed: mobile.isEmpty ? null : () => calling(mobile),
      ),
    );

    if (widget.readOnly || !confirmAllowed) {
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
            backgroundColor: AppColors.acGreen,
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
  });

  final int remaining;
  final int total;
  final int confirmedCount;
  final bool isActive;
  final int? homeHold;
  final int? overflowConfirmed;
  final int? overflowRemaining;

  bool get _hasPoolExtras =>
      homeHold != null &&
      overflowConfirmed != null &&
      overflowRemaining != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.acYellowWarm.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.event_seat, color: AppColors.acYellowWarm),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$remaining of $total seats remaining',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '$confirmedCount confirmed${isActive ? ' • trip active' : ''}',
                  style: theme.textTheme.bodySmall,
                ),
                if (_hasPoolExtras)
                  Text(
                    'Home hold $homeHold • Overflow in $overflowConfirmed • Overflow open $overflowRemaining',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
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
                          icon: const Icon(Icons.call),
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
