import 'package:cts/appManager/colors.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:cts/appManager/snackbar_service.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/pops/presentation/providers/pop_controller.dart';
import 'package:cts/features/pops/presentation/providers/pop_form_provider.dart';
import 'package:cts/models/pop_model.dart';
import 'package:cts/utils/pop_sort_options.dart';
import 'package:cts/utils/sort_utils.dart';
import 'package:cts/shared/widgets/confirmation_dialog.dart';
import 'package:cts/shared/widgets/dashboard_shell.dart';
import 'package:cts/shared/widgets/modern_list_card.dart';
import 'package:cts/shared/widgets/search_bar_widget.dart';
import 'package:cts/shared/widgets/skeleton_list.dart';
import 'package:cts/shared/widgets/sort_dropdown_widget.dart';
import 'package:cts/shared/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class PopScreen extends StatefulWidget {
  const PopScreen({super.key});

  @override
  State<PopScreen> createState() => _PopScreenState();
}

class _PopScreenState extends State<PopScreen> {
  String _searchQuery = '';
  PopSortOption _selectedSortOption = PopSortOption.nameAZ;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PopProvider>().fetchPops();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  void _onSortChanged(PopSortOption option) {
    setState(() {
      _selectedSortOption = option;
    });
  }

  List<PickUpPointModel> _getFilteredAndSortedPops(
    List<PickUpPointModel> allPops,
  ) {
    // First filter by search query
    List<PickUpPointModel> filtered = _searchQuery.isEmpty
        ? allPops
        : allPops.where((pop) {
            final name = (pop.pickUpPointName ?? '').toLowerCase();
            final routeName = (pop.routeId?.routeName ?? '').toLowerCase();
            final inline = pop.inLine.toString();
            return name.contains(_searchQuery) ||
                routeName.contains(_searchQuery) ||
                inline.contains(_searchQuery);
          }).toList();

    // Then sort according to selected sort option
    return sortPopList(filtered, _selectedSortOption);
  }

  List<SortOption<PopSortOption>> _getSortOptions() {
    return [
      SortOption(
        label: 'POP Name',
        subLabel: 'A-Z',
        value: PopSortOption.nameAZ,
        icon: Icons.sort_by_alpha,
      ),
      SortOption(
        label: 'POP Name',
        subLabel: 'Z-A',
        value: PopSortOption.nameZA,
        icon: Icons.sort_by_alpha,
      ),
      SortOption(
        label: 'Route Name',
        subLabel: 'A-Z',
        value: PopSortOption.routeAZ,
        icon: Icons.route,
      ),
      SortOption(
        label: 'Route Name',
        subLabel: 'Z-A',
        value: PopSortOption.routeZA,
        icon: Icons.route,
      ),
      SortOption(
        label: 'Stop Number',
        subLabel: '0-9',
        value: PopSortOption.inlineAsc,
        icon: Icons.numbers,
      ),
      SortOption(
        label: 'Stop Number',
        subLabel: '9-0',
        value: PopSortOption.inlineDesc,
        icon: Icons.numbers,
      ),
    ];
  }

  // MODIFIED: Accepts the model object directly for type safety
  void _showEditDialog(PickUpPointModel pop) {
    final formProvider = context.read<PopFormProvider>();
    formProvider.nameCtrl.text = pop.pickUpPointName ?? "";
    formProvider.inLine.text = pop.inLine.toString();
    formProvider.selectedRouteId = pop.routeId?.id;
    formProvider.updateId = pop.id ?? 0;
    formProvider.forUpdate = true;
    context.push(RouteName.popForm);
  }

  // MODIFIED: Accepts the model object directly for type safety
  void _showDeleteDialog(PickUpPointModel pop) {
    final controller = context.read<PopProvider>();
    ConfirmationDialog.showDeleteConfirmation(
      context,
      itemName: 'Pick-up Point',
      customMessage:
          'Are you sure you want to delete "${pop.pickUpPointName ?? 'this pick-up point'}"? This action cannot be undone.',
    ).then((confirmed) async {
      if (confirmed == true) {
        final success = await controller.deletePop(pop.id ?? 0);
        if (!mounted) return;
        if (!success) {
          SnackBarService.showErrorSnackbar(
            controller.errorMessage ?? 'Failed to delete pick-up point.',
          );
        }
        // Success snackbar is already shown in repository
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: 'Pick-Up Points',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Add POP',
          iconSize: 36,
          onPressed: () {
            context.read<PopFormProvider>().clearAll();
            context.push(RouteName.popForm);
          },
        ),
      ],
      child: Consumer<PopProvider>(
        builder: (context, popCtrl, child) {
          // Show skeleton loader on initial load
          if (popCtrl.state == ViewState.loading && popCtrl.pops.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'All Pick-Up Points',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage pickup locations and keep them updated.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const PopSkeletonList(itemCount: 8),
                    ],
                  ),
                ),
              ],
            );
          }

          if (popCtrl.state == ViewState.error) {
            return StatusMessage.error(
              title: popCtrl.errorMessage ?? 'Failed to load pick-up points',
              message: 'Please check your connection and try again.',
              onRetry: () => popCtrl.fetchPops(),
            );
          }

          // Get filtered and sorted POPs
          final filteredPops = _getFilteredAndSortedPops(popCtrl.pops);

          if (popCtrl.pops.isEmpty) {
            return StatusMessage.empty(
              icon: Icons.location_off_outlined,
              title: 'No pick-up points found',
              message: 'Get started by creating your first pick-up point.',
              actionLabel: 'Create POP',
              onAction: () {
                context.read<PopFormProvider>().clearAll();
                context.push(RouteName.popForm);
              },
            );
          }

          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SearchBarWidget(
                      hintText: 'Search by name, route, or inline number...',
                      onSearchChanged: _onSearchChanged,
                    ),
                  ),
                  SortDropdownWidget<PopSortOption>(
                    options: _getSortOptions(),
                    selectedValue: _selectedSortOption,
                    onSortChanged: _onSortChanged,
                    icon: Icons.sort,
                    tooltip: 'Sort pick-up points',
                  ),
                ],
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => popCtrl.fetchPops(),
                  child: filteredPops.isEmpty && _searchQuery.isNotEmpty
                      ? const StatusMessage(
                          icon: Icons.search_off,
                          title: 'No pick-up points match your search',
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
                                      'All Pick-Up Points',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Manage pickup locations and keep them updated.',
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
                            _PopList(
                              pops: filteredPops,
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

// START INSERTION: The new, modern, decoupled widget
class _PopList extends StatelessWidget {
  const _PopList({
    required this.pops,
    required this.onEdit,
    required this.onDelete,
  });

  final List<PickUpPointModel> pops;
  final void Function(PickUpPointModel) onEdit;
  final void Function(PickUpPointModel) onDelete;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      sliver: SliverList.separated(
        itemCount: pops.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final pop = pops[index];
          return Slidable(
          key: ValueKey(pop.id),
          startActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.25,
            dismissible: DismissiblePane(onDismissed: () => onDelete(pop)),
            children: [
              SlidableAction(
                onPressed: (_) => onDelete(pop),
                backgroundColor: AppColors.acRed,
                foregroundColor: AppColors.acWhite,
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
                onPressed: (_) => onEdit(pop),
                backgroundColor: AppColors.acYellowWarm,
                foregroundColor: AppColors.acWhite,
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
            title: pop.pickUpPointName ?? 'Unnamed Pick-Up Point',
            icon: Icons.location_on_rounded,
            iconColor: AppColors.acYellowWarm,
            trailing: PopupMenuButton<String>(
              tooltip: 'More options',
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit(pop);
                } else if (value == 'delete') {
                  onDelete(pop);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(
                      Icons.edit_outlined,
                      color: AppColors.acYellowWarm,
                    ),
                    title: const Text('Edit'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete_outline, color: AppColors.acRed),
                    title: Text(
                      'Delete',
                      style: TextStyle(color: AppColors.acRed),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            children: [
              InfoRow(
                icon: Icons.route_rounded,
                label: 'Route:',
                value: pop.routeId?.routeName ?? 'N/A',
                iconColor: AppColors.acYellowWarm,
              ),
              InfoRow(
                icon: Icons.numbers_rounded,
                label: 'Stop Number:',
                value: pop.inLine?.toString() ?? 'N/A',
                iconColor: AppColors.acYellowWarm,
              ),
            ],
          ),
          );
        },
      ),
    );
  }
}

// END INSERTION
