import 'package:cts/appManager/colors.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:cts/appManager/snackbar_service.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/drivers/providers/driver_controller.dart';
import 'package:cts/features/drivers/providers/driver_form_provider.dart';
import 'package:cts/features/drivers/models/driver_model.dart';
import 'package:cts/features/drivers/utils/driver_sort_options.dart';
import 'package:cts/utils/sort_utils.dart';
import 'package:cts/widgets/admin_search_sort_row.dart';
import 'package:cts/widgets/confirmation_dialog.dart';
import 'package:cts/widgets/dashboard_shell.dart';
import 'package:cts/widgets/modern_list_card.dart';
import 'package:cts/widgets/skeleton_list.dart';
import 'package:cts/widgets/sort_dropdown_widget.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class DriverScreen extends StatefulWidget {
  const DriverScreen({super.key});

  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  String _searchQuery = '';
  DriverSortOption _selectedSortOption = DriverSortOption.nameAZ;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverProvider>().fetchDrivers();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  void _onSortChanged(DriverSortOption option) {
    setState(() {
      _selectedSortOption = option;
    });
  }

  List<DriverModel> _getFilteredAndSortedDrivers(List<DriverModel> allDrivers) {
    // First filter by search query
    List<DriverModel> filtered = _searchQuery.isEmpty
        ? allDrivers
        : allDrivers.where((driver) {
            final name = (driver.userId?.username ?? '').toLowerCase();
            final mobile = (driver.userId?.mobileNumber ?? '').toLowerCase();
            final address = (driver.userId?.address ?? '').toLowerCase();
            final batchName = (driver.batchId?.batchName ?? '').toLowerCase();
            final cabNumber = (driver.cabId?.regNumber ?? '').toLowerCase();
            return name.contains(_searchQuery) ||
                mobile.contains(_searchQuery) ||
                address.contains(_searchQuery) ||
                batchName.contains(_searchQuery) ||
                cabNumber.contains(_searchQuery);
          }).toList();

    // Then sort according to selected sort option
    return sortDriverList(filtered, _selectedSortOption);
  }

  List<SortOption<DriverSortOption>> _getSortOptions() {
    return [
      SortOption(
        label: 'Driver Name',
        subLabel: 'A-Z',
        value: DriverSortOption.nameAZ,
        icon: Icons.person,
      ),
      SortOption(
        label: 'Driver Name',
        subLabel: 'Z-A',
        value: DriverSortOption.nameZA,
        icon: Icons.person,
      ),
      SortOption(
        label: 'Mobile',
        subLabel: 'A-Z',
        value: DriverSortOption.mobileAZ,
        icon: Icons.phone,
      ),
      SortOption(
        label: 'Mobile',
        subLabel: 'Z-A',
        value: DriverSortOption.mobileZA,
        icon: Icons.phone,
      ),
      SortOption(
        label: 'Batch',
        subLabel: 'A-Z',
        value: DriverSortOption.batchAZ,
        icon: Icons.groups,
      ),
      SortOption(
        label: 'Batch',
        subLabel: 'Z-A',
        value: DriverSortOption.batchZA,
        icon: Icons.groups,
      ),
      SortOption(
        label: 'Cab',
        subLabel: 'A-Z',
        value: DriverSortOption.cabRegAZ,
        icon: Icons.directions_car,
      ),
      SortOption(
        label: 'Cab',
        subLabel: 'Z-A',
        value: DriverSortOption.cabRegZA,
        icon: Icons.directions_car,
      ),
    ];
  }

  void _showEditDialog(DriverModel driver) {
    final formProvider = context.read<DriverFormProvider>();
    formProvider.forUpdate = true;
    formProvider.updateId = driver.userId?.id ?? 0;
    formProvider.driverNameCtrl.text = driver.userId?.username ?? "";
    formProvider.driverMobileCtrl.text = driver.userId?.mobileNumber ?? "";
    formProvider.driverAddressCtrl.text = driver.userId?.address ?? "";
    formProvider.selectedBatchId = driver.batchId?.id;
    formProvider.selectedCabId = driver.cabId?.id;
    context.push(RouteName.driverForm);
  }

  void _showDeleteDialog(DriverModel driver) {
    final controller = context.read<DriverProvider>();
    ConfirmationDialog.showDeleteConfirmation(
      context,
      itemName: 'Driver',
      customMessage:
          'Are you sure you want to delete "${driver.userId?.username ?? 'this driver'}"? This action cannot be undone.',
    ).then((confirmed) async {
      if (confirmed == true) {
        final success = await controller.deleteDriver(driver.userId?.id ?? 0);
        if (!mounted) return;
        if (!success) {
          SnackBarService.showErrorSnackbar(
            controller.errorMessage ?? 'Failed to delete driver.',
          );
        } else {
          SnackBarService.showsSuccessSnackbar(
            'Driver deleted successfully!',
            '',
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: 'Drivers',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Add Driver',
          iconSize: 36,
          onPressed: () {
            context.read<DriverFormProvider>().clearAll();
            context.push(RouteName.driverForm);
          },
        ),
      ],
      child: Consumer<DriverProvider>(
        builder: (context, dc, child) {
          // Show skeleton loader on initial load
          if (dc.state == ViewState.loading && dc.drivers.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'All Drivers',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage Drivers and keep them updated on the Batch & Cabs.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),
                const DriverSkeletonList(itemCount: 8),
              ],
            );
          }

          if (dc.state == ViewState.error) {
            return StatusMessage.error(
              title: dc.errorMessage ?? 'Failed to load drivers',
              message: 'Please check your connection and try again.',
              onRetry: () => dc.fetchDrivers(),
            );
          }

          // Get filtered and sorted drivers
          final filteredDrivers = _getFilteredAndSortedDrivers(dc.drivers);

          if (dc.drivers.isEmpty) {
            return StatusMessage.empty(
              icon: Icons.person_off_outlined,
              title: 'No drivers found',
              message: 'Get started by creating your first driver.',
              actionLabel: 'Create Driver',
              onAction: () {
                context.read<DriverFormProvider>().clearAll();
                context.push(RouteName.driverForm);
              },
            );
          }

          return Column(
            children: [
              AdminSearchSortRow<DriverSortOption>(
                hintText: 'Search by name, mobile, batch, or cab...',
                onSearchChanged: _onSearchChanged,
                sortOptions: _getSortOptions(),
                selectedSort: _selectedSortOption,
                onSortChanged: _onSortChanged,
                sortTooltip: 'Sort drivers',
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => dc.fetchDrivers(),
                  child: filteredDrivers.isEmpty && _searchQuery.isNotEmpty
                      ? const StatusMessage(
                          icon: Icons.search_off,
                          title: 'No drivers match your search',
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
                                      'All Drivers',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Manage drivers and keep them updated on batches & cabs.',
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
                            _DriverList(
                              drivers: filteredDrivers,
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

class _DriverList extends StatelessWidget {
  const _DriverList({
    required this.drivers,
    required this.onEdit,
    required this.onDelete,
  });

  final List<DriverModel> drivers;
  final void Function(DriverModel) onEdit;
  final void Function(DriverModel) onDelete;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      sliver: SliverList.separated(
        itemCount: drivers.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final driver = drivers[index];
          return Slidable(
          key: ValueKey(driver.userId?.id ?? index),
          startActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.25,
            dismissible: DismissiblePane(onDismissed: () => onDelete(driver)),
            children: [
              SlidableAction(
                onPressed: (_) => onDelete(driver),
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
                onPressed: (_) => onEdit(driver),
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
            title: driver.userId?.username ?? 'Untitled driver',
            icon: Icons.person_outline_rounded,
            iconColor: AppColors.acYellowWarm,
            trailing: PopupMenuButton<String>(
              tooltip: 'More options',
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit(driver);
                } else if (value == 'delete') {
                  onDelete(driver);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
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
                PopupMenuItem(
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
                icon: Icons.directions_car_rounded,
                label: 'Cab:',
                value: driver.cabId?.regNumber ?? 'N/A',
                iconColor: AppColors.acYellowWarm,
              ),
              InfoRow(
                icon: Icons.directions_bus_rounded,
                label: 'Batch:',
                value: driver.batchId?.batchName ?? 'N/A',
                iconColor: AppColors.acYellowWarm,
              ),
              if (driver.userId?.mobileNumber != null &&
                  driver.userId!.mobileNumber!.isNotEmpty)
                InfoRow(
                  icon: Icons.phone_rounded,
                  label: 'Mobile:',
                  value: driver.userId!.mobileNumber!,
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
