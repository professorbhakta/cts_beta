import 'package:cts/theme/cts_colors.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:cts/appManager/snackbar_service.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/cabs/providers/cab_controller.dart';
import 'package:cts/features/cabs/providers/cab_form_provider.dart';
import 'package:cts/models/cab_model.dart';
import 'package:cts/utils/cab_sort_options.dart';
import 'package:cts/utils/sort_utils.dart';
import 'package:cts/widgets/admin_search_sort_row.dart';
import 'package:cts/widgets/catalog_list_chrome.dart';
import 'package:cts/widgets/confirmation_dialog.dart';
import 'package:cts/widgets/cts_brand_logo.dart';
import 'package:cts/widgets/dashboard_shell.dart';
import 'package:cts/widgets/list_item_actions_sheet.dart';
import 'package:cts/widgets/sort_dropdown_widget.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class CabScreen extends StatefulWidget {
  const CabScreen({super.key});

  @override
  State<CabScreen> createState() => _CabScreenState();
}

class _CabScreenState extends State<CabScreen> {
  String _searchQuery = '';
  CabSortOption _selectedSortOption = CabSortOption.regNumberAZ;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CabProvider>().fetchCabs();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  void _onSortChanged(CabSortOption option) {
    setState(() {
      _selectedSortOption = option;
    });
  }

  List<CabModel> _getFilteredAndSortedCabs(List<CabModel> allCabs) {
    List<CabModel> filtered = _searchQuery.isEmpty
        ? allCabs
        : allCabs.where((cab) {
            final regNumber = (cab.regNumber ?? '').toLowerCase();
            final capacity = cab.capacity.toString();
            final km = cab.km.toString();
            final routeName = (cab.routeId?.routeName ?? '').toLowerCase();
            return regNumber.contains(_searchQuery) ||
                capacity.contains(_searchQuery) ||
                km.contains(_searchQuery) ||
                routeName.contains(_searchQuery);
          }).toList();

    return sortCabList(filtered, _selectedSortOption);
  }

  List<SortOption<CabSortOption>> _getSortOptions() {
    return [
      SortOption(
        label: 'Registration',
        subLabel: 'A-Z',
        value: CabSortOption.regNumberAZ,
        icon: Icons.confirmation_number,
      ),
      SortOption(
        label: 'Registration',
        subLabel: 'Z-A',
        value: CabSortOption.regNumberZA,
        icon: Icons.confirmation_number,
      ),
      SortOption(
        label: 'Route Name',
        subLabel: 'A-Z',
        value: CabSortOption.routeAZ,
        icon: Icons.route,
      ),
      SortOption(
        label: 'Route Name',
        subLabel: 'Z-A',
        value: CabSortOption.routeZA,
        icon: Icons.route,
      ),
      SortOption(
        label: 'Capacity',
        subLabel: '0-9',
        value: CabSortOption.capacityAsc,
        icon: Icons.event_seat,
      ),
      SortOption(
        label: 'Capacity',
        subLabel: '9-0',
        value: CabSortOption.capacityDesc,
        icon: Icons.event_seat,
      ),
      SortOption(
        label: 'Kilometers',
        subLabel: '0-9',
        value: CabSortOption.kmAsc,
        icon: Icons.straighten,
      ),
      SortOption(
        label: 'Kilometers',
        subLabel: '9-0',
        value: CabSortOption.kmDesc,
        icon: Icons.straighten,
      ),
    ];
  }

  void _openAddCab() {
    context.read<CabFormProvider>().clearAll();
    context.push(RouteName.cabForm);
  }

  void _showEditDialog(CabModel cab) {
    final formProvider = context.read<CabFormProvider>();
    formProvider.forUpdate = true;
    formProvider.updateId = cab.id ?? 0;
    formProvider.regNumberCtrl.text = cab.regNumber ?? "";
    formProvider.capacityCtrl.text = cab.capacity.toString();
    formProvider.kmCtrl.text = cab.km.toString();
    formProvider.trackingVehicleIdCtrl.text = cab.trackingVehicleId ?? "";
    formProvider.selectedRouteId = cab.routeId?.id;
    context.push(RouteName.cabForm);
  }

  void _showDeleteDialog(CabModel cab) {
    final controller = context.read<CabProvider>();
    ConfirmationDialog.showDeleteConfirmation(
      context,
      itemName: 'Cab',
      customMessage:
          'Are you sure you want to delete "${cab.regNumber ?? 'this cab'}"? This action cannot be undone.',
    ).then((confirmed) async {
      if (confirmed == true) {
        final success = await controller.deleteCab(cab.id ?? 0);
        if (!mounted) return;
        if (!success) {
          SnackBarService.showErrorSnackbar(
            controller.errorMessage ?? 'Failed to delete cab.',
          );
        } else {
          SnackBarService.showsSuccessSnackbar('Cab deleted successfully!', '');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: 'Cabs',
      quietBrandAppBar: true,
      titleWidget: const CtsBrandLogo(height: 32),
      child: Consumer<CabProvider>(
        builder: (context, cc, child) {
          if (cc.state == ViewState.loading && cc.cabs.isEmpty) {
            return const CatalogListSkeleton(title: 'Cabs', itemHeight: 110);
          }

          if (cc.state == ViewState.error) {
            return StatusMessage.error(
              title: cc.errorMessage ?? 'Failed to load cabs',
              message: 'Please check your connection and try again.',
              onRetry: () => cc.fetchCabs(),
            );
          }

          final filteredCabs = _getFilteredAndSortedCabs(cc.cabs);

          if (cc.cabs.isEmpty) {
            return StatusMessage.empty(
              icon: Icons.directions_car_outlined,
              title: 'No cabs found',
              message: 'Get started by creating your first cab.',
              actionLabel: 'Create Cab',
              onAction: _openAddCab,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: CatalogPageTitle(title: 'Cabs'),
              ),
              AdminSearchSortRow<CabSortOption>(
                hintText: 'Search by registration, capacity, or route...',
                onSearchChanged: _onSearchChanged,
                sortOptions: _getSortOptions(),
                selectedSort: _selectedSortOption,
                onSortChanged: _onSortChanged,
                sortTooltip: 'Sort cabs',
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: CatalogYellowAddButton(
                  label: 'Add Cab',
                  onPressed: _openAddCab,
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => cc.fetchCabs(),
                  child: filteredCabs.isEmpty && _searchQuery.isNotEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            StatusMessage(
                              icon: Icons.search_off,
                              title: 'No cabs match your search',
                            ),
                          ],
                        )
                      : CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            _CabList(
                              cabs: filteredCabs,
                              onEdit: _showEditDialog,
                              onDelete: _showDeleteDialog,
                            ),
                            const SliverToBoxAdapter(
                              child: CatalogFooterHint(
                                'Swipe to edit or delete',
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

class _CabList extends StatelessWidget {
  const _CabList({
    required this.cabs,
    required this.onEdit,
    required this.onDelete,
  });

  final List<CabModel> cabs;
  final void Function(CabModel) onEdit;
  final void Function(CabModel) onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      sliver: SliverList.separated(
        itemCount: cabs.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final cab = cabs[index];
          return Slidable(
            key: ValueKey(cab.id),
            startActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.25,
              dismissible: DismissiblePane(onDismissed: () => onDelete(cab)),
              children: [
                SlidableAction(
                  onPressed: (_) => onDelete(cab),
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
                  onPressed: (_) => onEdit(cab),
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
            child: CatalogCard(
              title: cab.regNumber ?? 'N/A',
              onLongPress: () => ListItemActionsSheet.show(
                context,
                onEdit: () => onEdit(cab),
                onDelete: () => onDelete(cab),
              ),
              children: [
                CatalogField(
                  label: 'Route',
                  value: cab.routeId?.routeName ?? 'N/A',
                ),
                CatalogField(
                  label: 'Capacity',
                  value: '${cab.capacity} Seats',
                ),
                if (cab.km != null && cab.km! > 0)
                  CatalogField(
                    label: 'Distance',
                    value: '${cab.km} km',
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
