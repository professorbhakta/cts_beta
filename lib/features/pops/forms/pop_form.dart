import 'package:cts/appManager/colors.dart';
import 'package:cts/appManager/snackbar_service.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/pops/providers/pop_controller.dart';
import 'package:cts/features/pops/providers/pop_form_provider.dart';
import 'package:cts/features/routes/providers/route_controller.dart';
import 'package:cts/models/route_model.dart';
import 'package:cts/utils/validators.dart';
import 'package:cts/widgets/admin_form_header.dart';
import 'package:cts/widgets/common_button.dart';
import 'package:cts/widgets/dashboard_shell.dart';
import 'package:cts/widgets/searchable_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class PopForm extends StatefulWidget {
  const PopForm({super.key});

  @override
  State<PopForm> createState() => _PopFormState();
}

class _PopFormState extends State<PopForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  late final PopProvider _dataProvider;

  @override
  void initState() {
    super.initState();
    _dataProvider = context.read<PopProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RouteController>().fetchRoutes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final formProvider = context.watch<PopFormProvider>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, bool? result) {
        if (didPop) {
          _dataProvider.fetchPops();
        }
      },
      child: DashboardShell(
        title: formProvider.forUpdate ? 'Edit Pick-Up Point' : 'Create Pick-Up Point',
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AdminFormHeader(
                    icon: Icons.location_on_rounded,
                    title: formProvider.forUpdate
                        ? 'Edit Pick-Up Point'
                        : 'Create New Pick-Up Point',
                  ),
                  const SizedBox(height: 24),

                  // Pick-Up Point Name Field
                  TextFormField(
                    controller: formProvider.nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Pick-Up Point Name',
                      hintText: 'Enter pick-up point name',
                      prefixIcon: const Icon(Icons.location_on_rounded),
                      prefixIconColor: AppColors.acYellowWarm,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.acYellowWarm.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.acYellowWarm.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.acYellowWarm,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.acRed,
                          width: 1.5,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.acRed,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: scheme.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    style: theme.textTheme.bodyLarge,
                    validator: (value) => Validators.pickupPointName(value),
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 16),

                  // Stop Number Field
                  TextFormField(
                    controller: formProvider.inLine,
                    decoration: InputDecoration(
                      labelText: 'Stop Number (in line)',
                      hintText: 'Enter stop number',
                      prefixIcon: const Icon(Icons.numbers_rounded),
                      prefixIconColor: AppColors.acYellowWarm,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.acYellowWarm.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.acYellowWarm.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.acYellowWarm,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.acRed,
                          width: 1.5,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.acRed,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: scheme.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: theme.textTheme.bodyLarge,
                    validator: (value) => Validators.inLineNumber(value),
                  ),
                  const SizedBox(height: 16),

                  // Route Dropdown
                  _buildRouteDropdown(),
                  const SizedBox(height: 32),

                  // Submit Button
                  CommonPrimaryButton(
                    label: formProvider.forUpdate
                        ? 'Update Pick-Up Point'
                        : 'Create Pick-Up Point',
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    borderRadius: BorderRadius.circular(12),
                    borderColor: AppColors.acYellowWarm,
                    fontSize: 16,
                    isLoading: _isSubmitting,
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                                final navigator = Navigator.of(context);
                                setState(() {
                                  _isSubmitting = true;
                                });

                              final data = {
                                "pickUpPointName":
                                    formProvider.nameCtrl.text.toUpperCase().trim(),
                                "lat": "0.0",
                                "longitude": "1.1",
                                "inLine": int.tryParse(formProvider.inLine.text) ?? 0,
                                "routeId": formProvider.selectedRouteId,
                              };

                              bool success = false;
                              if (formProvider.forUpdate) {
                                success = await _dataProvider.updatePop(
                                  formProvider.updateId,
                                  data,
                                );
                              } else {
                                success = await _dataProvider.createPop(data);
                              }

                              if (!mounted) return;

                              setState(() {
                                _isSubmitting = false;
                              });

                              if (success) {
                                SnackBarService.showsSuccessSnackbar(
                                  formProvider.forUpdate
                                      ? 'Pick-up point updated successfully!'
                                      : 'Pick-up point created successfully!',
                                  '',
                                );
                                navigator.pop();
                              } else {
                                final errorMessage =
                                    _dataProvider.errorMessage ??
                                    'An unknown error occurred.';
                                SnackBarService.showErrorSnackbar(errorMessage);
                              }
                            }
                          },
                    backgroundColor: AppColors.acYellowWarm,
                    textColor: AppColors.acBlack,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRouteDropdown() {
    return Consumer<RouteController>(
      builder: (context, routeProvider, child) {
        final formProvider = context.read<PopFormProvider>();

        if (routeProvider.state == ViewState.loading) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.acYellowWarm.withValues(alpha: 0.3),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (routeProvider.state == ViewState.error) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.acRed,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Text(
              'Error loading routes: ${routeProvider.errorMessage}',
              style: TextStyle(color: AppColors.acRed),
            ),
          );
        }

        RouteModel? selectedRoute;
        if (formProvider.selectedRouteId != null) {
          try {
            selectedRoute = routeProvider.routes.firstWhere(
              (route) => route.id == formProvider.selectedRouteId,
            );
          } catch (e) {
            // selectedRoute remains null
          }
        }

        return SearchableDropdown<RouteModel>(
          label: 'Route',
          hintText: 'Select a route',
          icon: Icons.route_rounded,
          items: routeProvider.routes,
          value: selectedRoute,
          itemAsString: (route) => route.routeName ?? 'Unnamed Route',
          filterFn: (route, filter) =>
              (route.routeName ?? '')
                  .toLowerCase()
                  .contains(filter.toLowerCase()),
          compareFn: (route1, route2) => route1.id == route2.id,
          onChanged: (RouteModel? newValue) {
            formProvider.selectedRouteId = newValue?.id;
            setState(() {});
          },
          validator: (value) =>
              value == null ? 'Please select a route' : null,
          isLoading: routeProvider.state == ViewState.loading,
          errorMessage: routeProvider.state == ViewState.error
              ? routeProvider.errorMessage
              : null,
        );
      },
    );
  }
}

