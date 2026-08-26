import 'package:cts/theme/cts_colors.dart';
import 'package:cts/offline_temp/providers/offline_temp_provider.dart';
import 'package:cts/offline_temp/screens/offline_commuter_form_screen.dart';
import 'package:cts/offline_temp/widgets/offline_commuter_filter_bar.dart';
import 'package:cts/widgets/loading_indicator.dart';
import 'package:cts/widgets/modern_list_card.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OfflineCommutersTab extends StatelessWidget {
  const OfflineCommutersTab({super.key});

  @override
  Widget build(BuildContext context) {

    return Consumer<OfflineTempProvider>(
      builder: (context, provider, _) {
    final cts = context.cts;

        if (provider.errorMessage != null && !provider.isLoading) {
          return StatusMessage.error(
            title: 'Failed to load commuters',
            message: provider.errorMessage,
            onRetry: provider.refreshAll,
          );
        }

        return Column(
          children: [
            OfflineCommuterFilterBar(provider: provider),
            Expanded(
              child: provider.isLoading && provider.allCommuters.isEmpty
                  ? const LoadingIndicator()
                  : provider.allCommuters.isEmpty
                  ? StatusMessage(
                      icon: Icons.people_outline,
                      title: provider.filter.hasActiveFilters
                          ? 'No matching commuters'
                          : 'No commuters yet',
                      message: provider.filter.hasActiveFilters
                          ? 'No commuters match your filters.'
                          : 'Open a batch and add commuters.',
                    )
                  : RefreshIndicator(
                      onRefresh: provider.refreshAll,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: provider.allCommuters.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final commuter = provider.allCommuters[index];
                          return ModernListCard(
                            title: commuter.name,
                            subtitle:
                                '#${commuter.displayId} • ${commuter.batchName ?? 'Batch'}',
                            icon: Icons.person_rounded,
                            iconColor: commuter.isComing
                                ? cts.success
                                : cts.orange,
                            trailing: Switch(
                              value: commuter.isComing,
                              onChanged: (value) async {
                                if (commuter.id == null) return;
                                await provider.toggleIsComing(
                                  commuter.id!,
                                  value,
                                );
                              },
                            ),
                            children: [
                              _chipRow('Route', commuter.routeName ?? '-'),
                              _chipRow('POP', commuter.popName ?? '-'),
                              _chipRow('Cab', commuter.cab),
                              _chipRow('Mobile', commuter.mobile),
                            ],
                            onTap: () async {
                              await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OfflineCommuterFormScreen(
                                    batchId: commuter.batchId,
                                    batchName:
                                        commuter.batchName ?? 'Batch',
                                    commuter: commuter,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _chipRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        '$label: ${value.isEmpty ? '-' : value}',
        style: TextStyle(fontSize: 12),
      ),
    );
  }
}
