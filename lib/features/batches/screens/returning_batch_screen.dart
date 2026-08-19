import 'package:cts/app/router/route_names.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/batches/models/batch_model.dart';
import 'package:cts/features/batches/providers/batch_controller.dart';
import 'package:cts/features/batches/providers/return_batch_provider.dart';
import 'package:cts/features/batches/widgets/return_batch_picker_card.dart';
import 'package:cts/widgets/dashboard_shell.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadStatuses());
  }

  Future<void> _loadStatuses() async {
    final batchProvider = context.read<BatchProvider>();
    await batchProvider.fetchBatches();
    if (!mounted) return;

    final batchIds = _batchIds(batchProvider.batches);
    if (batchIds.isNotEmpty) {
      await context.read<ReturnBatchProvider>().fetchStatusesForBatches(
        batchIds,
      );
    }
  }

  Future<void> _refresh() => _loadStatuses();

  List<String> _batchIds(List<BatchModel> batches) {
    return batches
        .map((batch) => batch.id?.toString())
        .whereType<String>()
        .toList();
  }

  bool _anyPoolExtras(
    ReturnBatchProvider returnProvider,
    List<BatchModel> batches,
  ) {
    return batches.any((batch) {
      final batchId = batch.id?.toString() ?? '';
      return returnProvider.statusForBatch(batchId)?.hasPoolExtras == true;
    });
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

          final batches = batchProvider.batches;
          final anyPoolExtras = _anyPoolExtras(returnProvider, batches);

          return RefreshIndicator(
            onRefresh: _refresh,
            child: Builder(
              builder: (context) {
                final screenWidth = MediaQuery.sizeOf(context).width;
                final useList = ReturnBatchPickerLayout.useListLayout(
                  screenWidth: screenWidth,
                  anyPoolExtras: anyPoolExtras,
                );

                if (useList) {
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: batches.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildCard(
                        context,
                        batches[index],
                        returnProvider,
                        compact: true,
                      );
                    },
                  );
                }

                final crossAxisCount = screenWidth > 600 ? 3 : 2;
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio:
                        ReturnBatchPickerLayout.gridChildAspectRatio(
                      anyPoolExtras: anyPoolExtras,
                    ),
                  ),
                  itemCount: batches.length,
                  itemBuilder: (context, index) {
                    return _buildCard(
                      context,
                      batches[index],
                      returnProvider,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    BatchModel batch,
    ReturnBatchProvider returnProvider, {
    bool compact = false,
  }) {
    final batchId = batch.id?.toString() ?? '';
    final status = returnProvider.statusForBatch(batchId);

    return ReturnBatchPickerCard(
      batch: batch,
      status: status,
      compact: compact,
      onTap: batchId.isEmpty
          ? null
          : () => context.push('${RouteName.returnCommuterScreen}/$batchId'),
    );
  }
}
