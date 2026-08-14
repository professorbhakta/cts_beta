import 'package:cts/appManager/app_class.dart';
import 'package:cts/appManager/colors.dart';
import 'package:cts/appManager/snackbar_service.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/batches/providers/batch_controller.dart';
import 'package:cts/features/cabs/providers/cab_controller.dart';
import 'package:cts/features/commuters/providers/commuter_controller.dart';
import 'package:cts/features/commuters/providers/commuter_form_provider.dart';
import 'package:cts/features/pops/providers/pop_controller.dart';
import 'package:cts/features/batches/models/batch_model.dart';
import 'package:cts/models/cab_model.dart';
import 'package:cts/models/pop_model.dart';
import 'package:cts/utils/validators.dart';
import 'package:cts/widgets/admin_form_header.dart';
import 'package:cts/widgets/common_button.dart';
import 'package:cts/widgets/dashboard_shell.dart';
import 'package:cts/widgets/searchable_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class CommuterForm extends StatefulWidget {
  const CommuterForm({super.key});

  @override
  State<CommuterForm> createState() => _CommuterFormState();
}

class _CommuterFormState extends State<CommuterForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  late final CommuterController _dataProvider;

  @override
  void initState() {
    super.initState();
    _dataProvider = context.read<CommuterController>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      context.read<BatchProvider>().fetchBatches();
      context.read<CabProvider>().fetchCabs();
      context.read<PopProvider>().fetchPops();
      final formProvider = context.read<CommuterFormProvider>();
      if (formProvider.forUpdate && formProvider.updateId != 0) {
        final user = await _dataProvider.fetchUser(formProvider.updateId);
        if (!mounted || user == null) return;
        formProvider.applyFetchedUser(user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final formProvider = context.watch<CommuterFormProvider>();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, bool? result) {
        if (didPop) {
          _dataProvider.refreshCurrentList();
        }
      },
      child: DashboardShell(
        title: formProvider.forUpdate ? 'Edit Commuter' : 'Create Commuter',
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
                    icon: Icons.person_rounded,
                    title: formProvider.forUpdate
                        ? 'Edit Commuter'
                        : 'Create New Commuter',
                  ),
                  const SizedBox(height: 24),
                  // Full Name Field
                  _buildTextField(
                    formProvider.commName,
                    "Full Name",
                    icon: Icons.person_outline_rounded,
                    customValidator: (value) => Validators.name(value),
                  ),
                  const SizedBox(height: 16),
                  // Mobile Number Field
                  _buildTextField(
                    formProvider.commMob,
                    "Mobile Number",
                    icon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                    customValidator: (value) => Validators.mobileNumber(value),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    formProvider.commEmail,
                    "Email",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    customValidator: (value) => Validators.email(value),
                  ),
                  if (!formProvider.forUpdate) ...[
                    const SizedBox(height: 16),
                    // Password Field
                    _buildTextField(
                      formProvider.commPass,
                      "Password",
                      icon: Icons.lock_outline_rounded,
                      isObscure: true,
                      customValidator: (value) => Validators.password(value),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildTextField(
                    formProvider.commAddr,
                    "Address",
                    icon: Icons.location_on_outlined,
                    hintText: 'Optional — defaults to email',
                    customValidator: (value) =>
                        Validators.address(value, isRequired: false),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(
                        CommuterFormProvider.addressMaxLength,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // College Name Field
                  _buildTextField(
                    formProvider.commClg,
                    "College Name",
                    icon: Icons.school_outlined,
                    customValidator: (value) => Validators.collegeName(value),
                  ),
                  const SizedBox(height: 16),
                  // Batch Dropdown
                  _buildBatchDropdown(),
                  const SizedBox(height: 16),
                  // Cab Dropdown
                  _buildCabDropdown(),
                  const SizedBox(height: 16),
                  // Pick-Up Point Dropdown
                  _buildPopDropdown(),
                  const SizedBox(height: 32),
                  // Submit Button
                  CommonPrimaryButton(
                    label: formProvider.forUpdate
                        ? "Update Commuter"
                        : "Create Commuter",
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
                              final email = formProvider.commEmail.text.trim();
                              final address = formProvider.addressForPayload();
                              if (formProvider.forUpdate) {
                                final userData = <String, dynamic>{
                                  "username": formProvider.commName.text
                                      .trim()
                                      .toUpperCase(),
                                  "mobileNumber": formProvider.commMob.text
                                      .trim(),
                                  "email": email,
                                  'userType': "COMMUTER",
                                  'address': ?address,
                                };
                                final commuterData = {
                                  "collegeName": formProvider.commClg.text
                                      .trim()
                                      .toUpperCase(),
                                  "popId": formProvider.selectedPopId,
                                  "batchId": formProvider.selectedBatchId,
                                  "cabId": formProvider.selectedCabId,
                                  "adminCode": AppManager.instance.getString(
                                    ManagerKey.adminCode,
                                  ),
                                };

                                success = await _dataProvider.updateCommuter(
                                  formProvider.updateId,
                                  userData,
                                  commuterData,
                                );
                              } else {
                                final data = {
                                  "user": {
                                    "username": formProvider.commName.text
                                        .trim()
                                        .toUpperCase(),
                                    "password": formProvider.commPass.text
                                        .trim(),
                                    "mobileNumber": formProvider.commMob.text
                                        .trim(),
                                    "email": email,
                                    'userType': "COMMUTER",
                                    'address': address ?? email,
                                  },
                                  "user_data": {
                                    "collegeName": formProvider.commClg.text
                                        .trim()
                                        .toUpperCase(),
                                    "popId": formProvider.selectedPopId,
                                    "batchId": formProvider.selectedBatchId,
                                    "cabId": formProvider.selectedCabId,
                                    "adminCode": AppManager.instance.getString(
                                      ManagerKey.adminCode,
                                    ),
                                  },
                                };
                                success = await _dataProvider.createCommuter(
                                  data,
                                );
                              }

                              if (!mounted) return;

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

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    bool isObscure = false,
    String? hintText,
    String? Function(String?)? customValidator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText ?? 'Enter $label',
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
          borderSide: BorderSide(color: AppColors.acYellowWarm, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.acRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.acRed, width: 2),
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
      validator:
          customValidator ?? (value) => Validators.required(value, label),
    );
  }

  Widget _buildBatchDropdown() {
    final formProvider = context.read<CommuterFormProvider>();
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
              border: Border.all(color: AppColors.acRed, width: 1.5),
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
            return (batch.batchName ?? '').toLowerCase().contains(
              filter.toLowerCase(),
            );
          },
          compareFn: (item1, item2) => item1 == item2,
          onChanged: (int? newValue) {
            setState(() {
              formProvider.selectedBatchId = newValue;
            });
          },
          validator: (value) => value == null ? 'Please select a Batch' : null,
          isLoading: batchProvider.state == ViewState.loading,
          errorMessage: batchProvider.state == ViewState.error
              ? batchProvider.errorMessage
              : null,
        );
      },
    );
  }

  Widget _buildCabDropdown() {
    final formProvider = context.read<CommuterFormProvider>();
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
              border: Border.all(color: AppColors.acRed, width: 1.5),
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
            return (cab.regNumber ?? '').toLowerCase().contains(
              filter.toLowerCase(),
            );
          },
          compareFn: (item1, item2) => item1 == item2,
          onChanged: (int? newValue) {
            setState(() {
              formProvider.selectedCabId = newValue;
            });
          },
          validator: (value) => value == null ? 'Please select a Cab' : null,
          isLoading: cabProvider.state == ViewState.loading,
          errorMessage: cabProvider.state == ViewState.error
              ? cabProvider.errorMessage
              : null,
        );
      },
    );
  }

  Widget _buildPopDropdown() {
    final formProvider = context.read<CommuterFormProvider>();
    return Consumer<PopProvider>(
      builder: (context, popProvider, child) {
        if (popProvider.state == ViewState.loading) {
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

        if (popProvider.state == ViewState.error) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.acRed, width: 1.5),
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Text(
              'Error loading pick-up points: ${popProvider.errorMessage}',
              style: TextStyle(color: AppColors.acRed),
            ),
          );
        }

        return SearchableDropdown<int>(
          label: "Pick-Up Point",
          hintText: 'Select a pick-up point',
          icon: Icons.location_on_rounded,
          items: popProvider.pops.map((pop) => pop.id!).toList(),
          value: formProvider.selectedPopId,
          itemAsString: (id) {
            final pop = popProvider.pops.firstWhere(
              (p) => p.id == id,
              orElse: () =>
                  PickUpPointModel(id: id, pickUpPointName: 'Unknown'),
            );
            return pop.pickUpPointName ?? 'Unnamed Pick-Up Point';
          },
          filterFn: (popId, filter) {
            final pop = popProvider.pops.firstWhere(
              (p) => p.id == popId,
              orElse: () => PickUpPointModel(id: popId, pickUpPointName: ''),
            );
            return (pop.pickUpPointName ?? '').toLowerCase().contains(
              filter.toLowerCase(),
            );
          },
          compareFn: (item1, item2) => item1 == item2,
          onChanged: (int? newValue) {
            setState(() {
              formProvider.selectedPopId = newValue;
            });
          },
          validator: (value) => value == null ? 'Please select a POP' : null,
          isLoading: popProvider.state == ViewState.loading,
          errorMessage: popProvider.state == ViewState.error
              ? popProvider.errorMessage
              : null,
        );
      },
    );
  }
}
