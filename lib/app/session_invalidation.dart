import 'package:cts/app/router/route_names.dart';
import 'package:cts/app/router/session_auth_notifier.dart';
import 'package:cts/appManager/snackbar_service.dart';
import 'package:go_router/go_router.dart';

typedef SessionInvalidatedCallback = Future<void> Function();

/// Clears auth state, notifies the user, and routes to sign-in.
SessionInvalidatedCallback createSessionInvalidatedHandler({
  required SessionAuthNotifier authNotifier,
}) {
  return () async {
    SnackBarService.showErrorSnackbar(
      'Your session has expired. Please log in again.',
    );
    await authNotifier.refresh();
    final context = SnackBarService.navigatorKey.currentContext;
    if (context != null && context.mounted) {
      context.go(RouteName.signIn);
    }
  };
}
