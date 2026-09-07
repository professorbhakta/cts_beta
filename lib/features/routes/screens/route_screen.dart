import 'package:cts/theme/cts_colors.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:cts/appManager/snackbar_service.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/routes/providers/route_controller.dart';
import 'package:cts/features/routes/providers/route_form_provider.dart';
import 'package:cts/models/route_model.dart';
import 'package:cts/utils/sort_utils.dart';
import 'package:cts/widgets/catalog_list_chrome.dart';
import 'package:cts/widgets/confirmation_dialog.dart';
import 'package:cts/widgets/cts_brand_logo.dart';
import 'package:cts/widgets/dashboard_shell.dart';
import 'package:cts/widgets/list_item_actions_sheet.dart';
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
    List<RouteModel> filtered = _searchQuery.isEmpty
        ? allRoutes
        : allRoutes.where((route) {
            final name = (route.routeName ?? '').toLowerCase();
            return name.contains(_searchQuery);
          }).toList();

    return sortListAZ(filtered, (route) => route.routeName ?? '');
  }

  void _openAddRoute() {
    context.read<RouteFormProvider>().clearAll();
    context.push(RouteName.routeForm);
  }

  void _showEditDialog(RouteModel route) {
    final formProvider = context.read<RouteFormProvider>();
    formProvider.routeNameCtrl.text = route.routeName ?? "";
    formProvider.forUpdate = true;
    formProvider.updateId = route.id ?? 0;
    context.push(RouteName.routeForm);
  }

  void _showDeleteDialog(RouteModel route) {
    final rc = context.read<RouteController>();
    ConfirmationDialog.showDeleteConfirmation(
      context,
      itemName: 'Route',
      customMessage:
          'Are you sure you want to delete "${route.routeName ?? 'this route'}"? This action cannot be undone.',
    ).then((confirmed) async {
      if (confirmed == true) {
        final success = await rc.deleteRoute(route.id ?? 0);
        if (!mounted) return;
        if (!success) {
          SnackBarService.showErrorSnackbar(
            rc.errorMessage ?? 'Failed to delete route.',
          );
        } else {
          SnackBarService.showsSuccessSnackbar(
            'Route deleted successfully!',
            '',
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: 'Routes',
      quietBrandAppBar: true,
      titleWidget: const CtsBrandLogo(height: 32),
      child: Consumer<RouteController>(
        builder: (context, rc, _) {
          if (rc.state == ViewState.loading && rc.routes.isEmpty) {
            return const CatalogListSkeleton(title: 'Routes');
          }

          if (rc.state == ViewState.error) {
            return StatusMessage.error(
              title: rc.errorMessage ?? 'Unable to fetch routes',
              message: 'Please check your connection and try again.',
              onRetry: () => rc.fetchRoutes(),
            );
          }

          final filteredRoutes = _getFilteredRoutes(rc.routes);

          if (rc.routes.isEmpty) {
            return StatusMessage.empty(
              icon: Icons.route_outlined,
              title: 'No routes found',
              message: 'Get started by creating your first route.',
              actionLabel: 'Create Route',
              onAction: _openAddRoute,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: CatalogPageTitle(title: 'Routes'),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: CatalogHairlineSearch(
                  hintText: 'Search routes by name...',
                  onSearchChanged: _onSearchChanged,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: CatalogYellowAddButton(
                  label: 'Add Route',
                  onPressed: _openAddRoute,
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: rc.fetchRoutes,
                  child: filteredRoutes.isEmpty && _searchQuery.isNotEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            StatusMessage(
                              icon: Icons.search_off,
                              title: 'No routes match your search',
                            ),
                          ],
                        )
                      : CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            _RouteList(
                              routes: filteredRoutes,
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

class _RouteList extends StatelessWidget {
  const _RouteList({
    required this.routes,
    required this.onEdit,
    required this.onDelete,
  });

  final List<RouteModel> routes;
  final void Function(RouteModel) onEdit;
  final void Function(RouteModel) onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      sliver: SliverList.separated(
        itemCount: routes.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final route = routes[index];
          return Slidable(
            key: ValueKey(route.id ?? index),
            startActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.25,
              dismissible: DismissiblePane(onDismissed: () => onDelete(route)),
              children: [
                SlidableAction(
                  onPressed: (_) => onDelete(route),
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
                  onPressed: (_) => onEdit(route),
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
              title: route.routeName ?? 'Untitled route',
              onLongPress: () => ListItemActionsSheet.show(
                context,
                onEdit: () => onEdit(route),
                onDelete: () => onDelete(route),
              ),
            ),
          );
        },
      ),
    );
  }
}
