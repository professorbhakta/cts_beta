import 'package:cts/api/connectivity_service.dart';
import 'package:cts/app/router/session_auth_notifier.dart';
import 'package:cts/core/lifecycle/app_lifecycle_coordinator.dart';
import 'package:cts/core/lifecycle/app_lifecycle_phase.dart';
import 'package:cts/data/repositories/session_repository_impl.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppLifecycleCoordinator', () {
    late SessionAuthNotifier sessionAuthNotifier;
    late AppLifecycleCoordinator coordinator;
    var resumeCount = 0;
    var lastOnline = true;

    setUp(() {
      resumeCount = 0;
      lastOnline = true;
      sessionAuthNotifier = SessionAuthNotifier(SessionRepositoryImpl());
      coordinator = AppLifecycleCoordinator(
        connectivityService: ConnectivityService(),
        sessionAuthNotifier: sessionAuthNotifier,
        refreshOnlineStatus: () async => lastOnline,
      )..addResumeListener((ctx) async {
          resumeCount++;
          lastOnline = ctx.isOnline;
        });
      coordinator.start();
    });

    tearDown(() {
      coordinator.stop();
    });

    test('does not fire resume listener on inactive alone', () async {
      coordinator.didChangeAppLifecycleState(AppLifecycleState.inactive);
      await Future<void>.delayed(Duration.zero);

      expect(resumeCount, 0);
    });

    test('fires resume listener after background then resumed', () async {
      lastOnline = false;
      coordinator.didChangeAppLifecycleState(AppLifecycleState.paused);
      coordinator.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await Future<void>.delayed(Duration.zero);

      expect(resumeCount, 1);
      expect(lastOnline, isFalse);
    });

    test('notifies phase listeners on background', () async {
      AppLifecyclePhase? capturedPhase;
      coordinator.addPhaseListener((phase) async {
        capturedPhase = phase;
      });

      coordinator.didChangeAppLifecycleState(AppLifecycleState.paused);
      await Future<void>.delayed(Duration.zero);

      expect(capturedPhase, AppLifecyclePhase.background);
    });
  });
}
