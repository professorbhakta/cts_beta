import 'dart:async';

import 'package:cts/theme/cts_colors.dart';
import 'package:cts/appManager/functions_and_tools.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/batches/providers/return_batch_provider.dart';
import 'package:cts/features/commuters/models/commuter_model.dart';
import 'package:cts/widgets/app_drawer.dart';
import 'package:cts/widgets/brand_app_bar.dart';
import 'package:cts/widgets/loading_indicator.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
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

  String _headline() => 'Return list';

  String _emptyMessage({
    required String defaultMessage,
    required bool isActive,
  }) {
    if (!widget.readOnly || isActive) return defaultMessage;
    return 'Today\'s return trip is not active. Pull to refresh for updates.';
  }

  String _batchLabel(ReturnBatchProvider provider) {
    for (final list in [
      provider.homeCommuters,
      provider.overflowCommuters,
      provider.confirmedCommuters,
      provider.waitingCommuters,
    ]) {
      for (final c in list) {
        final name = c.batchId?.batchName;
        if (name != null && name.isNotEmpty) return name.toUpperCase();
      }
    }
    return 'BATCH #${widget.batchId}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final cts = context.cts;
    final theme = Theme.of(context);
    final hairline = cts.navy.withValues(alpha: 0.14);

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

            if (provider.state == ViewState.loading && !provider.hasTripData) {
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
                              _batchLabel(provider),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: cts.navy,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _headline(),
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                      color: cts.navy,
                                      fontWeight: FontWeight.w700,
                                      height: 1.15,
                                    ),
                                  ),
                                ),
                                if (isActive) const _LiveChip(),
                              ],
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
                      const SizedBox(height: 8),
                      TabBar(
                        controller: _tabController,
                        labelColor: cts.navy,
                        unselectedLabelColor: cts.navy.withValues(alpha: 0.45),
                        indicatorColor: cts.navy,
                        indicatorWeight: 3,
                        labelStyle: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                        unselectedLabelStyle:
                            theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                        dividerColor: hairline,
                        tabs: [
                          Tab(
                            text:
                                'AVAILABLE · ${provider.availableCommuters.length}',
                          ),
                          Tab(
                            text:
                                'CONFIRMED · ${provider.confirmedCommuters.length}',
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
                              waiting: provider.waitingCommuters,
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
                              onRemove: (commuter) =>
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
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: provider.actionInProgress
                              ? null
                              : () => _endReturnTrip(provider),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: cts.navy,
                            side: BorderSide(color: hairline, width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Text(
                            'END RETURN',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: cts.navy,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
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

class _LiveChip extends StatelessWidget {
  const _LiveChip();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cts.navy,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'LIVE',
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _HairlineSearchField extends StatefulWidget {
  const _HairlineSearchField({
    required this.hintText,
    required this.onSearchChanged,
  });

  final String hintText;
  final ValueChanged<String> onSearchChanged;

  @override
  State<_HairlineSearchField> createState() => _HairlineSearchFieldState();
}

class _HairlineSearchFieldState extends State<_HairlineSearchField> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      widget.onSearchChanged(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;
    final hairline = cts.navy.withValues(alpha: 0.14);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: TextField(
        controller: _controller,
        onChanged: (value) {
          setState(() {});
          _onChanged(value);
        },
        style: theme.textTheme.bodyMedium?.copyWith(color: cts.navy),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: cts.navy.withValues(alpha: 0.45),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: cts.navy.withValues(alpha: 0.55),
            size: 20,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: cts.navy.withValues(alpha: 0.55),
                    size: 18,
                  ),
                  onPressed: () {
                    _controller.clear();
                    widget.onSearchChanged('');
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: theme.scaffoldBackgroundColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: hairline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: hairline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: cts.navy.withValues(alpha: 0.35)),
          ),
        ),
      ),
    );
  }
}

class _AvailableListTab extends StatefulWidget {
  const _AvailableListTab({
    required this.home,
    required this.overflow,
    required this.waiting,
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
  final List<CommuterModel> waiting;
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
    final waiting = _filter(widget.waiting);
    final isEmpty =
        widget.home.isEmpty && widget.overflow.isEmpty && widget.waiting.isEmpty;

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
        _HairlineSearchField(
          hintText: 'Search name, mobile, batch, or POP',
          onSearchChanged: (query) {
            setState(() => _searchQuery = query);
          },
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: widget.onRefresh,
            child: home.isEmpty && overflow.isEmpty && waiting.isEmpty
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
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    children: [
                      _sectionHeader(context, 'HOME', home.length),
                      if (home.isEmpty)
                        _emptySectionNote(
                          context,
                          'No Coming-today commuters for this batch.',
                        )
                      else
                        for (final commuter in home)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _CommuterActionCard(
                              commuter: commuter,
                              primaryLabel: 'CONFIRM',
                              primaryEmphasized: true,
                              onPrimary: widget.readOnly ||
                                      !widget.canConfirm
                                  ? null
                                  : (widget.actionInProgress
                                      ? null
                                      : () => widget.onConfirm(commuter)),
                            ),
                          ),
                      _sectionHeader(context, 'OVERFLOW', overflow.length),
                      if (overflow.isEmpty)
                        _emptySectionNote(
                          context,
                          'No other-batch Coming-today commuters waiting.',
                        )
                      else
                        for (final commuter in overflow)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _CommuterActionCard(
                              commuter: commuter,
                              primaryLabel: 'CONFIRM',
                              primaryEmphasized: true,
                              onPrimary: widget.readOnly ||
                                      !widget.canConfirm ||
                                      !widget.overflowConfirmAllowed
                                  ? null
                                  : (widget.actionInProgress
                                      ? null
                                      : () => widget.onConfirm(commuter)),
                            ),
                          ),
                      if (widget.waiting.isNotEmpty) ...[
                        _sectionHeader(
                          context,
                          'WAITING LINE',
                          waiting.length,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'First come, first served — auto-confirmed when a seat opens.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: context.cts.navy
                                      .withValues(alpha: 0.55),
                                ),
                          ),
                        ),
                        for (var i = 0; i < waiting.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _CommuterActionCard(
                              commuter: waiting[i],
                              leadingIndex: i + 1,
                              showPrimary: false,
                            ),
                          ),
                      ],
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(BuildContext context, String title, int count) {
    final cts = context.cts;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Text(
        '$title · $count',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: cts.navy,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
      ),
    );
  }

  Widget _emptySectionNote(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.cts.navy.withValues(alpha: 0.55),
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
    final hairline = cts.navy.withValues(alpha: 0.14);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: hairline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              style: theme.textTheme.titleSmall?.copyWith(
                color: cts.navy,
                fontWeight: FontWeight.w500,
              ),
              children: [
                TextSpan(
                  text: '$remaining',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: ' of $total seats remaining'),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$confirmedCount confirmed${isActive ? ' · trip active' : ''}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cts.navy,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (_hasPoolExtras) ...[
            const SizedBox(height: 4),
            Text(
              'Home hold $homeHold · Overflow in $overflowConfirmed · Overflow open $overflowRemaining'
              '${cutoffApplied ? ' · Holds released (T−15)' : ''}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cts.navy.withValues(alpha: 0.65),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
    required this.onRemove,
    required this.onRefresh,
    required this.actionInProgress,
    this.readOnly = false,
  });

  final List<CommuterModel> commuters;
  final String emptyTitle;
  final String emptyMessage;
  final ValueChanged<CommuterModel> onRemove;
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
        _HairlineSearchField(
          hintText: 'Search name, mobile, batch, or POP',
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
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final commuter = visible[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _CommuterActionCard(
                          commuter: commuter,
                          primaryLabel: 'REMOVE',
                          primaryEmphasized: false,
                          onPrimary: widget.readOnly
                              ? null
                              : (widget.actionInProgress
                                  ? null
                                  : () => widget.onRemove(commuter)),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _CommuterActionCard extends StatelessWidget {
  const _CommuterActionCard({
    required this.commuter,
    this.primaryLabel,
    this.primaryEmphasized = false,
    this.onPrimary,
    this.showPrimary = true,
    this.leadingIndex,
  });

  final CommuterModel commuter;
  final String? primaryLabel;
  final bool primaryEmphasized;
  final VoidCallback? onPrimary;
  final bool showPrimary;
  final int? leadingIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;
    final hairline = cts.navy.withValues(alpha: 0.14);
    final mobile = commuter.userId?.mobileNumber ?? '';
    final pop = commuter.popId?.pickUpPointName ?? 'N/A';
    final batch = commuter.batchId?.batchName;
    final detail = batch == null || batch.isEmpty ? pop : '$pop · $batch';

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: hairline, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leadingIndex != null) ...[
            SizedBox(
              width: 24,
              child: Text(
                '$leadingIndex',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: cts.navy.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  commuter.userId?.username ?? 'N/A',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: cts.navy,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cts.navy.withValues(alpha: 0.65),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (mobile.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    mobile,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cts.navy.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          _OutlineActionButton(
            label: 'CALL',
            onPressed: mobile.isEmpty ? null : () => calling(mobile),
          ),
          if (showPrimary && primaryLabel != null) ...[
            const SizedBox(width: 6),
            _OutlineActionButton(
              label: primaryLabel!,
              emphasized: primaryEmphasized,
              onPressed: onPrimary,
            ),
          ],
        ],
      ),
    );
  }
}

class _OutlineActionButton extends StatelessWidget {
  const _OutlineActionButton({
    required this.label,
    this.onPressed,
    this.emphasized = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;
    final hairline = cts.navy.withValues(alpha: 0.14);
    final enabled = onPressed != null;

    return SizedBox(
      height: 36,
      child: Material(
        color: emphasized && enabled ? cts.yellow : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: emphasized && enabled ? cts.yellow : hairline,
                width: 1,
              ),
            ),
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: enabled
                    ? cts.navy
                    : cts.navy.withValues(alpha: 0.35),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
