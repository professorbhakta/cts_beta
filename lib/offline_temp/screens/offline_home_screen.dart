import 'package:cts/offline_temp/data/offline_seed_data.dart';
import 'package:cts/offline_temp/offline_auto_redirect.dart';
import 'package:cts/offline_temp/providers/offline_temp_provider.dart';
import 'package:cts/offline_temp/screens/offline_batches_tab.dart';
import 'package:cts/offline_temp/screens/offline_commuters_tab.dart';
import 'package:cts/offline_temp/screens/offline_output_tab.dart';
import 'package:cts/offline_temp/screens/offline_routes_tab.dart';
import 'package:cts/offline_temp/utils/offline_validators.dart';
import 'package:cts/offline_temp/utils/show_offline_text_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum _OfflineMenuAction { importSeed, dumpAll, refresh }

class OfflineHomeScreen extends StatefulWidget {
  const OfflineHomeScreen({super.key});

  @override
  State<OfflineHomeScreen> createState() => _OfflineHomeScreenState();
}

class _OfflineHomeScreenState extends State<OfflineHomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OfflineTempProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return OfflineAutoRedirect(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Offline Mode'),
          actions: [
            PopupMenuButton<_OfflineMenuAction>(
              tooltip: 'More actions',
              icon: const Icon(Icons.more_vert),
              onSelected: (action) => _handleMenuAction(context, action),
              itemBuilder: (context) {
                final errorColor = Theme.of(context).colorScheme.error;
                return [
                  if (hasOfflineSeedData)
                    const PopupMenuItem(
                      value: _OfflineMenuAction.importSeed,
                      child: ListTile(
                        leading: Icon(Icons.upload_file_rounded),
                        title: Text('Import seed data'),
                        contentPadding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  PopupMenuItem(
                    value: _OfflineMenuAction.dumpAll,
                    child: ListTile(
                      leading: Icon(Icons.delete_sweep_rounded, color: errorColor),
                      title: Text(
                        'Dump all data',
                        style: TextStyle(color: errorColor),
                      ),
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const PopupMenuItem(
                    value: _OfflineMenuAction.refresh,
                    child: ListTile(
                      leading: Icon(Icons.refresh_rounded),
                      title: Text('Refresh'),
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            OfflineRoutesTab(),
            OfflineBatchesTab(),
            OfflineCommutersTab(),
            OfflineOutputTab(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
            if (index == 3) {
              context.read<OfflineTempProvider>().regenerateExportFromFilter();
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.route_outlined),
              selectedIcon: Icon(Icons.route),
              label: 'Routes',
            ),
            NavigationDestination(
              icon: Icon(Icons.directions_bus_outlined),
              selectedIcon: Icon(Icons.directions_bus),
              label: 'Batches',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: 'Commuters',
            ),
            NavigationDestination(
              icon: Icon(Icons.output_outlined),
              selectedIcon: Icon(Icons.output),
              label: 'Output',
            ),
          ],
        ),
        floatingActionButton: _buildFab(context),
      ),
    );
  }

  Widget? _buildFab(BuildContext context) {
    switch (_currentIndex) {
      case 0:
        return FloatingActionButton.extended(
          onPressed: () => showAddRouteDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Route'),
        );
      case 1:
        return FloatingActionButton.extended(
          onPressed: () => _showAddBatchDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Batch'),
        );
      default:
        return null;
    }
  }

  Future<void> _handleMenuAction(
    BuildContext context,
    _OfflineMenuAction action,
  ) async {
    switch (action) {
      case _OfflineMenuAction.importSeed:
        await _importSeed(context);
      case _OfflineMenuAction.dumpAll:
        await _dumpAllData(context);
      case _OfflineMenuAction.refresh:
        await context.read<OfflineTempProvider>().refreshAll();
    }
  }

  Future<void> _showAddBatchDialog(BuildContext context) async {
    final provider = context.read<OfflineTempProvider>();
    final name = await showOfflineTextDialog(
      context,
      title: 'New Batch',
      labelText: 'Batch name',
      hintText: 'Morning Batch',
      validator: OfflineValidators.batchName,
      textCapitalization: TextCapitalization.words,
    );

    if (name != null && context.mounted) {
      final ok = await provider.addBatch(name);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a unique batch name.')),
        );
      }
    }
  }

  Future<void> _dumpAllData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dump all data?'),
        content: const Text(
          'This permanently deletes all routes, POPs, batches, and commuters from offline storage.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Dump'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await context.read<OfflineTempProvider>().dumpAllData();
    if (!context.mounted) return;

    final error = context.read<OfflineTempProvider>().errorMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ?? 'All offline data deleted.',
        ),
      ),
    );
  }

  Future<void> _importSeed(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import seed data?'),
        content: const Text(
          'This adds routes, POPs, batches, and commuters from the built-in seed file. Existing rows are kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final result =
          await context.read<OfflineTempProvider>().importSeedData(offlineSeedData);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Imported ${result.routes} routes, ${result.pops} POPs, '
            '${result.batches} batches, ${result.commuters} commuters.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    }
  }
}

/// Drawer helper — only Admin/Driver should see offline mode in the menu.
bool showOfflineDrawerTile() => OfflineAutoRedirect.isOfflineRole();
