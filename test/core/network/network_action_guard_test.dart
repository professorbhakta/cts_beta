import 'package:cts/api/connectivity_service.dart';
import 'package:cts/core/network/network_action_guard.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeConnectivity extends ConnectivityService {
  _FakeConnectivity({bool? initialOnline}) : _online = initialOnline;

  bool? _online;

  void setOnline(bool value) => _online = value;

  @override
  Future<bool> get isOnline async => _online ?? true;

  @override
  Future<bool> refreshOnlineStatus() async => _online ?? true;

  @override
  bool get isOnlineCached => _online ?? true;
}

void main() {
  group('NetworkActionGuard', () {
    late _FakeConnectivity connectivity;
    late NetworkActionGuard guard;

    setUp(() {
      connectivity = _FakeConnectivity(initialOnline: true);
      guard = NetworkActionGuard(connectivity);
    });

    test('check returns online when connected', () async {
      final result = await guard.check();
      expect(result.isOnline, isTrue);
      expect(result.message, isNull);
    });

    test('check returns offline with message when disconnected', () async {
      connectivity.setOnline(false);
      final result = await guard.check();
      expect(result.isOnline, isFalse);
      expect(result.message, NetworkActionGuard.actionBlockedMessage);
    });

    test('appearsOnline reflects cached connectivity', () {
      connectivity.setOnline(true);
      expect(guard.appearsOnline, isTrue);
      connectivity.setOnline(false);
      expect(guard.appearsOnline, isFalse);
    });

    test('queueWhenOffline fails closed in P5 (no queue yet)', () async {
      connectivity.setOnline(false);
      final result = await guard.check(
        policy: NetworkActionPolicy.queueWhenOffline,
      );
      expect(result.isOnline, isFalse);
    });
  });
}
