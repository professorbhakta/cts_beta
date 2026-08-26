import 'package:cts/theme/cts_colors.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:cts/appManager/snackbar_service.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/commuters/providers/commuter_controller.dart';
import 'package:cts/features/commuters/providers/commuter_form_provider.dart';
import 'package:cts/features/commuters/models/commuter_model.dart';
import 'package:cts/features/commuters/utils/commuter_sort_options.dart';
import 'package:cts/features/commuters/utils/commuter_sort_utils.dart';
import 'package:cts/widgets/admin_search_sort_row.dart';
import 'package:cts/widgets/coming_today_switch.dart';
import 'package:cts/widgets/confirmation_dialog.dart';
import 'package:cts/widgets/dashboard_shell.dart';
import 'package:cts/widgets/list_item_actions_sheet.dart';
import 'package:cts/widgets/modern_list_card.dart';
import 'package:cts/widgets/skeleton_list.dart';
import 'package:cts/widgets/sort_dropdown_widget.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class CommuterScreen extends StatefulWidget {
  const CommuterScreen({super.key});

  @override
  State<CommuterScreen> createState() => _CommuterScreenState();
}

class _CommuterScreenState extends State<CommuterScreen> {
  String _searchQuery = '';
  CommuterSortOption _selectedSortOption = CommuterSortOption.nameAZ;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommuterController>().fetchCommuters();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  void _onSortChanged(CommuterSortOption option) {
    setState(() {
      _selectedSortOption = option;
    });
  }

  List<CommuterModel> _getFilteredAndSortedCommuters(
    List<CommuterModel> allCommuters,
  ) {
    // First filter by search query
    List<CommuterModel> filtered = _searchQuery.isEmpty
        ? allCommuters
        : allCommuters.where((commuter) {
            final name = (commuter.userId?.username ?? '').toLowerCase();
            final mobile = (commuter.userId?.mobileNumber ?? '').toLowerCase();
            final college = (commuter.collegeName ?? '').toLowerCase();
            final address = (commuter.userId?.address ?? '').toLowerCase();
            final batchName = (commuter.batchId?.batchName ?? '').toLowerCase();
            return name.contains(_searchQuery) ||
                mobile.contains(_searchQuery) ||
                college.contains(_searchQuery) ||
                address.contains(_searchQuery) ||
                batchName.contains(_searchQuery);
          }).toList();

    // Then sort according to selected sort option
    return sortCommuterList(filtered, _selectedSortOption);
  }

  List<SortOption<CommuterSortOption>> _getSortOptions() {
    return [
      SortOption(
        label: 'Name',
        subLabel: 'A-Z',
        value: CommuterSortOption.nameAZ,
        icon: Icons.person,
      ),
      SortOption(
        label: 'Name',
        subLabel: 'Z-A',
        value: CommuterSortOption.nameZA,
        icon: Icons.person,
      ),
      SortOption(
        label: 'Mobile',
        subLabel: 'A-Z',
        value: CommuterSortOption.mobileAZ,
        icon: Icons.phone,
      ),
      SortOption(
        label: 'Mobile',
        subLabel: 'Z-A',
        value: CommuterSortOption.mobileZA,
        icon: Icons.phone,
      ),
      SortOption(
        label: 'Batch',
        subLabel: 'A-Z',
        value: CommuterSortOption.batchAZ,
        icon: Icons.groups,
      ),
      SortOption(
        label: 'Batch',
        subLabel: 'Z-A',
        value: CommuterSortOption.batchZA,
        icon: Icons.groups,
      ),
      SortOption(
        label: 'Cab',
        subLabel: 'A-Z',
        value: CommuterSortOption.cabRegAZ,
        icon: Icons.directions_car,
      ),
      SortOption(
        label: 'Cab',
        subLabel: 'Z-A',
        value: CommuterSortOption.cabRegZA,
        icon: Icons.directions_car,
      ),
      SortOption(
        label: 'College',
        subLabel: 'A-Z',
        value: CommuterSortOption.collegeAZ,
        icon: Icons.school,
      ),
      SortOption(
        label: 'College',
        subLabel: 'Z-A',
        value: CommuterSortOption.collegeZA,
        icon: Icons.school,
      ),
      SortOption(
        label: 'POP',
        subLabel: 'A-Z',
        value: CommuterSortOption.popAZ,
        icon: Icons.location_on,
      ),
      SortOption(
        label: 'POP',
        subLabel: 'Z-A',
        value: CommuterSortOption.popZA,
        icon: Icons.location_on,
      ),
      SortOption(
        label: 'Route',
        subLabel: 'A-Z',
        value: CommuterSortOption.routeAZ,
        icon: Icons.route,
      ),
      SortOption(
        label: 'Route',
        subLabel: 'Z-A',
        value: CommuterSortOption.routeZA,
        icon: Icons.route,
      ),
    ];
  }

  // START MODIFICATION: Update signature to be type-safe
  void _showEditDialog(CommuterModel commuter) {
    context.read<CommuterFormProvider>().fillFromCommuter(commuter);
    context.push(RouteName.commuterForm);
  }

  void _showDeleteDialog(CommuterModel commuter) {
    final controller = context.read<CommuterController>();
    ConfirmationDialog.showDeleteConfirmation(
      context,
      itemName: 'Commuter',
      customMessage:
          'Are you sure you want to delete "${commuter.userId?.username ?? 'this commuter'}"? This action cannot be undone.',
    ).then((confirmed) async {
      if (confirmed == true) {
        final success = await controller.deleteCommuter(
          commuter.userId?.id ?? 0,
        );
        if (!mounted) return;
        if (!success) {
          SnackBarService.showErrorSnackbar(
            controller.errorMessage ?? 'Failed to delete commuter.',
          );
        } else {
          SnackBarService.showsSuccessSnackbar(
            'Commuter deleted successfully!',
            '',
          );
        }
      }
    });
  }

  Future<void> _onMarkAllComing() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {

        final theme = Theme.of(dialogContext);
        return ConfirmationDialog(
          title: 'Mark all coming?',
          message:
              'Set Coming today to ON for every commuter in your organization.',
          confirmLabel: 'Mark all',
          cancelLabel: 'Cancel',
          icon: Icons.done_all,
          iconColor: theme.colorScheme.primary,
        );
      },
    );
    if (confirmed != true || !mounted) return;

    final controller = context.read<CommuterController>();
    final updated = await controller.markAllComing();
    if (!mounted) return;
    if (updated == null) {
      SnackBarService.showErrorSnackbar(
        controller.errorMessage ?? 'Failed to mark all coming.',
      );
    } else {
      SnackBarService.showsSuccessSnackbar(
        'Marked $updated commuter${updated == 1 ? '' : 's'} coming.',
        '',
      );
    }
  }
  // END MODIFICATION

  @override
  Widget build(BuildContext context) {

    return DashboardShell(
      title: 'Commuters',
      actions: [
        Consumer<CommuterController>(
          builder: (context, cc, _) {

            final busy = cc.isMarkAllComingInFlight;
            return TextButton.icon(
              onPressed: busy ? null : _onMarkAllComing,
              icon: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.done_all),
              label: const Text('Mark all'),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.add),
          tooltip: 'Add Commuter',
          iconSize: 36,
          onPressed: () {
            final formProvider = context.read<CommuterFormProvider>();
            formProvider.clearAll();
            context.push(RouteName.commuterForm);
          },
        ),
      ],
      child: Consumer<CommuterController>(
        builder: (context, cc, child) {

          // Show skeleton loader on initial load
          if (cc.state == ViewState.loading && cc.commuters.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'All Commuter',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage Commuter and keep them updated on the Batch & Cabs.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),
                const CommuterSkeletonList(itemCount: 8),
              ],
            );
          }

          if (cc.state == ViewState.error) {
            return StatusMessage.error(
              title: cc.errorMessage ?? 'Failed to load commuters',
              message: 'Please check your connection and try again.',
              onRetry: () => cc.fetchCommuters(),
            );
          }

          // Get filtered and sorted commuters
          final filteredCommuters = _getFilteredAndSortedCommuters(
            cc.commuters,
          );

          if (cc.commuters.isEmpty) {
            return StatusMessage.empty(
              icon: Icons.people_outline,
              title: 'No commuters found',
              message: 'Get started by creating your first commuter.',
              actionLabel: 'Create Commuter',
              onAction: () {
                final formProvider = context.read<CommuterFormProvider>();
                formProvider.clearAll();
                context.push(RouteName.commuterForm);
              },
            );
          }

          return Column(
            children: [
              AdminSearchSortRow<CommuterSortOption>(
                hintText: 'Search by name, mobile, college, or batch...',
                onSearchChanged: _onSearchChanged,
                sortOptions: _getSortOptions(),
                selectedSort: _selectedSortOption,
                onSortChanged: _onSortChanged,
                sortTooltip: 'Sort commuters',
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => cc.fetchCommuters(),
                  child: filteredCommuters.isEmpty && _searchQuery.isNotEmpty
                      ? const StatusMessage(
                          icon: Icons.search_off,
                          title: 'No commuters match your search',
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
                                      'All Commuters',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Manage commuters and keep them updated on batches & cabs.',
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
                            _CommuterList(
                              commuters: filteredCommuters,
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

// START MODIFICATION: Create new decoupled list widget
class _CommuterList extends StatelessWidget {
  const _CommuterList({
    required this.commuters,
    required this.onEdit,
    required this.onDelete,
  });

  final List<CommuterModel> commuters;
  final void Function(CommuterModel) onEdit;
  final void Function(CommuterModel) onDelete;

  Future<void> _handleIsComingToggle(
    BuildContext context,
    CommuterModel commuter,
    bool newValue,
  ) async {
    final controller = context.read<CommuterController>();
    final userId = commuter.userId?.id;

    if (userId == null) {
      SnackBarService.showErrorSnackbar('Invalid commuter ID');
      return;
    }

    final success = await controller.updateCommuterIsComing(userId, newValue);

    if (!success && context.mounted) {
      SnackBarService.showErrorSnackbar(
        controller.errorMessage ?? 'Failed to update commuter status.',
      );
    }
  }

  Widget _buildDetailItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return InfoRow(
      icon: icon,
      label: label,
      value: value,
      iconColor: iconColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final cts = context.cts;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      sliver: SliverList.separated(
        itemCount: commuters.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final commuter = commuters[index];
          return Slidable(
          key: ValueKey(commuter.userId?.id ?? index),
          startActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.25,
            dismissible: DismissiblePane(onDismissed: () => onDelete(commuter)),
            children: [
              SlidableAction(
                onPressed: (_) => onDelete(commuter),
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
                onPressed: (_) => onEdit(commuter),
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
            title:
                '${commuter.userId?.id ?? ''} ${commuter.userId?.username ?? 'Untitled commuter'}'
                    .trim(),
            icon: Icons.person_rounded,
            iconColor: scheme.primary,
            onLongPress: () => ListItemActionsSheet.show(
              context,
              onEdit: () => onEdit(commuter),
              onDelete: () => onDelete(commuter),
            ),
            trailing: ComingTodaySwitch(
              value: commuter.isComing ?? false,
              onChanged: (value) =>
                  _handleIsComingToggle(context, commuter, value),
            ),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      Icons.route_rounded,
                      'Route:',
                      commuter.popId?.routeId?.routeName ?? 'N/A',
                      cts.info,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      Icons.event_rounded,
                      'Batch:',
                      commuter.batchId?.batchName ?? 'N/A',
                      cts.yellowDark,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      Icons.location_on_rounded,
                      'POP:',
                      commuter.popId?.pickUpPointName ?? 'N/A',
                      scheme.primary,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      Icons.directions_car_rounded,
                      'Cab:',
                      commuter.cabId?.regNumber ?? 'N/A',
                      cts.info,
                    ),
                  ),
                ],
              ),
            ],
          ),
          );
        },
      ),
    );
  }
}
