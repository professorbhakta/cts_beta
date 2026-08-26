import 'package:cts/api/api_result.dart';
import 'package:cts/api/client_pack_error_messages.dart';
import 'package:cts/appManager/snackbar_service.dart';
import 'package:cts/features/d2d/helpers/odometer_camera_helper.dart';
import 'package:flutter/material.dart';

/// SnackBar / branch helpers for client-pack odometer + boarding UI.
///
/// Prefer [showFailure] / [showMessage] over inventing new HTTP clients —
/// call sites still use [D2dRepository] only.
class ClientPackFeedback {
  ClientPackFeedback._();

  static String messageForFailure(ApiFailure failure) {
    return ClientPackErrorMessages.messageFor(
      failure.code,
      fallback: failure.message,
    );
  }

  static void showFailure(ApiFailure failure) {
    SnackBarService.showErrorSnackbar(messageForFailure(failure));
  }

  static void showError(String message) {
    SnackBarService.showErrorSnackbar(message);
  }

  static void showSuccess(String message) {
    SnackBarService.showsSuccessSnackbar(message, '');
  }

  static bool shouldRefreshQr(ApiFailure? failure) =>
      ClientPackErrorMessages.shouldRefreshQr(failure?.code);

  static bool needsActiveTrip(ApiFailure? failure) =>
      ClientPackErrorMessages.needsActiveTrip(failure?.code);

  static bool isAuthFailure(ApiFailure? failure) =>
      ClientPackErrorMessages.isAuthFailure(failure?.code);

  /// Camera helper → user-visible copy (no silent fail).
  static String messageForCameraFailure(OdometerCameraFailure failure) {
    switch (failure) {
      case OdometerCameraFailure.permissionDenied:
        return 'Camera permission is required to photograph the odometer.';
      case OdometerCameraFailure.cancelled:
        return 'Photo capture cancelled.';
      case OdometerCameraFailure.compressFailed:
        return 'Could not process the photo. Please try again.';
    }
  }

  static void showCameraFailure(OdometerCameraFailure failure) {
    showError(messageForCameraFailure(failure));
  }

  /// Optional context SnackBar when [SnackBarService] overlay is unavailable.
  static void showScaffoldError(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      showError(message);
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
