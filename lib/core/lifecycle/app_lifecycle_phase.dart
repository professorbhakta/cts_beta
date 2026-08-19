import 'package:flutter/widgets.dart';

/// Normalized app lifecycle phase for cross-platform resume handling.
///
/// iOS may emit [inactive] for control center / incoming call without a full
/// background transition. Android typically moves paused → hidden → resumed.
enum AppLifecyclePhase {
  foreground,
  inactive,
  background,
  detached,
}

/// Maps Flutter [AppLifecycleState] to [AppLifecyclePhase].
AppLifecyclePhase lifecyclePhaseFromState(AppLifecycleState state) {
  switch (state) {
    case AppLifecycleState.resumed:
      return AppLifecyclePhase.foreground;
    case AppLifecycleState.inactive:
      return AppLifecyclePhase.inactive;
    case AppLifecycleState.paused:
    case AppLifecycleState.hidden:
      return AppLifecyclePhase.background;
    case AppLifecycleState.detached:
      return AppLifecyclePhase.detached;
  }
}

/// True when the OS has moved the app out of the active foreground.
bool isBackgroundPhase(AppLifecyclePhase phase) {
  return phase == AppLifecyclePhase.background ||
      phase == AppLifecyclePhase.detached;
}
