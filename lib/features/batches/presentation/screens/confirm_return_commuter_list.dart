import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/batches/presentation/providers/return_batch_provider.dart';
import 'package:cts/widgets/dashboard_shell.dart';
import 'package:cts/widgets/loading_indicator.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConfirmReturnCommuterList extends StatefulWidget {
  final String batchId;

  const ConfirmReturnCommuterList({super.key, required this.batchId});

  @override
  State<ConfirmReturnCommuterList> createState() =>
      _ConfirmReturnCommuterListState();
}

class _ConfirmReturnCommuterListState extends State<ConfirmReturnCommuterList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReturnBatchProvider>().fetchConfirmedCommuters(widget.batchId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: 'Confirmed Return List',
      child: Consumer<ReturnBatchProvider>(
        builder: (context, provider, child) {
          if (provider.state == ViewState.loading &&
              provider.confirmedCommuters.isEmpty) {
            return const LoadingIndicator();
          }

          if (provider.state == ViewState.error) {
            return StatusMessage(
              icon: Icons.error_outline,
              title: 'Failed to load confirmed list',
              message: provider.errorMessage ?? 'Please try again.',
              color: Theme.of(context).colorScheme.error,
              onRetry: () =>
                  provider.fetchConfirmedCommuters(widget.batchId),
            );
          }

          if (provider.confirmedCommuters.isEmpty) {
            return const StatusMessage(
              icon: Icons.check_circle_outline,
              title: 'No confirmed commuters',
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                provider.fetchConfirmedCommuters(widget.batchId),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.confirmedCommuters.length,
              itemBuilder: (context, index) {
                final commuter = provider.confirmedCommuters[index];
                final initial =
                    commuter.userId?.username?.substring(0, 1).toUpperCase() ??
                    'C';
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 16.0,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      child: Text(
                        initial,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      commuter.userId?.username ?? 'No Name',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            commuter.popId?.pickUpPointName ??
                                'No Pickup Point',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    trailing: Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
