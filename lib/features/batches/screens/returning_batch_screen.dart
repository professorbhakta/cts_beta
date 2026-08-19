import 'package:cts/app/router/route_names.dart';
import 'package:cts/appManager/colors.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/batches/providers/batch_controller.dart';
import 'package:cts/features/batches/providers/return_batch_provider.dart';
import 'package:cts/widgets/dashboard_shell.dart';
import 'package:cts/widgets/modern_list_card.dart';
import 'package:cts/widgets/loading_indicator.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final batchProvider = context.read<BatchProvider>();
      await batchProvider.fetchBatches();
      if (!mounted) return;

      final batchIds = batchProvider.batches
          .map((batch) => batch.id?.toString())
          .whereType<String>()
          .toList();
      if (batchIds.isNotEmpty) {
        await context.read<ReturnBatchProvider>().fetchStatusesForBatches(
          batchIds,
        );
      }
    });
  }

  Future<void> _refresh() async {
    final batchProvider = context.read<BatchProvider>();
    await batchProvider.fetchBatches();
    if (!mounted) return;

    final batchIds = batchProvider.batches
        .map((batch) => batch.id?.toString())
        .whereType<String>()
        .toList();
    if (batchIds.isNotEmpty) {
      await context.read<ReturnBatchProvider>().fetchStatusesForBatches(
        batchIds,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: 'Select a Batch for Return Trip',
      child: Consumer2<BatchProvider, ReturnBatchProvider>(
        builder: (context, batchProvider, returnProvider, child) {
          if (batchProvider.state == ViewState.loading &&
              batchProvider.batches.isEmpty) {
            return const LoadingIndicator();
          }

          if (batchProvider.state == ViewState.error) {
            return StatusMessage(
              icon: Icons.error_outline,
              title: 'Unable to fetch batches',
              message: batchProvider.errorMessage ?? 'Please try again later.',
              onRetry: _refresh,
            );
          }

          if (batchProvider.batches.isEmpty) {
            return const StatusMessage(
              icon: Icons.assignment_return_outlined,
              title: 'No batches found',
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              itemCount: batchProvider.batches.length,
              itemBuilder: (context, index) {
                final batch = batchProvider.batches[index];
                final batchId = batch.id?.toString() ?? '';
                final status = returnProvider.statusForBatch(batchId);

                return Card(
                  child: InkWell(
                    onTap: batchId.isEmpty
                        ? null
                        : () => context.push(
                            '${RouteName.returnCommuterScreen}/$batchId',
                          ),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        batch.batchName ?? 'N/A',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (batch.driver?.userId?.username !=
                                              null &&
                                          batch
                                              .driver!
                                              .userId!
                                              .username!
                                              .isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          batch.driver!.userId!.username!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.65),
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (status?.isActive == true)
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: AppColors.acGreen,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                else
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
                            InfoRow(
                              icon: Icons.people,
                              label: 'Available',
                              value: status != null
                                  ? '${status.availableCount}'
                                  : '…',
                            ),
                            InfoRow(
                              icon: Icons.event_seat,
                              label: 'Seats left',
                              value: status != null
                                  ? '${status.remainingCapacity}/${status.totalCapacity}'
                                  : '…',
                            ),
                            InfoRow(
                              icon: Icons.check_circle_outline,
                              label: 'Confirmed',
                              value: status != null
                                  ? '${status.confirmedCount}'
                                  : '…',
                            ),
                            if (status?.hasPoolExtras == true) ...[
                              InfoRow(
                                icon: Icons.home_outlined,
                                label: 'Home hold',
                                value: '${status!.homeHold}',
                              ),
                              InfoRow(
                                icon: Icons.swap_horiz,
                                label: 'Overflow in',
                                value: '${status.overflowConfirmed}',
                              ),
                              InfoRow(
                                icon: Icons.airline_seat_recline_normal,
                                label: 'Overflow open',
                                value: '${status.overflowRemaining}',
                              ),
                            ],
                          ],
                        ),
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
