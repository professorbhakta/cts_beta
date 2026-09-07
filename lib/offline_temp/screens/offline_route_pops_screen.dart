import 'package:cts/theme/cts_colors.dart';
import 'package:cts/offline_temp/models/offline_pop.dart';
import 'package:cts/offline_temp/utils/offline_validators.dart';
import 'package:cts/offline_temp/utils/show_offline_text_dialog.dart';
import 'package:cts/offline_temp/providers/offline_temp_provider.dart';
import 'package:cts/widgets/confirmation_dialog.dart';
import 'package:cts/widgets/modern_list_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OfflineRoutePopsScreen extends StatefulWidget {
  const OfflineRoutePopsScreen({required this.routeId, super.key});

  final int routeId;

  @override
  State<OfflineRoutePopsScreen> createState() => _OfflineRoutePopsScreenState();
}

class _OfflineRoutePopsScreenState extends State<OfflineRoutePopsScreen> {
  List<OfflinePop> _pops = [];
  String _routeName = 'Route';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final provider = context.read<OfflineTempProvider>();
    for (final route in provider.routes) {
      if (route.id == widget.routeId) {
        _routeName = route.name;
        break;
      }
    }
    _pops = await provider.loadPopsForRoute(widget.routeId);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {    final scheme = context.scheme;
    final cts = context.cts;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.onSurface,
        title: Text('POPs — $_routeName'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPopDialog(context),
        icon: Icon(Icons.add_location_alt),
        label: const Text('POP'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _pops.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No pick-up points for $_routeName.\nTap + POP to add one.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _pops.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final pop = _pops[index];
                  return ModernListCard(
                    title: pop.name,
                    subtitle: '${pop.commuterCount} commuter(s) assigned',
                    icon: Icons.location_on_rounded,
                    iconColor: cts.yellowDark,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          await _editPop(context, pop);
                        } else if (value == 'delete') {
                          await _deletePop(context, pop);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Rename')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  Future<void> _showAddPopDialog(BuildContext context) async {
    final provider = context.read<OfflineTempProvider>();
    final name = await showOfflineTextDialog(
      context,
      title: 'New POP',
      labelText: 'POP name',
      hintText: 'Main gate',
      validator: OfflineValidators.popName,
      textCapitalization: TextCapitalization.words,
    );

    if (name != null) {
      final ok = await provider.addPop(
        routeId: widget.routeId,
        name: name,
      );
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not add POP. Name may already exist on this route.',
            ),
          ),
        );
      } else {
        await _load();
      }
    }
  }

  Future<void> _editPop(BuildContext context, OfflinePop pop) async {
    final provider = context.read<OfflineTempProvider>();
    final name = await showOfflineTextDialog(
      context,
      title: 'Rename POP',
      labelText: 'POP name',
      initialValue: pop.name,
      validator: OfflineValidators.popName,
      textCapitalization: TextCapitalization.words,
    );

    if (name != null && pop.id != null) {
      final ok = await provider.updatePopName(pop.id!, name);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not save POP. Name may already exist on this route.',
            ),
          ),
        );
      } else {
        await _load();
      }
    }
  }

  Future<void> _deletePop(BuildContext context, OfflinePop pop) async {
    final provider = context.read<OfflineTempProvider>();
    final scheme = context.scheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmationDialog(
        title: 'Delete POP?',
        message: pop.commuterCount > 0
            ? '"${pop.name}" has ${pop.commuterCount} commuter(s). Their POP will be cleared.'
            : 'Delete "${pop.name}"?',
        confirmLabel: 'Delete',
        confirmColor: scheme.error,
        icon: Icons.delete_outline,
        iconColor: scheme.error,
      ),
    );

    if (confirmed == true && pop.id != null) {
      final ok = await provider.deletePop(pop.id!);
      if (!context.mounted) return;
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete POP.')),
        );
      } else {
        await _load();
      }
    }
  }
}
