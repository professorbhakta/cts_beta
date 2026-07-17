import 'package:cts/appManager/colors.dart';
import 'package:cts/appManager/snackbar_service.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/cabs/presentation/providers/cab_controller.dart';
import 'package:cts/features/cabs/presentation/providers/cab_form_provider.dart';
import 'package:cts/features/routes/presentation/providers/route_controller.dart';
import 'package:cts/models/route_model.dart';
import 'package:cts/utils/validators.dart';
import 'package:cts/shared/widgets/admin_form_header.dart';
import 'package:cts/shared/widgets/common_button.dart';
import 'package:cts/shared/widgets/dashboard_shell.dart';
import 'package:cts/shared/widgets/searchable_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class CabForm extends StatefulWidget {
  const CabForm({super.key});

  @override
  State<CabForm> createState() => _CabFormState();
}

class _CabFormState extends State<CabForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  late final CabProvider _dataProvider;

  @override
  void initState() {
    super.initState();
    _dataProvider = context.read<CabProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RouteController>().fetchRoutes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final formProvider = context.watch<CabFormProvider>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, bool? result) {
        if (didPop) {
          _dataProvider.fetchCabs();
        }
      },
      child: DashboardShell(
        title: formProvider.forUpdate ? 'Edit Cab' : 'Create Cab',
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
                    icon: Icons.directions_car_rounded,
                    title: formProvider.forUpdate
                        ? 'Edit Cab'
                        : 'Create New Cab',
                  ),
                  const SizedBox(height: 24),
                  // Registration Number Field
                  TextFormField(
                    controller: formProvider.regNumberCtrl,
                    decoration: InputDecoration(
                      labelText: 'Registration Number',
                      hintText: 'Enter registration (e.g., GJ00XX0000)',
                      prefixIcon: const Icon(Icons.confirmation_number_rounded),
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
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) => Validators.registrationNumber(value),
                  ),
                  const SizedBox(height: 16),
                  // Capacity Field
                  TextFormField(
                    controller: formProvider.capacityCtrl,
                    decoration: InputDecoration(
                      labelText: 'Capacity',
                      hintText: 'Enter seating capacity',
                      prefixIcon: const Icon(Icons.people_rounded),
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
                    validator: (value) => Validators.capacity(value),
                  ),
                  const SizedBox(height: 16),
                  // KM Field
                  TextFormField(
                    controller: formProvider.kmCtrl,
                    decoration: InputDecoration(
                      labelText: 'Distance (KM)',
                      hintText: 'Enter distance in kilometers',
                      prefixIcon: const Icon(Icons.straighten_rounded),
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
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    style: theme.textTheme.bodyLarge,
                    validator: (value) => Validators.distance(value),
                  ),
                  const SizedBox(height: 16),
                  // Route Dropdown
                  _buildRouteDropdown(),
                  const SizedBox(height: 32),
                  // Submit Button
                  CommonPrimaryButton(
                    label: formProvider.forUpdate
                        ? 'Update Cab'
                        : 'Create Cab',
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
                                "regNumber": formProvider.regNumberCtrl.text
                                    .toUpperCase()
                                    .trim(),
                                "capacity": formProvider.capacityCtrl.text.trim(),
                                "km": formProvider.kmCtrl.text.trim(),
                                "routeId": formProvider.selectedRouteId,
                              };

                              bool success = false;
                              if (formProvider.forUpdate) {
                                success = await _dataProvider.updateCab(
                                  formProvider.updateId,
                                  data,
                                );
                              } else {
                                success = await _dataProvider.createCab(data);
                              }

                              if (!mounted) {
                                setState(() {
                                  _isSubmitting = false;
                                });
                                return;
                              }

                              setState(() {
                                _isSubmitting = false;
                              });

                              if (success) {
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
        final formProvider = context.read<CabFormProvider>();

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

