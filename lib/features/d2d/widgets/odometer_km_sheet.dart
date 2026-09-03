import 'package:cts/theme/cts_colors.dart';
import 'dart:io';

import 'package:cts/api/api_result.dart';
import 'package:cts/appManager/colors.dart';
import 'package:cts/features/d2d/helpers/client_pack_feedback.dart';
import 'package:cts/features/d2d/helpers/odometer_camera_helper.dart';
import 'package:cts/features/d2d/models/odometer_models.dart';
import 'package:cts/features/d2d/repositories/d2d_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

enum OdometerSheetMode { start, end }

/// Start/end KM sheet (morning leg for MVP).
///
/// - **KM** required on Confirm.
/// - **Photo** optional (camera only when taken).
/// - **Close** (top): leave without recording — no swipe-to-dismiss on start.
/// - **Skip** (bottom): same as close — skip odometer step for now.
///
/// Returns `true` on successful API submit; `false` if Close/Skip.
class OdometerKmSheet extends StatefulWidget {
  const OdometerKmSheet({
    super.key,
    required this.batchId,
    required this.mode,
    this.leg = OdometerLeg.morning,
    this.cameraHelper,
  });

  final String batchId;
  final OdometerSheetMode mode;
  final OdometerLeg leg;
  final OdometerCameraHelper? cameraHelper;

  static Future<bool?> show(
    BuildContext context, {
    required String batchId,
    required OdometerSheetMode mode,
    OdometerLeg leg = OdometerLeg.morning,
    OdometerCameraHelper? cameraHelper,
  }) {
    // No swipe / barrier dismiss — user must use Close, Skip, or Confirm.
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (sheetContext) {

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            // System back → same as Close (do not trap forever).
            Navigator.of(sheetContext).pop(false);
          },
          child: OdometerKmSheet(
            batchId: batchId,
            mode: mode,
            leg: leg,
            cameraHelper: cameraHelper,
          ),
        );
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
    );
  }

  @override
  State<OdometerKmSheet> createState() => _OdometerKmSheetState();
}

class _OdometerKmSheetState extends State<OdometerKmSheet> {
  final _kmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final OdometerCameraHelper _camera;

  String? _photoPath;
  bool _submitting = false;
  bool _capturing = false;

  static const _invalidKmFailure = ApiFailure(
    type: ApiFailureType.invalidRequest,
    code: 'invalid_km',
  );

  @override
  void initState() {
    super.initState();
    _camera = widget.cameraHelper ?? OdometerCameraHelper();
  }

  @override
  void dispose() {
    _kmController.dispose();
    super.dispose();
  }

  String get _title =>
      widget.mode == OdometerSheetMode.start ? 'Start odometer' : 'End odometer';

  String get _confirmLabel =>
      widget.mode == OdometerSheetMode.start
          ? 'Confirm start KM'
          : 'Confirm end KM';

  void _closeOrSkip() {
    if (_submitting || _capturing) return;
    Navigator.of(context).pop(false);
  }

  Future<void> _takePhoto() async {
    if (_capturing || _submitting) return;
    setState(() => _capturing = true);
    try {
      final result = await _camera.captureCompressedPhoto();
      if (!mounted) return;
      if (!result.isSuccess) {
        ClientPackFeedback.showCameraFailure(
          result.failure ?? OdometerCameraFailure.cancelled,
        );
        return;
      }
      setState(() => _photoPath = result.path);
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final km = int.tryParse(_kmController.text.trim());
    if (km == null || km < 0) {
      ClientPackFeedback.showFailure(_invalidKmFailure);
      return;
    }

    // Photo optional — blank is OK (matches BE + product lock).
    final photo = _photoPath;

    setState(() => _submitting = true);
    try {
      final repo = context.read<D2dRepository>();
      final result = widget.mode == OdometerSheetMode.start
          ? await repo.submitOdometerStart(
              batchId: widget.batchId,
              leg: widget.leg,
              km: km,
              photoPath: photo,
            )
          : await repo.submitOdometerEnd(
              batchId: widget.batchId,
              leg: widget.leg,
              km: km,
              photoPath: photo,
            );

      if (!mounted) return;
      if (result.isFailure) {
        final failure = result.failure!;
        ClientPackFeedback.showFailure(failure);
        if (failure.code == 'already_started' ||
            failure.code == 'already_ended') {
          Navigator.of(context).pop(true);
        }
        return;
      }
      ClientPackFeedback.showSuccess(
        widget.mode == OdometerSheetMode.start
            ? 'Start KM recorded.'
            : 'End KM recorded.',
      );
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final cts = context.cts;

    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 48),
                    Expanded(
                      child: Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: (_submitting || _capturing)
                          ? null
                          : _closeOrSkip,
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: cts.navy,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enter odometer KM (required). Photo is optional.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: cts.navy.withValues(alpha: 0.65),
                            ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _kmController,
                        enabled: !_submitting,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: 'Odometer KM',
                          hintText: 'e.g. 25678',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        validator: (value) {
                          final raw = value?.trim() ?? '';
                          if (raw.isEmpty) return 'KM is required';
                          final n = int.tryParse(raw);
                          if (n == null || n < 0) {
                            return 'Enter a whole number ≥ 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      if (_photoPath != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.file(
                            File(_photoPath!),
                            height: 160,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      OutlinedButton.icon(
                        onPressed:
                            (_submitting || _capturing) ? null : _takePhoto,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: cts.navy,
                          side: BorderSide(
                            color: cts.navy.withValues(alpha: 0.4),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        icon: _capturing
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: cts.navy,
                                ),
                              )
                            : const Icon(Icons.photo_camera_outlined),
                        label: Text(
                          _photoPath == null
                              ? 'Take odometer photo (optional)'
                              : 'Retake photo',
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: _submitting ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.acBlack,
                          foregroundColor: scheme.surface,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: _submitting
                            ? SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: scheme.surface,
                                ),
                              )
                            : Text(_confirmLabel),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: (_submitting || _capturing)
                            ? null
                            : _closeOrSkip,
                        child: const Text('Skip for now'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
