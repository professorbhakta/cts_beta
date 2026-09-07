import 'package:cts/theme/cts_colors.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:cts/offline_temp/models/offline_route.dart';
import 'package:cts/offline_temp/utils/offline_validators.dart';
import 'package:cts/offline_temp/utils/show_offline_text_dialog.dart';
import 'package:cts/offline_temp/providers/offline_temp_provider.dart';
import 'package:cts/widgets/confirmation_dialog.dart';
import 'package:cts/widgets/loading_indicator.dart';
import 'package:cts/widgets/modern_list_card.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class OfflineRoutesTab extends StatelessWidget {
  const OfflineRoutesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OfflineTempProvider>(
      builder: (context, provider, _) {
        final cts = context.cts;

        if (provider.errorMessage != null && !provider.isLoading) {
          return StatusMessage.error(
            title: 'Failed to load routes',
            message: provider.errorMessage,
            onRetry: provider.refreshAll,
          );
        }

        if (provider.isLoading && provider.routes.isEmpty) {
          return const LoadingIndicator();
        }

        if (provider.routes.isEmpty) {
          return const StatusMessage(
            icon: Icons.route_outlined,
            title: 'No routes yet',
            message:
                'Add routes first, then add POPs under each route before assigning commuters.',
          );
        }

        return RefreshIndicator(
          onRefresh: provider.refreshAll,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.routes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final route = provider.routes[index];
              return ModernListCard(
                title: route.name,
                subtitle: '${route.popCount} POP(s)',
                icon: Icons.route_rounded,
                iconColor: cts.yellowBright,
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      await _editRoute(context, provider, route);
                    } else if (value == 'delete') {
                      await _deleteRoute(context, provider, route);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Rename')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
                onTap: () {
                  if (route.id == null) return;
                  context.push(
                    '${RouteName.offlineRoutePops}/${route.id}',
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _editRoute(
    BuildContext context,
    OfflineTempProvider provider,
    OfflineRoute route,
  ) async {
    final name = await showOfflineTextDialog(
      context,
      title: 'Rename Route',
      labelText: 'Route name',
      initialValue: route.name,
      validator: OfflineValidators.routeName,
      textCapitalization: TextCapitalization.words,
    );

    if (name != null && route.id != null) {
      final ok = await provider.updateRouteName(route.id!, name);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save route. Name may already exist.'),
          ),
        );
      }
    }
  }

  Future<void> _deleteRoute(
    BuildContext context,
    OfflineTempProvider provider,
    OfflineRoute route,
  ) async {
    if (route.popCount > 0) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete route?'),
          content: Text(
            'Cannot delete "${route.name}" while it has ${route.popCount} POP(s). Remove POPs first.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final scheme = context.scheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmationDialog(
        title: 'Delete route?',
        message: 'Delete route "${route.name}"?',
        confirmLabel: 'Delete',
        confirmColor: scheme.error,
        icon: Icons.delete_outline,
        iconColor: scheme.error,
      ),
    );

    if (confirmed == true && route.id != null) {
      final ok = await provider.deleteRoute(route.id!);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete route.')),
        );
      }
    }
  }
}

Future<void> showAddRouteDialog(BuildContext context) async {
  final provider = context.read<OfflineTempProvider>();
  final name = await showOfflineTextDialog(
    context,
    title: 'New Route',
    labelText: 'Route name',
    hintText: 'Route A',
    validator: OfflineValidators.routeName,
    textCapitalization: TextCapitalization.words,
  );

  if (name != null && context.mounted) {
    final ok = await provider.addRoute(name);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a unique route name.')),
      );
    }
  }
}
