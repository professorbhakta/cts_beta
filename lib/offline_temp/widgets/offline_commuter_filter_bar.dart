import 'dart:async';

import 'package:cts/appManager/colors.dart';
import 'package:cts/offline_temp/models/offline_commuter_filter.dart';
import 'package:cts/offline_temp/models/offline_pop.dart';
import 'package:cts/offline_temp/providers/offline_temp_provider.dart';
import 'package:flutter/material.dart';

class OfflineCommuterFilterBar extends StatefulWidget {
  const OfflineCommuterFilterBar({
    required this.provider,
    this.showDataQualityFilters = true,
    super.key,
  });

  final OfflineTempProvider provider;
  final bool showDataQualityFilters;

  @override
  State<OfflineCommuterFilterBar> createState() =>
      _OfflineCommuterFilterBarState();
}

class _OfflineCommuterFilterBarState extends State<OfflineCommuterFilterBar> {
  late final TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.provider.filter.searchQuery,
    );
  }

  @override
  void didUpdateWidget(covariant OfflineCommuterFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.provider.filter.searchQuery != _searchController.text) {
      _searchController.text = widget.provider.filter.searchQuery;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  OfflineTempProvider get provider => widget.provider;

  List<OfflinePop> get _popOptions {
    final routeId = provider.filter.routeId;
    if (routeId == null) return provider.pops;
    return provider.pops.where((pop) => pop.routeId == routeId).toList();
  }

  void _applySearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      provider.updateFilter(provider.filter.copyWith(searchQuery: value));
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: AppColors.acYellowSoft.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search name, local ID, mobile...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                          provider.updateFilter(
                            provider.filter.copyWith(searchQuery: ''),
                          );
                        },
                      )
                    : null,
                filled: true,
                fillColor: scheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {});
                _applySearch(value);
              },
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _batchFilter(),
                  const SizedBox(width: 8),
                  _routeFilter(),
                  const SizedBox(width: 8),
                  _popFilter(),
                  const SizedBox(width: 8),
                  _choiceFilter(
                    label: 'Coming',
                    value: provider.filter.isComing,
                    onChanged: (value) {
                      provider.updateFilter(
                        provider.filter.copyWith(
                          isComing: value,
                          clearIsComing: value == null,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _cabFilter(),
                  if (widget.showDataQualityFilters) ...[
                    const SizedBox(width: 8),
                    _triStateFilter(
                      label: 'POP set',
                      value: provider.filter.hasPop,
                      onChanged: (value) {
                        provider.updateFilter(
                          provider.filter.copyWith(
                            hasPop: value,
                            clearHasPop: value == null,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _triStateFilter(
                      label: 'Mobile set',
                      value: provider.filter.hasMobile,
                      onChanged: (value) {
                        provider.updateFilter(
                          provider.filter.copyWith(
                            hasMobile: value,
                            clearHasMobile: value == null,
                          ),
                        );
                      },
                    ),
                  ],
                  if (provider.filter.hasActiveFilters) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                        provider.updateFilter(OfflineCommuterFilter.empty);
                      },
                      child: const Text('Clear all'),
                    ),
                  ],
                ],
              ),
            ),
            if (provider.filter.hasActiveFilters) ...[
              const SizedBox(height: 8),
              Text(
                '${provider.filter.activeFilterCount} filter(s) active • '
                '${provider.allCommuters.length} result(s)',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _batchFilter() {
    return DropdownMenu<int?>(
      label: const Text('Batch'),
      width: 150,
      initialSelection: provider.filter.batchId,
      dropdownMenuEntries: [
        const DropdownMenuEntry(value: null, label: 'All batches'),
        ...provider.batches.map(
          (batch) => DropdownMenuEntry(value: batch.id, label: batch.name),
        ),
      ],
      onSelected: (value) {
        provider.updateFilter(
          provider.filter.copyWith(
            batchId: value,
            clearBatchId: value == null,
            clearCab: true,
          ),
        );
      },
    );
  }

  Widget _routeFilter() {
    return PopupMenuButton<int?>(
      tooltip: 'Route',
      onSelected: (value) {
        provider.updateFilter(
          provider.filter.copyWith(
            routeId: value,
            clearRouteId: value == null,
            clearPopId: true,
          ),
        );
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: null, child: Text('All routes')),
        ...provider.routes.where((r) => r.id != null).map(
          (route) => PopupMenuItem(
            value: route.id,
            child: Text(route.name),
          ),
        ),
      ],
      child: Chip(label: Text(_routeLabel())),
    );
  }

  String _routeLabel() {
    final id = provider.filter.routeId;
    if (id == null) return 'Route';
    for (final route in provider.routes) {
      if (route.id == id) return 'Route: ${route.name}';
    }
    return 'Route';
  }

  Widget _popFilter() {
    return PopupMenuButton<int?>(
      tooltip: 'POP',
      onSelected: (value) {
        provider.updateFilter(
          provider.filter.copyWith(popId: value, clearPopId: value == null),
        );
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: null, child: Text('All POPs')),
        ..._popOptions.where((p) => p.id != null).map(
          (pop) => PopupMenuItem(
            value: pop.id,
            child: Text(
              provider.filter.routeId == null && pop.routeName != null
                  ? '${pop.name} (${pop.routeName})'
                  : pop.name,
            ),
          ),
        ),
      ],
      child: Chip(label: Text(_popLabel())),
    );
  }

  String _popLabel() {
    final id = provider.filter.popId;
    if (id == null) return 'POP';
    for (final pop in provider.pops) {
      if (pop.id == id) return 'POP: ${pop.name}';
    }
    return 'POP';
  }

  Widget _cabFilter() {
    final cabs = provider.cabs;
    return PopupMenuButton<String?>(
      tooltip: 'Cab',
      onSelected: (value) {
        provider.updateFilter(
          provider.filter.copyWith(cab: value, clearCab: value == null),
        );
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: null, child: Text('All cabs')),
        if (cabs.isEmpty)
          const PopupMenuItem(
            enabled: false,
            child: Text('No cab numbers yet'),
          ),
        ...cabs.map(
          (cab) => PopupMenuItem(value: cab, child: Text(cab)),
        ),
      ],
      child: Chip(
        label: Text(
          provider.filter.cab == null ? 'Cab' : 'Cab: ${provider.filter.cab}',
        ),
      ),
    );
  }

  Widget _choiceFilter({
    required String label,
    required bool? value,
    required ValueChanged<bool?> onChanged,
  }) {
    return PopupMenuButton<bool?>(
      tooltip: label,
      onSelected: onChanged,
      itemBuilder: (_) => [
        const PopupMenuItem(value: null, child: Text('All')),
        const PopupMenuItem(value: true, child: Text('Coming')),
        const PopupMenuItem(value: false, child: Text('Not coming')),
      ],
      child: Chip(
        label: Text(
          value == null ? label : '$label: ${value ? 'Yes' : 'No'}',
        ),
      ),
    );
  }

  Widget _triStateFilter({
    required String label,
    required bool? value,
    required ValueChanged<bool?> onChanged,
  }) {
    return PopupMenuButton<bool?>(
      tooltip: label,
      onSelected: onChanged,
      itemBuilder: (_) => [
        const PopupMenuItem(value: null, child: Text('All')),
        const PopupMenuItem(value: true, child: Text('Yes')),
        const PopupMenuItem(value: false, child: Text('No')),
      ],
      child: Chip(
        label: Text(
          value == null ? label : '$label: ${value ? 'Yes' : 'No'}',
        ),
      ),
    );
  }
}
