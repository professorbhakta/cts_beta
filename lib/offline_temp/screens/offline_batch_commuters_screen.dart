import 'package:cts/appManager/colors.dart';
import 'package:cts/offline_temp/models/offline_batch.dart';
import 'package:cts/offline_temp/models/offline_commuter.dart';
import 'package:cts/offline_temp/providers/offline_temp_provider.dart';
import 'package:cts/offline_temp/screens/offline_commuter_form_screen.dart';
import 'package:cts/widgets/modern_list_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OfflineBatchCommutersScreen extends StatefulWidget {
  const OfflineBatchCommutersScreen({required this.batchId, super.key});

  final int batchId;

  @override
  State<OfflineBatchCommutersScreen> createState() =>
      _OfflineBatchCommutersScreenState();
}

class _OfflineBatchCommutersScreenState
    extends State<OfflineBatchCommutersScreen> {
  OfflineBatch? _batch;
  List<OfflineCommuter> _commuters = [];
  bool _loading = true;
  String _searchQuery = '';
  bool? _comingFilter;

  List<OfflineCommuter> get _visibleCommuters {
    return _commuters.where((commuter) {
      if (_comingFilter != null && commuter.isComing != _comingFilter) {
        return false;
      }
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return commuter.name.toLowerCase().contains(query) ||
          commuter.mobile.contains(query) ||
          commuter.displayId.contains(query) ||
          (commuter.popName?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final provider = context.read<OfflineTempProvider>();
    _batch = await provider.getBatch(widget.batchId);
    _commuters = await provider.getCommutersForBatch(widget.batchId);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final batchName = _batch?.name ?? 'Batch';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.acBlack,
        title: Text(batchName),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final changed = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => OfflineCommuterFormScreen(
                batchId: widget.batchId,
                batchName: batchName,
              ),
            ),
          );
          if (changed == true) await _load();
        },
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Commuter'),
      ),
      body: Column(
        children: [
          if (!_loading && _commuters.isNotEmpty)
            Material(
              color: AppColors.acYellowSoft.withValues(alpha: 0.35),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search in batch...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: scheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) =>
                            setState(() => _searchQuery = value.trim()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<bool?>(
                      tooltip: 'Coming filter',
                      onSelected: (value) =>
                          setState(() => _comingFilter = value),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: null, child: Text('All')),
                        PopupMenuItem(value: true, child: Text('Coming')),
                        PopupMenuItem(value: false, child: Text('Not coming')),
                      ],
                      child: Chip(
                        label: Text(
                          _comingFilter == null
                              ? 'Coming'
                              : 'Coming: ${_comingFilter! ? 'Yes' : 'No'}',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _commuters.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'No commuters in $batchName.\nTap + Commuter to add one.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : _visibleCommuters.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'No commuters match your search/filter.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _visibleCommuters.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final commuter = _visibleCommuters[index];
                  return ModernListCard(
                    title: commuter.name,
                    subtitle:
                        '#${commuter.displayId} • ${commuter.routeName ?? 'No route'}',
                    icon: Icons.person_rounded,
                    iconColor: commuter.isComing
                        ? AppColors.acGreen
                        : AppColors.acOrange,
                    trailing: Switch(
                      value: commuter.isComing,
                      onChanged: (value) async {
                        if (commuter.id == null) return;
                        await context
                            .read<OfflineTempProvider>()
                            .toggleIsComing(commuter.id!, value);
                        await _load();
                      },
                    ),
                    children: [
                      _infoRow('POP', commuter.popName ?? '-'),
                      _infoRow('Cab', commuter.cab),
                      _infoRow('Mobile', commuter.mobile),
                      _infoRow('Coming', commuter.isComing ? 'Yes' : 'No'),
                    ],
                    onTap: () async {
                      final changed = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OfflineCommuterFormScreen(
                            batchId: widget.batchId,
                            batchName: batchName,
                            commuter: commuter,
                          ),
                        ),
                      );
                      if (changed == true) await _load();
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
