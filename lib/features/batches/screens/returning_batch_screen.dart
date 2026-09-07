import 'package:cts/app/router/route_names.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/batches/models/batch_model.dart';
import 'package:cts/features/batches/providers/batch_controller.dart';
import 'package:cts/features/batches/providers/return_batch_provider.dart';
import 'package:cts/features/batches/widgets/return_batch_picker_card.dart';
import 'package:cts/theme/cts_colors.dart';
import 'package:cts/widgets/cts_brand_logo.dart';
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
    final cts = context.cts;

    return DashboardShell(
      title: 'Select a Batch for Return Trip',
      quietBrandAppBar: true,
      titleWidget: const CtsBrandLogo(height: 32),
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
          final theme = Theme.of(context);

          return RefreshIndicator(
            onRefresh: _refresh,
            child: Builder(
              builder: (context) {
                final screenWidth = MediaQuery.sizeOf(context).width;
                final useList = ReturnBatchPickerLayout.useListLayout(
                  screenWidth: screenWidth,
                  anyPoolExtras: anyPoolExtras,
                );

                final header = Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RETURN TRIP',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cts.navy,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Select a batch',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: cts.navy,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                );

                if (useList) {
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: batches.length + 1,
                    separatorBuilder: (_, index) =>
                        SizedBox(height: index == 0 ? 16 : 12),
                    itemBuilder: (context, index) {
                      if (index == 0) return header;
                      return _buildCard(
                        context,
                        batches[index - 1],
                        returnProvider,
                        compact: true,
                      );
                    },
                  );
                }

                final crossAxisCount = screenWidth > 600 ? 3 : 2;
                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: header),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio:
                              ReturnBatchPickerLayout.gridChildAspectRatio(
                            anyPoolExtras: anyPoolExtras,
                          ),
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return _buildCard(
                              context,
                              batches[index],
                              returnProvider,
                            );
                          },
                          childCount: batches.length,
                        ),
                      ),
                    ),
                  ],
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
