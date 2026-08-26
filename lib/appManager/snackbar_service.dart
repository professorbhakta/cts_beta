import 'package:cts/theme/app_theme.dart';
import 'package:cts/theme/cts_colors.dart';
import 'package:flutter/material.dart';

// This will hold the reference to the active overlay so we can remove it on the *next* call.
OverlayEntry? _overlayEntry;

class SnackBarService {
  // Key for custom overlays
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Key for standard SnackBars, used by functions in functions_and_tools.dart
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Theme colors from the messenger context, or light defaults when null.
  static (ColorScheme, CtsColors) resolveColors() {
    final ctx = scaffoldMessengerKey.currentContext;
    if (ctx != null) {
      return (ctx.scheme, ctx.cts);
    }
    return (AppTheme.light().colorScheme, CtsColors.light());
  }

  static void showsSuccessSnackbar(String message, String backgroundColor) {
    final (scheme, cts) = resolveColors();
    _showCustomTopMessage(
      message,
      backgroundColor: backgroundColor.isEmpty ? cts.success : scheme.error,
      icon: Icons.check_circle_outline,
    );
  }

  static void showErrorSnackbar(String message) {
    final (scheme, _) = resolveColors();
    _showCustomTopMessage(
      message,
      backgroundColor: scheme.error,
      icon: Icons.error_outline,
    );
  }

  static void _showCustomTopMessage(
    String message, {
    Color? backgroundColor,
    IconData? icon,
  }) {
    // If an overlay is already showing from a previous call, remove it.
    _overlayEntry?.remove();
    _overlayEntry = null; // Clear the old reference immediately

    // Get the overlay from the correct navigatorKey
    final OverlayState? overlayState = navigatorKey.currentState?.overlay;
    if (overlayState == null) return;

    final (scheme, cts) = resolveColors();
    final bg = backgroundColor ?? cts.info;
    final onBg = scheme.onError; // white/on-error for saturated banners

    // Create a new entry for the new message.
    final newOverlayEntry = OverlayEntry(
      builder: (context) {
        final topInset = MediaQuery.paddingOf(context).top;
        return Positioned(
          top: topInset + 8,
          left: 16,
          right: 16,
          child: Material(
            elevation: 7.0,
            borderRadius: BorderRadius.circular(12),
            color: bg,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: onBg),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: onBg,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // Store the new entry in our global variable so it can be removed by the *next* call.
    _overlayEntry = newOverlayEntry;

    // Insert the new entry into the overlay.
    overlayState.insert(newOverlayEntry);

    // Set a timer to automatically remove THIS SPECIFIC entry.
    Future.delayed(const Duration(seconds: 3), () {
      // Only remove the entry if it hasn't been removed by a subsequent call already.
      // We check if the global entry is still pointing to the one we created.
      if (_overlayEntry == newOverlayEntry) {
        newOverlayEntry.remove();
        _overlayEntry = null; // Clear the reference
      }
    });
  }
}
