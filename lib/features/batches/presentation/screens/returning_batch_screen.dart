import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/batches/presentation/providers/batch_controller.dart';
import 'package:cts/features/commuters/presentation/screens/return_batch_commuter_screen.dart';
import 'package:cts/widgets/dashboard_shell.dart';
import 'package:cts/widgets/info_row.dart';
import 'package:cts/widgets/loading_indicator.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReturningBatchScreen extends StatefulWidget {
  const ReturningBatchScreen({super.key});

  @override
  State<ReturningBatchScreen> createState() => ReturningBatchScreenState();
}

class ReturningBatchScreenState extends State<ReturningBatchScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BatchProvider>().fetchBatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: 'Select a Batch for Return Trip',
      child: Consumer<BatchProvider>(
        builder: (context, batchProvider, child) {
          if (batchProvider.state == ViewState.loading &&
              batchProvider.batches.isEmpty) {
            return const LoadingIndicator();
          }

          if (batchProvider.state == ViewState.error) {
            return StatusMessage(
              icon: Icons.error_outline,
              title: 'Unable to fetch batches',
              message: batchProvider.errorMessage ?? 'Please try again later.',
              onRetry: () => batchProvider.fetchBatches(),
            );
          }

          if (batchProvider.batches.isEmpty) {
            return const StatusMessage(
              icon: Icons.assignment_return_outlined,
              title: 'No batches found',
            );
          }

          return RefreshIndicator(
            onRefresh: () => batchProvider.fetchBatches(),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: batchProvider.batches.length,
              itemBuilder: (context, index) {
                final batch = batchProvider.batches[index];
                return Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReturnCommuterListScreen(
                            batchId: batch.id.toString(),
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  batch.batchName ?? 'N/A',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          InfoRow(
                            icon: Icons.assignment_return,
                            label: 'Return Time',
                            value: batch.returnTime?.substring(0, 5) ?? 'N/A',
                          ),
                          const InfoRow(
                            icon: Icons.people,
                            label: 'Students',
                            value: 'N/A',
                          ),
                          const InfoRow(
                            icon: Icons.person,
                            label: 'Driver',
                            value: 'N/A',
                          ),
                        ],
                      ),
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
