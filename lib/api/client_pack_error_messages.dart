/// User-facing copy for client-pack (`/d2d/odometer/*`, `/d2d/boarding_*`) error codes.
///
/// Prefer [messageFor] in UI/SnackBars. Unknown codes fall back to [fallback]
/// or a generic string — never crash.
class ClientPackErrorMessages {
  ClientPackErrorMessages._();

  static String messageFor(String? code, {String? fallback}) {
    if (code == null || code.isEmpty) {
      return fallback?.trim().isNotEmpty == true
          ? fallback!.trim()
          : 'Something went wrong. Please try again.';
    }
    return _messages[code] ??
        (fallback?.trim().isNotEmpty == true
            ? fallback!.trim()
            : 'Something went wrong. Please try again.');
  }

  /// Whether Flutter should prompt re-login / session clear.
  static bool isAuthFailure(String? code) =>
      code == 'unauthorized' || code == 'forbidden';

  /// Driver should refresh QR (token expired or invalid).
  static bool shouldRefreshQr(String? code) =>
      code == 'expired_token' || code == 'invalid_token';

  /// Trip must be (re)started / live WS connected.
  static bool needsActiveTrip(String? code) =>
      code == 'trip_not_active' ||
      code == 'no_live_state' ||
      code == 'conflict' ||
      code == 'aborted';

  static const Map<String, String> _messages = {
    // Auth
    'unauthorized': 'Please sign in again to continue.',
    'forbidden': "You don't have permission for this action.",
    // Odometer
    'batch_id_required': 'Batch is required.',
    'km_required': 'Please enter the odometer KM.',
    'invalid_km': 'KM must be a whole number (0 or greater).',
    'invalid_leg': 'Invalid trip leg. Use morning or return.',
    'invalid_date': 'Invalid date. Use YYYY-MM-DD.',
    'already_started': 'Start KM was already recorded for this leg.',
    'already_ended': 'End KM was already recorded for this leg.',
    'start_required': 'Record start KM before end KM.',
    'km_below_start': 'End KM must be greater than or equal to start KM.',
    'km_below_morning_end':
        'Return start KM must be at least the morning end KM.',
    'invalid_path': 'Invalid photo request.',
    'not_found': 'Record not found.',
    // Boarding / QR
    'invalid_token': 'QR code is invalid. Ask the driver to refresh the QR.',
    'expired_token': 'QR code expired. Ask the driver to refresh the QR.',
    'trip_not_active': 'Trip is not active. Wait for the driver to start.',
    'no_live_state': 'Live trip is not ready yet. Try again in a moment.',
    'not_coming': 'Mark Coming first, then scan the QR.',
    'not_in_queue': 'You are not on this trip queue. Mark Coming for this batch.',
    'wrong_batch': 'This QR is for a different cab/batch.',
    'capacity_full': 'Cab is full. Contact the driver or admin.',
    'invalid_commuter': 'Commuter profile not found.',
    'not_boarded': 'This rider is not boarded yet.',
    'missing_fields': 'Missing required fields.',
    'no_driver': 'No driver assigned to this batch.',
    'no_cab': 'No cab assigned to this batch.',
    'conflict': 'Trip update conflict. Please try again.',
    'aborted': 'Trip update was aborted. Please try again.',
  };
}
