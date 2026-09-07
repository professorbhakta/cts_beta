import 'package:cts/theme/cts_colors.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:cts/offline_temp/models/offline_batch.dart';
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

class OfflineBatchesTab extends StatelessWidget {
  const OfflineBatchesTab({super.key});

  @override
  Widget build(BuildContext context) {

    return Consumer<OfflineTempProvider>(
      builder: (context, provider, _) {
    final scheme = context.scheme;

        if (provider.errorMessage != null && !provider.isLoading) {
          return StatusMessage.error(
            title: 'Failed to load batches',
            message: provider.errorMessage,
            onRetry: provider.refreshAll,
          );
        }

        if (provider.isLoading && provider.batches.isEmpty) {
          return const LoadingIndicator();
        }

        if (provider.batches.isEmpty) {
          return StatusMessage(
            icon: Icons.directions_bus_outlined,
            title: 'No batches yet',
            message: 'Tap the + Batch button to create your first offline batch.',
          );
        }

        return RefreshIndicator(
          onRefresh: provider.refreshAll,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.batches.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final batch = provider.batches[index];
              return ModernListCard(
                title: batch.name,
                subtitle: '${batch.commuterCount} commuter(s)',
                icon: Icons.directions_bus_rounded,
                iconColor: scheme.primary,
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      await _editBatch(context, provider, batch);
                    } else if (value == 'delete') {
                      await _confirmDelete(context, provider, batch);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Rename')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
                onTap: () {
                  context.push(
                    '${RouteName.offlineBatchCommuters}/${batch.id}',
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _editBatch(
    BuildContext context,
    OfflineTempProvider provider,
    OfflineBatch batch,
  ) async {
    final name = await showOfflineTextDialog(
      context,
      title: 'Rename Batch',
      labelText: 'Batch name',
      initialValue: batch.name,
      validator: OfflineValidators.batchName,
      textCapitalization: TextCapitalization.words,
    );

    if (name != null && batch.id != null) {
      final ok = await provider.updateBatchName(batch.id!, name);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save batch. Name may already exist.'),
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    OfflineTempProvider provider,
    OfflineBatch batch,
  ) async {
    final scheme = context.scheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmationDialog(
        title: 'Delete batch?',
        message:
            'Delete "${batch.name}" and all ${batch.commuterCount} commuter(s)?',
        confirmLabel: 'Delete',
        confirmColor: scheme.error,
        icon: Icons.delete_outline,
        iconColor: scheme.error,
      ),
    );

    if (confirmed == true && batch.id != null) {
      await provider.deleteBatch(batch.id!);
    }
  }
}
