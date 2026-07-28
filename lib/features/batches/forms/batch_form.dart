import 'package:cts/appManager/colors.dart';
import 'package:cts/appManager/functions_and_tools.dart';
import 'package:cts/appManager/snackbar_service.dart';
import 'package:cts/features/batches/providers/batch_controller.dart';
import 'package:cts/features/batches/providers/batch_form_provider.dart';
import 'package:cts/widgets/admin_form_header.dart';
import 'package:cts/widgets/common_button.dart';
import 'package:cts/widgets/dashboard_shell.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BatchForm extends StatefulWidget {
  const BatchForm({super.key});

  @override
  State<BatchForm> createState() => _BatchFormState();
}

class _BatchFormState extends State<BatchForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final BatchProvider _batchProvider;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _batchProvider = context.read<BatchProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final formProvider = context.read<BatchFormProvider>();
      if (!formProvider.forUpdate) {
        formProvider.clearAll();
      }
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final formProvider = context.read<BatchFormProvider>();
    final initialDate = isStart
        ? (formProvider.startDate ?? DateTime.now())
        : (formProvider.endDate ?? DateTime.now());

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      if (isStart) {
        formProvider.setStartDate(picked);
      } else {
        formProvider.setEndDate(picked);
      }
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final formProvider = context.read<BatchFormProvider>();
    final initialTime = isStart
        ? (formProvider.startTime ?? TimeOfDay.now())
        : (formProvider.returnTime ?? TimeOfDay.now());

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      if (isStart) {
        formProvider.setStartTime(picked);
      } else {
        formProvider.setReturnTime(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _batchProvider.fetchBatches();
        }
      },
      child: Consumer<BatchFormProvider>(
        builder: (context, formProvider, child) {
          return DashboardShell(
            title: formProvider.forUpdate ? 'Edit Batch' : 'Create Batch',
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
                        icon: Icons.event_rounded,
                        title: formProvider.forUpdate
                            ? 'Edit Batch'
                            : 'Create New Batch',
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(formProvider.nameCtrl, "Batch Name"),
                      const SizedBox(height: 16),
                      _buildDateTimePicker(
                        "Start Date",
                        formProvider.startDate == null
                            ? 'Select Date'
                            : dateFormat(formProvider.startDate.toString()),
                        () => _selectDate(context, true),
                      ),
                      const SizedBox(height: 16),
                      _buildDateTimePicker(
                        "End Date",
                        formProvider.endDate == null
                            ? 'Select Date'
                            : dateFormat(formProvider.endDate.toString()),
                        () => _selectDate(context, false),
                      ),
                      const SizedBox(height: 16),
                      _buildDateTimePicker(
                        "Start Time",
                        formProvider.startTime?.format(context) ??
                            'Select Time',
                        () => _selectTime(context, true),
                      ),
                      const SizedBox(height: 16),
                      _buildDateTimePicker(
                        "Return Time",
                        formProvider.returnTime?.format(context) ??
                            'Select Time',
                        () => _selectTime(context, false),
                      ),
                      const SizedBox(height: 32),
                      CommonPrimaryButton(
                        label: formProvider.forUpdate
                            ? "Update Batch"
                            : "Create Batch",
                        borderRadius: BorderRadius.circular(12),
                        fontSize: 16,
                        borderColor: AppColors.acYellowWarm,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        isLoading: _isSubmitting,
                        onPressed: _isSubmitting
                            ? null
                            : () async {
                                if (!_formKey.currentState!.validate()) return;

                                if (formProvider.startDate == null) {
                                  SnackBarService.showErrorSnackbar(
                                    'Please select a start date.',
                                  );
                                  return;
                                }
                                if (formProvider.endDate == null) {
                                  SnackBarService.showErrorSnackbar(
                                    'Please select an end date.',
                                  );
                                  return;
                                }
                                if (formProvider.startTime == null) {
                                  SnackBarService.showErrorSnackbar(
                                    'Please select a start time.',
                                  );
                                  return;
                                }
                                if (formProvider.returnTime == null) {
                                  SnackBarService.showErrorSnackbar(
                                    'Please select a return time.',
                                  );
                                  return;
                                }

                                final data = {
                                  "batchName": formProvider.nameCtrl.text,
                                  "batchTime":
                                      "${formProvider.startTime?.hour.toString().padLeft(2, '0')}:${formProvider.startTime?.minute.toString().padLeft(2, '0')}",
                                  "end_time":
                                      "${formProvider.returnTime?.hour.toString().padLeft(2, '0')}:${formProvider.returnTime?.minute.toString().padLeft(2, '0')}",
                                  "startDate": formProvider.startDate
                                      ?.toIso8601String()
                                      .substring(0, 10),
                                  "endDate": formProvider.endDate
                                      ?.toIso8601String()
                                      .substring(0, 10),
                                };

                                final navigator = Navigator.of(context);
                                setState(() {
                                  _isSubmitting = true;
                                });

                                bool success = false;
                                if (formProvider.forUpdate) {
                                  success = await _batchProvider.updateBatch(
                                    formProvider.updateId,
                                    data,
                                  );
                                } else {
                                  success = await _batchProvider.createBatch(
                                    data,
                                  );
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
                                      _batchProvider.errorMessage ??
                                      'An unknown error occurred.';
                                  SnackBarService.showErrorSnackbar(
                                    errorMessage,
                                  );
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

  Widget _buildTextField(TextEditingController controller, String label) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Enter $label',
        prefixIcon: const Icon(Icons.text_fields_rounded),
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
      style: theme.textTheme.bodyLarge,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a $label';
        }
        return null;
      },
    );
  }

  Widget _buildDateTimePicker(String title, String value, VoidCallback onTap) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.acYellowWarm.withValues(alpha: 0.3),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
          color: scheme.surface,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  title.contains('Time')
                      ? Icons.access_time_rounded
                      : Icons.calendar_today_rounded,
                  color: AppColors.acYellowWarm,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(title, style: theme.textTheme.bodyLarge),
              ],
            ),
            Row(
              children: [
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: value.contains('Select')
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                        : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  title.contains('Time')
                      ? Icons.access_time_rounded
                      : Icons.calendar_today_rounded,
                  color: AppColors.acYellowWarm,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
