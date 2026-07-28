import 'package:cts/appManager/colors.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:cts/appManager/snackbar_service.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/routes/providers/route_controller.dart';
import 'package:cts/features/routes/providers/route_form_provider.dart';
import 'package:cts/models/route_model.dart';
import 'package:cts/utils/sort_utils.dart';
import 'package:cts/widgets/confirmation_dialog.dart';
import 'package:cts/widgets/dashboard_shell.dart';
import 'package:cts/widgets/modern_list_card.dart';
import 'package:cts/widgets/search_bar_widget.dart';
import 'package:cts/widgets/skeleton_list.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class RouteScreen extends StatefulWidget {
  const RouteScreen({super.key});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RouteController>().fetchRoutes();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  List<RouteModel> _getFilteredRoutes(List<RouteModel> allRoutes) {
    // First filter by search query
    List<RouteModel> filtered = _searchQuery.isEmpty
        ? allRoutes
        : allRoutes.where((route) {
            final name = (route.routeName ?? '').toLowerCase();
            return name.contains(_searchQuery);
          }).toList();

    // Then sort A-Z by route name
    return sortListAZ(
      filtered,
      (route) => route.routeName ?? '',
    );
  }

  // START: Reverted RouteProvider to RouteController
  void _showEditDialog(BuildContext context, RouteController rc, int index) {
    // END: Reverted RouteProvider to RouteController
    final formProvider = context.read<RouteFormProvider>();
    formProvider.routeNameCtrl.text = rc.routes[index].routeName ?? "";
    formProvider.forUpdate = true;
    formProvider.updateId = rc.routes[index].id ?? 0;
    context.push(RouteName.routeForm);
  }

  // START: Reverted RouteProvider to RouteController
  void _showDeleteDialog(BuildContext context, RouteController rc, int index) {
    final route = rc.routes[index];
    ConfirmationDialog.showDeleteConfirmation(
      context,
      itemName: 'Route',
      customMessage: 'Are you sure you want to delete "${route.routeName ?? 'this route'}"? This action cannot be undone.',
    ).then((confirmed) async {
      if (confirmed == true) {
        final success = await rc.deleteRoute(route.id ?? 0);
        if (!mounted) return;
        if (!success) {
          SnackBarService.showErrorSnackbar(
            rc.errorMessage ?? 'Failed to delete route.',
          );
        } else {
          SnackBarService.showsSuccessSnackbar('Route deleted successfully!', '');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: 'Routes',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Add Route',
          iconSize: 36,
          onPressed: () {
            context.read<RouteFormProvider>().clearAll();
            context.push(RouteName.routeForm);
          },
        ),
      ],
      // START: Reverted RouteProvider to RouteController
      child: Consumer<RouteController>(
        // END: Reverted RouteProvider to RouteController
        builder: (context, rc, _) {
          // Show skeleton loader on initial load
          if (rc.state == ViewState.loading && rc.routes.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'All Routes',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage pickup corridors and keep them updated.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                ),
                const SizedBox(height: 16),
                const RouteSkeletonList(itemCount: 8),
              ],
            );
          }

          if (rc.state == ViewState.error) {
            return StatusMessage.error(
              title: rc.errorMessage ?? 'Unable to fetch routes',
              message: 'Please check your connection and try again.',
              onRetry: () => rc.fetchRoutes(),
            );
          }

          // Get filtered routes (computed, no setState)
          final filteredRoutes = _getFilteredRoutes(rc.routes);

          if (rc.routes.isEmpty) {
            return StatusMessage.empty(
              icon: Icons.route_outlined,
              title: 'No routes found',
              message: 'Get started by creating your first route.',
              actionLabel: 'Create Route',
              onAction: () {
                context.read<RouteFormProvider>().clearAll();
                context.push(RouteName.routeForm);
              },
            );
          }

          return Column(
            children: [
              SearchBarWidget(
                hintText: 'Search routes by name...',
                onSearchChanged: _onSearchChanged,
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: rc.fetchRoutes,
                  child: filteredRoutes.isEmpty && _searchQuery.isNotEmpty
                      ? const StatusMessage(
                          icon: Icons.search_off,
                          title: 'No routes match your search',
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
                                      'All Routes',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Manage pickup corridors and keep them updated.',
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
                            _RouteList(
                              routes: filteredRoutes,
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

class _RouteList extends StatelessWidget {
  const _RouteList({
    required this.routes,
    required this.onEdit,
    required this.onDelete,
  });

  final List<RouteModel> routes;
  final void Function(BuildContext, RouteController, int) onEdit;
  final void Function(BuildContext, RouteController, int) onDelete;

  @override
  Widget build(BuildContext context) {
    final routeController = context.read<RouteController>();
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      sliver: SliverList.separated(
        itemCount: routes.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
        final route = routes[index];
        return Slidable(
          key: ValueKey(route.id ?? index),
          startActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.25,
            dismissible: DismissiblePane(
              onDismissed: () => onDelete(context, routeController, index),
            ),
            children: [
              SlidableAction(
                onPressed: (_) => onDelete(context, routeController, index),
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
                onPressed: (_) => onEdit(context, routeController, index),
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
            title: route.routeName ?? 'Untitled route',
            icon: Icons.route_rounded,
            iconColor: AppColors.acYellowWarm,
            trailing: PopupMenuButton<String>(
              tooltip: 'More options',
              onSelected: (value) {
                final routeController = context.read<RouteController>();
                if (value == 'edit') {
                  onEdit(context, routeController, index);
                } else if (value == 'delete') {
                  onDelete(context, routeController, index);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Edit'),
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete_outline, color: AppColors.acRed),
                    title: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      ),
    );
  }
}

