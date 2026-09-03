import 'package:cts/core/lifecycle/app_lifecycle_phase.dart';
import 'package:cts/features/batches/providers/return_batch_provider.dart';
import 'package:cts/features/batches/repositories/return_batch_repository.dart';
import 'package:cts/features/d2d/providers/d2d_channel_provider.dart';
import 'package:cts/features/d2d/repositories/d2d_repository.dart';
import 'package:cts/features/drivers/repositories/driver_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _NoOpDriverRepository implements DriverRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoOpD2dRepository implements D2dRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoOpReturnBatchRepository implements ReturnBatchRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('D2dChannelProvider lifecycle', () {
    late D2dChannelProvider provider;

    setUp(() {
      provider = D2dChannelProvider(
        _NoOpDriverRepository(),
        _NoOpD2dRepository(),
      );
    });

    tearDown(() {
      provider.dispose();
    });

    test('onAppResumed is no-op without connected batch', () async {
      await provider.onAppResumed(isOnline: true);
      expect(provider.connectedBatchId, isNull);
      expect(provider.connectionLost, isFalse);
    });

    test('onAppResumed offline sets offline message when batch is bound', () async {
      provider.bindActiveBatchForLifecycle('99');
      await provider.onAppResumed(isOnline: false);
      expect(provider.connectionLost, isTrue);
      expect(provider.errorMessage, contains('network'));
    });

    test('onLifecyclePhase tracks background without disconnecting', () {
      provider.bindActiveBatchForLifecycle('42');
      provider.onLifecyclePhase(AppLifecyclePhase.background);
      provider.onLifecyclePhase(AppLifecyclePhase.foreground);
      expect(provider.connectedBatchId, '42');
    });

    test('disconnect clears connected batch id', () {
      provider.bindActiveBatchForLifecycle('42');
      provider.disconnect();
      expect(provider.connectedBatchId, isNull);
    });

    test('isChannelLive uses connection/trip flags, not remaining queue', () {
      expect(provider.isChannelLive, isFalse);

      provider.debugSetChannelLiveState(batchId: '7');
      expect(provider.commuters, isEmpty);
      expect(provider.isChannelLive, isTrue);

      provider.debugSetChannelLiveState(
        batchId: '7',
        tripStatus: D2dTripStatus.active,
      );
      expect(provider.isChannelLive, isTrue);

      provider.debugSetChannelLiveState(
        batchId: '7',
        connectionLost: true,
        tripStatus: D2dTripStatus.active,
      );
      expect(provider.isChannelLive, isFalse);

      provider.debugSetChannelLiveState(
        batchId: '7',
        tripStatus: D2dTripStatus.ended,
        tripEnded: true,
      );
      expect(provider.isChannelLive, isFalse);

      provider.debugSetChannelLiveState(
        batchId: '7',
        tripStatus: D2dTripStatus.none,
      );
      expect(provider.isChannelLive, isFalse);
    });
  });

  group('ReturnBatchProvider lifecycle', () {
    test('onAppResumed is no-op without active batch', () async {
      final provider = ReturnBatchProvider(_NoOpReturnBatchRepository());
      await provider.onAppResumed(isOnline: true);
      expect(provider.activeBatchId, isNull);
    });
  });
}
