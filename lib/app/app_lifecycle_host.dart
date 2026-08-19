import 'dart:async';

import 'package:cts/app/router/session_auth_notifier.dart';
import 'package:cts/core/lifecycle/app_lifecycle_coordinator.dart';
import 'package:cts/core/lifecycle/app_lifecycle_phase.dart';
import 'package:cts/features/admin_home/providers/admin_provider.dart';
import 'package:cts/features/batches/providers/return_batch_provider.dart';
import 'package:cts/features/batches/providers/running_batch_provider.dart';
import 'package:cts/features/d2d/providers/d2d_channel_provider.dart';
import 'package:cts/api/connectivity_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Wires [AppLifecycleCoordinator] to feature providers inside [MultiProvider].
class AppLifecycleHost extends StatefulWidget {
  const AppLifecycleHost({super.key, required this.child});

  final Widget child;

  @override
  State<AppLifecycleHost> createState() => _AppLifecycleHostState();
}

class _AppLifecycleHostState extends State<AppLifecycleHost> {
  AppLifecycleCoordinator? _coordinator;
  late final LifecycleResumeListener _onResume;
  late final Future<void> Function(AppLifecyclePhase phase) _onPhaseChange;

  @override
  void initState() {
    super.initState();

    _onResume = _handleResume;
    _onPhaseChange = _handlePhaseChange;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _coordinator = AppLifecycleCoordinator(
        connectivityService: context.read<ConnectivityService>(),
        sessionAuthNotifier: context.read<SessionAuthNotifier>(),
      )..addResumeListener(_onResume)
        ..addPhaseListener(_onPhaseChange)
        ..start();
    });
  }

  Future<void> _handlePhaseChange(AppLifecyclePhase phase) async {
    if (!mounted) return;
    context.read<D2dChannelProvider>().onLifecyclePhase(phase);
  }

  Future<void> _handleResume(LifecycleResumeContext ctx) async {
    if (!mounted) return;

    final runningBatches = context.read<RunningBatchProvider>();
    final admin = context.read<AdminProvider>();
    final returnBatch = context.read<ReturnBatchProvider>();
    final d2d = context.read<D2dChannelProvider>();

    if (ctx.sessionValidated) {
      unawaited(runningBatches.fetchOnce());
      unawaited(admin.refreshRunningBatches());
    }

    unawaited(returnBatch.onAppResumed(isOnline: ctx.isOnline));
    unawaited(d2d.onAppResumed(isOnline: ctx.isOnline));
  }

  @override
  void dispose() {
    _coordinator
      ?..removeResumeListener(_onResume)
      ..removePhaseListener(_onPhaseChange)
      ..stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
