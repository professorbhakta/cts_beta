import 'package:cts/appManager/colors.dart';
import 'package:cts/appManager/functions_and_tools.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/batches/providers/return_batch_provider.dart';
import 'package:cts/features/commuters/models/commuter_model.dart';
import 'package:cts/widgets/brand_app_bar.dart';
import 'package:cts/widgets/headline_widget.dart';
import 'package:cts/widgets/loading_indicator.dart';
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
      final provider = context.read<ReturnBatchProvider>();
      provider.loadReturnTrip(widget.batchId);
      if (!widget.canEndTrip) {
        provider.fetchStatusesForBatches([widget.batchId]);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final provider = context.read<ReturnBatchProvider>();
    await provider.loadReturnTrip(widget.batchId);
    if (!widget.canEndTrip) {
      await provider.fetchStatusesForBatches([widget.batchId]);
    }
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
      SnackBar(
        content: Text(message ?? 'Commuter confirmed for return'),
      ),
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
      SnackBar(
        content: Text(message ?? 'Commuter removed from return list'),
      ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Return trip ended')),
    );
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
            final isActive = capacity?.isActive ??
                provider.statusForBatch(widget.batchId)?.isActive ??
                false;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Headline(
                        headline: _headline(),
                        fontSize: 21,
                      ),
                      const SizedBox(height: 12),
                      _CapacityBanner(
                        remaining: remaining,
                        total: total,
                        confirmedCount: capacity?.confirmedCount ?? 0,
                        isActive: isActive,
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
                      _CommuterListTab(
                        commuters: provider.availableCommuters,
                        emptyTitle: 'No commuters available',
                        emptyMessage: _emptyMessage(
                          defaultMessage:
                              'Commuters not yet confirmed for a return trip will appear here.',
                          isActive: isActive,
                        ),
                        actionLabel: 'Confirm',
                        actionColor: AppColors.acGreen,
                        actionIcon: Icons.check_circle_outline,
                        onAction: (commuter) =>
                            _confirmCommuter(provider, commuter),
                        onRefresh: _refresh,
                        actionInProgress: provider.actionInProgress,
                        readOnly: widget.readOnly,
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

class _CapacityBanner extends StatelessWidget {
  const _CapacityBanner({
    required this.remaining,
    required this.total,
    required this.confirmedCount,
    required this.isActive,
  });

  final int remaining;
  final int total;
  final int confirmedCount;
  final bool isActive;

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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommuterListTab extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (commuters.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            StatusMessage(
              icon: Icons.people_outline,
              title: emptyTitle,
              message: emptyMessage,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: commuters.length,
        itemBuilder: (context, index) {
          final commuter = commuters[index];
          final mobile = commuter.userId?.mobileNumber ?? '';

          final tile = ListTile(
            title: Text(commuter.userId?.username ?? 'N/A'),
            subtitle: Text(commuter.popId?.pickUpPointName ?? 'N/A'),
            trailing: IconButton(
              tooltip: 'Call commuter',
              icon: const Icon(Icons.call),
              onPressed: mobile.isEmpty ? null : () => calling(mobile),
            ),
          );

          if (readOnly) return tile;

          return Slidable(
            endActionPane: ActionPane(
              motion: const StretchMotion(),
              children: [
                SlidableAction(
                  onPressed: actionInProgress
                      ? null
                      : (_) => onAction(commuter),
                  backgroundColor: actionColor,
                  icon: actionIcon,
                  label: actionLabel,
                ),
              ],
            ),
            child: tile,
          );
        },
      ),
    );
  }
}
