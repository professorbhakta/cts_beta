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

void main() {
  group('D2dChannelProvider role gating', () {
    late D2dChannelProvider provider;

    tearDown(() {
      provider.dispose();
    });

    test('admin stopTrip is rejected with clear message', () {
      provider = D2dChannelProvider(
        _NoOpDriverRepository(),
        _NoOpD2dRepository(),
        sessionRoleOverride: 'ADMIN',
      );

      final stopped = provider.stopTrip();

      expect(stopped, isFalse);
      expect(provider.actionErrorMessage, contains('driver'));
    });

    test('admin confirmPickup is rejected', () {
      provider = D2dChannelProvider(
        _NoOpDriverRepository(),
        _NoOpD2dRepository(),
        sessionRoleOverride: 'ADMIN',
      );

      final confirmed = provider.confirmCommuter('4');

      expect(confirmed, isFalse);
      expect(provider.actionErrorMessage, contains('driver'));
    });

    test('driver addCommuter is allowed when connected', () {
      provider = D2dChannelProvider(
        _NoOpDriverRepository(),
        _NoOpD2dRepository(),
        sessionRoleOverride: 'DRIVER',
      );
      provider.bindActiveBatchForLifecycle('1');

      final added = provider.addCommuter('0');

      expect(added, isFalse);
      expect(provider.actionErrorMessage, isNot(contains('not allowed')));
    });
  });

  group('parseAlreadyInFromResult', () {
    test('parses already_in list from WS snapshot', () {
      final parsed = parseAlreadyInFromResult({
        'data': [],
        'already_in': [
          {
            '4': {
              'username': 'Alice',
              'mobile_number': '9999999999',
              'pickUpPoint': 'Stop A',
              'inLine': 1,
            },
          },
        ],
      });

      expect(parsed, isNotNull);
      expect(parsed!.length, 1);
      expect(parsed.first.username, 'Alice');
      expect(parsed.first.id, 4);
    });

    test('returns null when already_in is absent', () {
      expect(parseAlreadyInFromResult({'data': []}), isNull);
    });
  });
}
