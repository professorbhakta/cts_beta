import 'dart:async';

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
import 'package:cts/widgets/cts_brand_logo.dart';
import 'package:cts/widgets/dashboard_shell.dart';
import 'package:cts/widgets/list_item_actions_sheet.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

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

  void _openAddBatch() {
    context.read<BatchFormProvider>().clearAll();
    context.push(RouteName.batchForm);
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
    final cts = context.cts;
    final theme = Theme.of(context);

    return DashboardShell(
      title: 'Batches',
      quietBrandAppBar: true,
      titleWidget: const CtsBrandLogo(height: 32),
      child: Consumer<BatchProvider>(
        builder: (context, bc, child) {
          if (bc.state == ViewState.loading && bc.batches.isEmpty) {
            return _BatchSkeleton(onSearchChanged: _onSearchChanged);
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
              onAction: _openAddBatch,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'Batches',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: cts.navy,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          context.push(RouteName.returnBatchScreen),
                      style: TextButton.styleFrom(
                        foregroundColor: cts.navy,
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'RETURN BATCHES',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cts.navy,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _HairlineSearchField(
                hintText: 'Search batches by name or time...',
                onSearchChanged: _onSearchChanged,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: Material(
                    color: cts.yellow,
                    borderRadius: BorderRadius.circular(4),
                    child: InkWell(
                      onTap: _openAddBatch,
                      borderRadius: BorderRadius.circular(4),
                      child: Center(
                        child: Text(
                          'ADD BATCH',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: cts.navy,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => bc.fetchBatches(),
                  child: filteredBatches.isEmpty && _searchQuery.isNotEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            StatusMessage(
                              icon: Icons.search_off,
                              title: 'No batches match your search',
                            ),
                          ],
                        )
                      : CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            _BatchList(
                              batches: filteredBatches,
                              onEdit: _showEditDialog,
                              onDelete: _showDeleteDialog,
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  4,
                                  16,
                                  24,
                                ),
                                child: Text(
                                  'Swipe to edit or delete • tap to open commuters',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: cts.navy.withValues(alpha: 0.55),
                                  ),
                                ),
                              ),
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

class _HairlineSearchField extends StatefulWidget {
  const _HairlineSearchField({
    required this.hintText,
    required this.onSearchChanged,
  });

  final String hintText;
  final ValueChanged<String> onSearchChanged;

  @override
  State<_HairlineSearchField> createState() => _HairlineSearchFieldState();
}

class _HairlineSearchFieldState extends State<_HairlineSearchField> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      widget.onSearchChanged(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;
    final hairline = cts.navy.withValues(alpha: 0.14);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _controller,
        onChanged: (value) {
          setState(() {});
          _onChanged(value);
        },
        style: theme.textTheme.bodyMedium?.copyWith(color: cts.navy),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: cts.navy.withValues(alpha: 0.45),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: cts.navy.withValues(alpha: 0.55),
            size: 20,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: cts.navy.withValues(alpha: 0.55),
                    size: 18,
                  ),
                  onPressed: () {
                    _controller.clear();
                    widget.onSearchChanged('');
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: theme.scaffoldBackgroundColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: hairline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: hairline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: cts.navy.withValues(alpha: 0.35)),
          ),
        ),
      ),
    );
  }
}

class _BatchSkeleton extends StatelessWidget {
  const _BatchSkeleton({required this.onSearchChanged});

  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final cts = context.cts;
    final theme = Theme.of(context);
    final base = cts.navy.withValues(alpha: 0.08);
    final highlight = cts.navy.withValues(alpha: 0.03);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(
            'Batches',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: cts.navy,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _HairlineSearchField(
          hintText: 'Search batches by name or time...',
          onSearchChanged: onSearchChanged,
        ),
        Expanded(
          child: Shimmer.fromColors(
            baseColor: base,
            highlightColor: highlight,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: 6,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, _) => Container(
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ],
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
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      sliver: SliverList.separated(
        itemCount: batches.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
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
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
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
                  foregroundColor: scheme.onPrimary,
                  icon: Icons.edit_rounded,
                  label: 'Edit',
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  flex: 1,
                ),
              ],
            ),
            child: _BatchCatalogCard(
              batch: batch,
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
            ),
          );
        },
      ),
    );
  }
}

class _BatchCatalogCard extends StatelessWidget {
  const _BatchCatalogCard({
    required this.batch,
    required this.onTap,
    required this.onLongPress,
  });

  final BatchModel batch;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  String? get _driverLabel {
    final user = batch.driver?.userId;
    final full = [
      user?.firstName,
      user?.lastName,
    ].whereType<String>().where((n) => n.isNotEmpty).join(' ');
    if (full.isNotEmpty) return full;
    final username = user?.username;
    if (username != null && username.isNotEmpty) return username;
    return null;
  }

  String _timeLabel(String? raw) {
    if (raw == null || raw.isEmpty) return 'N/A';
    if (raw.length >= 5) return raw.substring(0, 5);
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;
    final hairline = cts.navy.withValues(alpha: 0.14);
    final driver = _driverLabel;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: hairline, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  batch.batchName ?? 'Untitled Batch',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: cts.navy,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (driver != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    driver,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cts.navy.withValues(alpha: 0.65),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _TimeCell(
                        value: _timeLabel(batch.batchTime),
                        label: 'Start time',
                      ),
                    ),
                    Expanded(
                      child: _TimeCell(
                        value: _timeLabel(batch.returnTime),
                        label: 'Return time',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeCell extends StatelessWidget {
  const _TimeCell({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: cts.navy,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: cts.navy.withValues(alpha: 0.65),
          ),
        ),
      ],
    );
  }
}
