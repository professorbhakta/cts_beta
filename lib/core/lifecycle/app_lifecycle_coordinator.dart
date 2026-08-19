import 'dart:async';

import 'package:cts/api/connectivity_service.dart';
import 'package:cts/app/router/session_auth_notifier.dart';
import 'package:cts/core/lifecycle/app_lifecycle_phase.dart';
import 'package:flutter/widgets.dart';

/// Context passed to resume listeners after a background → foreground transition.
class LifecycleResumeContext {
  const LifecycleResumeContext({
    required this.isOnline,
    required this.sessionValidated,
  });

  final bool isOnline;
  final bool sessionValidated;
}

typedef LifecycleResumeListener = Future<void> Function(
  LifecycleResumeContext context,
);

/// Central coordinator for foreground / background / resume behavior.
///
/// Platform notes:
/// - **Android:** Process may be killed in background; WebSocket and in-memory
///   state are lost. Resume must reconnect and refresh from server.
/// - **iOS:** App may stay suspended with socket closed; [inactive] does not
///   always mean background. Only [resumed] after a background phase triggers
///   refresh actions.
class AppLifecycleCoordinator with WidgetsBindingObserver {
  AppLifecycleCoordinator({
    required ConnectivityService connectivityService,
    required SessionAuthNotifier sessionAuthNotifier,
    Future<bool> Function()? refreshOnlineStatus,
  })  : _connectivityService = connectivityService,
        _sessionAuthNotifier = sessionAuthNotifier,
        _refreshOnlineStatus =
            refreshOnlineStatus ?? connectivityService.refreshOnlineStatus;

  final ConnectivityService _connectivityService;
  final SessionAuthNotifier _sessionAuthNotifier;
  final Future<bool> Function() _refreshOnlineStatus;

  AppLifecyclePhase _phase = AppLifecyclePhase.foreground;
  final List<LifecycleResumeListener> _resumeListeners = [];

  AppLifecyclePhase get phase => _phase;

  void start() {
    WidgetsBinding.instance.addObserver(this);
  }

  void stop() {
    WidgetsBinding.instance.removeObserver(this);
    _resumeListeners.clear();
    _phaseListeners.clear();
  }

  void addResumeListener(LifecycleResumeListener listener) {
    _resumeListeners.add(listener);
  }

  void removeResumeListener(LifecycleResumeListener listener) {
    _resumeListeners.remove(listener);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final nextPhase = lifecyclePhaseFromState(state);

    if (state == AppLifecycleState.resumed) {
      final wasBackground = isBackgroundPhase(_phase);
      _phase = AppLifecyclePhase.foreground;
      if (wasBackground) {
        unawaited(_handleResumeFromBackground());
      }
      return;
    }

    _phase = nextPhase;
    _notifyPhaseListeners(nextPhase);
  }

  Future<void> _handleResumeFromBackground() async {
    final isOnline = await _refreshOnlineStatus();

    var sessionValidated = false;
    if (_sessionAuthNotifier.loggedIn) {
      await _sessionAuthNotifier.refresh(validateWithServer: true);
      sessionValidated = _sessionAuthNotifier.loggedIn;
    }

    final context = LifecycleResumeContext(
      isOnline: isOnline,
      sessionValidated: sessionValidated,
    );

    for (final listener in List<LifecycleResumeListener>.from(_resumeListeners)) {
      await listener(context);
    }
  }

  void _notifyPhaseListeners(AppLifecyclePhase phase) {
    for (final listener
        in List<Future<void> Function(AppLifecyclePhase)>.from(_phaseListeners)) {
      unawaited(listener(phase));
    }
  }

  final List<Future<void> Function(AppLifecyclePhase phase)> _phaseListeners =
      [];

  void addPhaseListener(Future<void> Function(AppLifecyclePhase phase) listener) {
    _phaseListeners.add(listener);
  }

  void removePhaseListener(
    Future<void> Function(AppLifecyclePhase phase) listener,
  ) {
    _phaseListeners.remove(listener);
  }
}
