import 'package:cts/core/lifecycle/app_lifecycle_phase.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('lifecyclePhaseFromState', () {
    test('maps resumed to foreground', () {
      expect(
        lifecyclePhaseFromState(AppLifecycleState.resumed),
        AppLifecyclePhase.foreground,
      );
    });

    test('maps paused and hidden to background', () {
      expect(
        lifecyclePhaseFromState(AppLifecycleState.paused),
        AppLifecyclePhase.background,
      );
      expect(
        lifecyclePhaseFromState(AppLifecycleState.hidden),
        AppLifecyclePhase.background,
      );
    });

    test('maps inactive separately from background', () {
      expect(
        lifecyclePhaseFromState(AppLifecycleState.inactive),
        AppLifecyclePhase.inactive,
      );
      expect(isBackgroundPhase(AppLifecyclePhase.inactive), isFalse);
    });
  });

  group('isBackgroundPhase', () {
    test('is true for background and detached', () {
      expect(isBackgroundPhase(AppLifecyclePhase.background), isTrue);
      expect(isBackgroundPhase(AppLifecyclePhase.detached), isTrue);
    });

    test('is false for foreground and inactive', () {
      expect(isBackgroundPhase(AppLifecyclePhase.foreground), isFalse);
      expect(isBackgroundPhase(AppLifecyclePhase.inactive), isFalse);
    });
  });
}
