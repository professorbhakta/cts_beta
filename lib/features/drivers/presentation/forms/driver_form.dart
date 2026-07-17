import 'package:cts/appManager/app_class.dart';
import 'package:cts/appManager/colors.dart';
import 'package:cts/appManager/snackbar_service.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/batches/presentation/providers/batch_controller.dart';
import 'package:cts/controllers/cab_controller.dart';
import 'package:cts/features/drivers/presentation/providers/driver_controller.dart';
import 'package:cts/features/drivers/presentation/providers/driver_form_provider.dart';
import 'package:cts/features/batches/domain/models/batch_model.dart';
import 'package:cts/models/cab_model.dart';
import 'package:cts/utils/validators.dart';
import 'package:cts/shared/widgets/admin_form_header.dart';
import 'package:cts/shared/widgets/common_button.dart';
import 'package:cts/shared/widgets/dashboard_shell.dart';
import 'package:cts/shared/widgets/searchable_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class DriverForm extends StatefulWidget {
  const DriverForm({super.key});

  @override
  State<DriverForm> createState() => _DriverFormState();
}

class _DriverFormState extends State<DriverForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final DriverProvider _driverProvider;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _driverProvider = context.read<DriverProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BatchProvider>().fetchBatches();
      context.read<CabProvider>().fetchCabs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, bool? result) {
        if (didPop) {
          _driverProvider.fetchDrivers();
        }
      },
      child: Consumer<DriverFormProvider>(
        builder: (context, formProvider, child) {
          return DashboardShell(
            title: formProvider.forUpdate ? 'Edit Driver' : 'Create Driver',
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
                        icon: Icons.person_outline_rounded,
                        title: formProvider.forUpdate
                            ? 'Edit Driver'
                            : 'Create New Driver',
                      ),
                      const SizedBox(height: 24),
                      // Driver Name Field
                      _buildTextField(
                        formProvider.driverNameCtrl,
                        "Driver Name",
                        icon: Icons.person_outline_rounded,
                        customValidator: (value) =>
                            Validators.name(value, fieldName: "Driver name"),
                      ),
                      const SizedBox(height: 16),
                      // Mobile Number Field
                      _buildTextField(
                        formProvider.driverMobileCtrl,
                        "Mobile Number",
                        icon: Icons.phone_rounded,
                        keyboardType: TextInputType.phone,
                        customValidator: (value) => Validators.mobileNumber(value),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(10),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      if (!formProvider.forUpdate) ...[
                        const SizedBox(height: 16),
                        // Password Field
                        _buildTextField(
                          formProvider.driverPasswordCtrl,
                          "Password",
                          icon: Icons.lock_outline_rounded,
                          isObscure: true,
                          customValidator: (value) => Validators.password(value),
                        ),
                      ],
                      const SizedBox(height: 16),
                      // Address Field
                      _buildTextField(
                        formProvider.driverAddressCtrl,
                        "Address",
                        icon: Icons.location_on_outlined,
                        customValidator: (value) => Validators.address(value),
                      ),
                      const SizedBox(height: 16),
                      // Batch Dropdown
                      _buildBatchDropdown(formProvider),
                      const SizedBox(height: 16),
                      // Cab Dropdown
                      _buildCabDropdown(formProvider),
                      const SizedBox(height: 32),
                      // Submit Button
                      CommonPrimaryButton(
                        label: formProvider.forUpdate
                            ? "Update Driver"
                            : "Create Driver",
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

                                  bool success = false;
                                  if (formProvider.forUpdate) {
                                    final userData = {
                                      "first": formProvider.driverNameCtrl.text
                                          .trim()
                                          .toUpperCase(),
                                      "mobileNumber":
                                          formProvider.driverMobileCtrl.text.trim(),
                                      'address': formProvider.driverAddressCtrl.text
                                          .trim()
                                          .toUpperCase(),
                                      'userType': "DRIVER",
                                      "username": formProvider.driverNameCtrl.text
                                          .trim()
                                          .toUpperCase(),
                                    };

                                    final driverData = {
                                      "cabId": formProvider.selectedCabId,
                                      "adminCode": AppManager.instance.getString(
                                        ManagerKey.adminCode,
                                      ),
                                      "batchId": formProvider.selectedBatchId,
                                    };

                                    success = await _driverProvider.updateDriver(
                                      formProvider.updateId,
                                      userData,
                                      driverData,
                                    );
                                  } else {
                                    final data = {
                                      "user": {
                                        "username": formProvider.driverNameCtrl.text
                                            .trim()
                                            .toUpperCase(),
                                        "password":
                                            formProvider.driverPasswordCtrl.text.trim(),
                                        "first": formProvider.driverNameCtrl.text
                                            .trim()
                                            .toUpperCase(),
                                        "mobileNumber":
                                            formProvider.driverMobileCtrl.text.trim(),
                                        'userType': "DRIVER",
                                      },
                                      "user_data": {
                                        "cabId": formProvider.selectedCabId,
                                        "adminCode": AppManager.instance.getString(
                                          ManagerKey.adminCode,
                                        ),
                                        "batchId": formProvider.selectedBatchId,
                                        'address': formProvider.driverAddressCtrl.text
                                            .trim()
                                            .toUpperCase(),
                                      }
                                    };
                                    success =
                                        await _driverProvider.createDriver(data);
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
                                        _driverProvider.errorMessage ??
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
          );
        },
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    bool isObscure = false,
    String? Function(String?)? customValidator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Enter $label',
        prefixIcon: Icon(icon ?? Icons.edit_outlined),
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
      keyboardType: keyboardType,
      obscureText: isObscure,
      inputFormatters: inputFormatters,
      style: theme.textTheme.bodyLarge,
      validator: customValidator ?? (value) => Validators.required(value, label),
    );
  }

  Widget _buildBatchDropdown(DriverFormProvider formProvider) {
    return Consumer<BatchProvider>(
      builder: (context, batchProvider, child) {
        if (batchProvider.state == ViewState.loading) {
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

        if (batchProvider.state == ViewState.error) {
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
              'Error loading batches: ${batchProvider.errorMessage}',
              style: TextStyle(color: AppColors.acRed),
            ),
          );
        }

        return SearchableDropdown<int>(
          label: "Batch",
          hintText: 'Select a batch',
          icon: Icons.event_rounded,
          items: batchProvider.batches.map((batch) => batch.id!).toList(),
          value: formProvider.selectedBatchId,
          itemAsString: (id) {
            final batch = batchProvider.batches.firstWhere(
              (b) => b.id == id,
              orElse: () => BatchModel(id: id, batchName: 'Unknown'),
            );
            return batch.batchName ?? 'Unnamed Batch';
          },
          filterFn: (batchId, filter) {
            final batch = batchProvider.batches.firstWhere(
              (b) => b.id == batchId,
              orElse: () => BatchModel(id: batchId, batchName: ''),
            );
            return (batch.batchName ?? '')
                .toLowerCase()
                .contains(filter.toLowerCase());
          },
          compareFn: (item1, item2) => item1 == item2,
          onChanged: (int? newValue) {
            formProvider.selectedBatchId = newValue;
            setState(() {});
          },
          validator: (value) => value == null ? 'Please select a batch' : null,
          isLoading: batchProvider.state == ViewState.loading,
          errorMessage: batchProvider.state == ViewState.error
              ? batchProvider.errorMessage
              : null,
        );
      },
    );
  }

  Widget _buildCabDropdown(DriverFormProvider formProvider) {
    return Consumer<CabProvider>(
      builder: (context, cabProvider, child) {
        if (cabProvider.state == ViewState.loading) {
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

        if (cabProvider.state == ViewState.error) {
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
              'Error loading cabs: ${cabProvider.errorMessage}',
              style: TextStyle(color: AppColors.acRed),
            ),
          );
        }

        return SearchableDropdown<int>(
          label: "Cab",
          hintText: 'Select a cab',
          icon: Icons.directions_car_rounded,
          items: cabProvider.cabs.map((cab) => cab.id!).toList(),
          value: formProvider.selectedCabId,
          itemAsString: (id) {
            final cab = cabProvider.cabs.firstWhere(
              (c) => c.id == id,
              orElse: () => CabModel(id: id, regNumber: 'Unknown'),
            );
            return cab.regNumber ?? 'Unnamed Cab';
          },
          filterFn: (cabId, filter) {
            final cab = cabProvider.cabs.firstWhere(
              (c) => c.id == cabId,
              orElse: () => CabModel(id: cabId, regNumber: ''),
            );
            return (cab.regNumber ?? '')
                .toLowerCase()
                .contains(filter.toLowerCase());
          },
          compareFn: (item1, item2) => item1 == item2,
          onChanged: (int? newValue) {
            formProvider.selectedCabId = newValue;
            setState(() {});
          },
          validator: (value) => value == null ? 'Please select a cab' : null,
          isLoading: cabProvider.state == ViewState.loading,
          errorMessage: cabProvider.state == ViewState.error
              ? cabProvider.errorMessage
              : null,
        );
      },
    );
  }
}

