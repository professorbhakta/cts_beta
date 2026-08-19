import 'package:cts/appManager/colors.dart';
import 'package:cts/appManager/snackbar_service.dart';
import 'package:cts/features/routes/providers/route_controller.dart';
import 'package:cts/features/routes/providers/route_form_provider.dart';
import 'package:cts/utils/validators.dart';
import 'package:cts/widgets/admin_form_header.dart';
import 'package:cts/widgets/common_button.dart';
import 'package:cts/widgets/dashboard_shell.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RouteForm extends StatefulWidget {
  const RouteForm({super.key});

  @override
  State<RouteForm> createState() => _RouteFormState();
}

class _RouteFormState extends State<RouteForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Add a member variable to hold the provider safely
  late final RouteController _dataProvider;

  @override
  void initState() {
    super.initState();
    // Get a stable reference to the provider here, before any async gaps.
    _dataProvider = context.read<RouteController>();
  }

  @override
  Widget build(BuildContext context) {
    final formProvider = context.watch<RouteFormProvider>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, bool? result) {
        if (didPop) {
          _dataProvider.fetchRoutes();
        }
      },
      child: DashboardShell(
        title: formProvider.forUpdate ? 'Edit Route' : 'Create Route',
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
                    icon: Icons.route_rounded,
                    title: formProvider.forUpdate
                        ? 'Edit Route'
                        : 'Create New Route',
                  ),
                  const SizedBox(height: 24),

                  // Form Field
                  TextFormField(
                    controller: formProvider.routeNameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Route Name',
                      hintText: 'Enter route name (e.g., Route A, Main Street)',
                      prefixIcon: const Icon(Icons.route_rounded),
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
                    validator: (value) => Validators.routeName(value),
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  CommonPrimaryButton(
                    label: formProvider.forUpdate
                        ? 'Update Route'
                        : 'Create Route',
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
                                "routeName": formProvider.routeNameCtrl.text
                                    .trim(),
                              };

                              bool success = false;
                              if (formProvider.forUpdate) {
                                success = await _dataProvider.updateRoute(
                                  formProvider.updateId,
                                  data,
                                );
                              } else {
                                success = await _dataProvider.createRoute(data);
                              }

                              if (!mounted) return;

                              setState(() {
                                _isSubmitting = false;
                              });

                              if (success) {
                                SnackBarService.showsSuccessSnackbar(
                                  formProvider.forUpdate
                                      ? 'Route updated successfully!'
                                      : 'Route created successfully!',
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
}

