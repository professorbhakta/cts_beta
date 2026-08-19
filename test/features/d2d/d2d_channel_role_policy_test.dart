import 'package:cts/features/d2d/models/d2d_channel_role_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('D2dChannelRolePolicy', () {
    test('admin can connect, add, remove from queue, but not stop or confirm', () {
      expect(D2dChannelRolePolicy.can('ADMIN', D2dChannelAction.connect), isTrue);
      expect(D2dChannelRolePolicy.can('ADMIN', D2dChannelAction.disconnect), isTrue);
      expect(D2dChannelRolePolicy.can('ADMIN', D2dChannelAction.addCommuter), isTrue);
      expect(
        D2dChannelRolePolicy.can('ADMIN', D2dChannelAction.removeFromQueue),
        isTrue,
      );
      expect(
        D2dChannelRolePolicy.can('ADMIN', D2dChannelAction.confirmPickup),
        isFalse,
      );
      expect(D2dChannelRolePolicy.can('ADMIN', D2dChannelAction.stopTrip), isFalse);
    });

    test('driver can add, remove, confirm, and stop', () {
      expect(D2dChannelRolePolicy.can('DRIVER', D2dChannelAction.addCommuter), isTrue);
      expect(
        D2dChannelRolePolicy.can('DRIVER', D2dChannelAction.removeFromQueue),
        isTrue,
      );
      expect(
        D2dChannelRolePolicy.can('DRIVER', D2dChannelAction.confirmPickup),
        isTrue,
      );
      expect(D2dChannelRolePolicy.can('DRIVER', D2dChannelAction.stopTrip), isTrue);
    });

    test('commuter cannot mutate live trip', () {
      expect(
        D2dChannelRolePolicy.can('COMMUTER', D2dChannelAction.addCommuter),
        isFalse,
      );
      expect(
        D2dChannelRolePolicy.can('COMMUTER', D2dChannelAction.stopTrip),
        isFalse,
      );
    });

    test('denial messages mention driver ownership for stop and confirm', () {
      expect(
        D2dChannelRolePolicy.denialMessage(D2dChannelAction.stopTrip),
        contains('driver'),
      );
      expect(
        D2dChannelRolePolicy.denialMessage(D2dChannelAction.confirmPickup),
        contains('driver'),
      );
    });
  });
}
