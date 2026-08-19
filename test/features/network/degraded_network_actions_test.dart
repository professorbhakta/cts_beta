import 'package:cts/api/connectivity_service.dart';
import 'package:cts/core/network/network_action_guard.dart';
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

class _OfflineConnectivity extends ConnectivityService {
  @override
  Future<bool> get isOnline async => false;

  @override
  Future<bool> refreshOnlineStatus() async => false;

  @override
  bool get isOnlineCached => false;
}

void main() {
  group('D2dChannelProvider network guard', () {
    late D2dChannelProvider provider;

    setUp(() {
      provider = D2dChannelProvider(
        _NoOpDriverRepository(),
        _NoOpD2dRepository(),
        networkGuard: NetworkActionGuard(_OfflineConnectivity()),
      );
    });

    tearDown(() {
      provider.dispose();
    });

    test('connect blocked offline sets error message', () async {
      provider.connect('42');
      await Future<void>.delayed(Duration.zero);
      expect(provider.errorMessage, contains('internet'));
      expect(provider.connectionLost, isTrue);
    });

    test('addCommuter blocked offline', () {
      provider.bindActiveBatchForLifecycle('42');
      final sent = provider.addCommuter('7');
      expect(sent, isFalse);
      expect(
        provider.actionErrorMessage,
        NetworkActionGuard.actionBlockedMessage,
      );
    });
  });

  group('ReturnBatchProvider network guard', () {
    test('confirmCommuter blocked when offline', () async {
      final provider = ReturnBatchProvider(
        _NoOpReturnBatchRepository(),
        networkGuard: NetworkActionGuard(_OfflineConnectivity()),
      );
      provider.bindActiveBatchForTesting('1');

      final error = await provider.confirmCommuter('99', '1');
      expect(error, NetworkActionGuard.actionBlockedMessage);
    });
  });
}
