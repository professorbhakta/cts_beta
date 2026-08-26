import 'package:cts/theme/cts_colors.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:cts/appManager/snackbar_service.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/batches/models/batch_model.dart';
import 'package:cts/features/batches/providers/batch_controller.dart';
import 'package:cts/features/batches/providers/batch_form_provider.dart';
import 'package:cts/features/commuters/screens/commuter_list_screen.dart';
import 'package:cts/utils/sort_utils.dart';
import 'package:cts/widgets/confirmation_dialog.dart';
import 'package:cts/widgets/dashboard_shell.dart';
import 'package:cts/widgets/list_item_actions_sheet.dart';
import 'package:cts/widgets/modern_list_card.dart';
import 'package:cts/widgets/search_bar_widget.dart';
import 'package:cts/widgets/skeleton_list.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class BatchScreen extends StatefulWidget {
  const BatchScreen({super.key});

  @override
  State<BatchScreen> createState() => BatchScreenState();
}

class BatchScreenState extends State<BatchScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BatchProvider>().fetchBatches();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  List<BatchModel> _getFilteredBatches(List<BatchModel> allBatches) {
    List<BatchModel> filtered = _searchQuery.isEmpty
        ? allBatches
        : allBatches.where((batch) {
            final name = (batch.batchName ?? '').toLowerCase();
            final time = (batch.batchTime ?? '').toLowerCase();
            final returnTime = (batch.returnTime ?? '').toLowerCase();
            return name.contains(_searchQuery) ||
                time.contains(_searchQuery) ||
                returnTime.contains(_searchQuery);
          }).toList();

    return sortListAZ(filtered, (batch) => batch.batchName ?? '');
  }

  void _showEditDialog(BatchModel batch) {
    final formProvider = context.read<BatchFormProvider>();
    formProvider.forUpdate = true;
    formProvider.updateId = batch.id ?? 0;
    formProvider.nameCtrl.text = batch.batchName ?? "";

    formProvider.startDate = DateTime.tryParse(batch.startDate ?? '');
    formProvider.endDate = DateTime.tryParse(batch.endDate ?? '');

    final startTimeParts = batch.batchTime?.split(':');
    if (startTimeParts?.length == 2) {
      formProvider.startTime = TimeOfDay(
        hour: int.parse(startTimeParts![0]),
        minute: int.parse(startTimeParts[1]),
      );
    } else {
      formProvider.startTime = null;
    }

    final returnTimeParts = batch.returnTime?.split(':');
    if (returnTimeParts?.length == 2) {
      formProvider.returnTime = TimeOfDay(
        hour: int.parse(returnTimeParts![0]),
        minute: int.parse(returnTimeParts[1]),
      );
    } else {
      formProvider.returnTime = null;
    }

    context.push(RouteName.batchForm);
  }

  void _showDeleteDialog(BatchModel batch) {
    final batchProvider = context.read<BatchProvider>();
    ConfirmationDialog.showDeleteConfirmation(
      context,
      itemName: 'Batch',
      customMessage:
          'Are you sure you want to delete "${batch.batchName ?? 'this batch'}"? This action cannot be undone.',
    ).then((confirmed) async {
      if (confirmed == true) {
        final success = await batchProvider.deleteBatch(batch.id ?? 0);
        if (mounted && !success) {
          SnackBarService.showErrorSnackbar(
            batchProvider.errorMessage ?? 'Failed to delete batch.',
          );
        } else if (mounted) {
          SnackBarService.showsSuccessSnackbar(
            'Batch deleted successfully!',
            '',
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return DashboardShell(
      title: 'Batches',
      actions: [
        IconButton(
          icon: Icon(Icons.assignment_returned_outlined),
          tooltip: 'Return Batches',
          onPressed: () {
            context.push(RouteName.returnBatchScreen);
          },
        ),
        IconButton(
          icon: Icon(Icons.add),
          tooltip: 'Add Batch',
          onPressed: () {
            context.read<BatchFormProvider>().clearAll();
            context.push(RouteName.batchForm);
          },
        ),
      ],
      child: Consumer<BatchProvider>(
        builder: (context, bc, child) {

          if (bc.state == ViewState.loading && bc.batches.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'All Batches',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage Batches and keep them updated.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),
                const BatchSkeletonList(itemCount: 8),
              ],
            );
          }

          if (bc.state == ViewState.error) {
            return StatusMessage.error(
              title: bc.errorMessage ?? 'Failed to load batches',
              message: 'Please check your connection and try again.',
              onRetry: () => bc.fetchBatches(),
            );
          }

          final filteredBatches = _getFilteredBatches(bc.batches);

          if (bc.batches.isEmpty) {
            return StatusMessage.empty(
              icon: Icons.inbox_outlined,
              title: 'No batches found',
              message: 'Get started by creating your first batch.',
              actionLabel: 'Create Batch',
              onAction: () {
                context.read<BatchFormProvider>().clearAll();
                context.push(RouteName.batchForm);
              },
            );
          }

          return Column(
            children: [
              SearchBarWidget(
                hintText: 'Search batches by name or time...',
                onSearchChanged: _onSearchChanged,
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => bc.fetchBatches(),
                  child: filteredBatches.isEmpty && _searchQuery.isNotEmpty
                      ? const StatusMessage(
                          icon: Icons.search_off,
                          title: 'No batches match your search',
                        )
                      : CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                              sliver: SliverToBoxAdapter(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'All Batches',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Manage batches and keep them updated.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.7),
                                          ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ),
                            _BatchList(
                              batches: filteredBatches,
                              onEdit: _showEditDialog,
                              onDelete: _showDeleteDialog,
                            ),
                          ],
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BatchList extends StatelessWidget {
  const _BatchList({
    required this.batches,
    required this.onEdit,
    required this.onDelete,
  });

  final List<BatchModel> batches;
  final void Function(BatchModel) onEdit;
  final void Function(BatchModel) onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      sliver: SliverList.separated(
        itemCount: batches.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final batch = batches[index];
          return Slidable(
            key: ValueKey(batch.id),
            startActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.25,
              dismissible: DismissiblePane(onDismissed: () => onDelete(batch)),
              children: [
                SlidableAction(
                  onPressed: (_) => onDelete(batch),
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.surface,
                  icon: Icons.delete_rounded,
                  label: 'Delete',
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  flex: 1,
                ),
              ],
            ),
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.25,
              children: [
                SlidableAction(
                  onPressed: (_) => onEdit(batch),
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.surface,
                  icon: Icons.edit_rounded,
                  label: 'Edit',
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  flex: 1,
                ),
              ],
            ),
            child: ModernListCard(
              title: batch.batchName ?? 'Untitled Batch',
              icon: Icons.event_rounded,
              iconColor: scheme.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CommuterListScreen(
                      batchId: batch.id.toString(),
                      batchName: batch.batchName ?? '',
                    ),
                  ),
                );
              },
              onLongPress: () => ListItemActionsSheet.show(
                context,
                onEdit: () => onEdit(batch),
                onDelete: () => onDelete(batch),
              ),
              children: [
                InfoRow(
                  icon: Icons.access_time_rounded,
                  label: 'Start Time:',
                  value: batch.batchTime?.substring(0, 5) ?? 'N/A',
                  iconColor: scheme.primary,
                ),
                InfoRow(
                  icon: Icons.access_time_rounded,
                  label: 'Return Time:',
                  value: batch.returnTime?.substring(0, 5) ?? 'N/A',
                  iconColor: scheme.primary,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
