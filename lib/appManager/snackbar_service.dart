import 'package:cts/appManager/colors.dart';
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

  static void showsSuccessSnackbar(String message, String backgroundColor) {
    _showCustomTopMessage(
      message,
      backgroundColor:
          backgroundColor.isEmpty ? AppColors.acGreen : AppColors.acRed,
      icon: Icons.check_circle_outline,
    );
  }

  static void showErrorSnackbar(String message) {
    _showCustomTopMessage(
      message,
      backgroundColor: AppColors.acRed,
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
            color: backgroundColor ?? AppColors.acBlue,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: AppColors.acWhite),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: AppColors.acWhite,
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

