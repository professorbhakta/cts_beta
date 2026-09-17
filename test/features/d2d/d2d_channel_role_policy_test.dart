import 'package:cts/features/d2d/models/d2d_channel_role_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('D2dChannelRolePolicy', () {
    test('admin can connect, add, remove, confirm, but not stop', () {
      expect(D2dChannelRolePolicy.can('ADMIN', D2dChannelAction.connect), isTrue);
      expect(D2dChannelRolePolicy.can('ADMIN', D2dChannelAction.disconnect), isTrue);
      expect(D2dChannelRolePolicy.can('ADMIN', D2dChannelAction.addCommuter), isTrue);
      expect(
        D2dChannelRolePolicy.can('ADMIN', D2dChannelAction.removeFromQueue),
        isTrue,
      );
      expect(
        D2dChannelRolePolicy.can('ADMIN', D2dChannelAction.confirmPickup),
        isTrue,
      );
      expect(D2dChannelRolePolicy.can('ADMIN', D2dChannelAction.stopTrip), isFalse);
    });

    test('driver cannot add; can remove, confirm, and stop', () {
      expect(D2dChannelRolePolicy.can('DRIVER', D2dChannelAction.addCommuter), isFalse);
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

    test('supervisor can connect, add, remove, confirm, but not stop', () {
      expect(
        D2dChannelRolePolicy.can('SUPERVISOR', D2dChannelAction.connect),
        isTrue,
      );
      expect(
        D2dChannelRolePolicy.can('SUPERVISOR', D2dChannelAction.addCommuter),
        isTrue,
      );
      expect(
        D2dChannelRolePolicy.can('SUPERVISOR', D2dChannelAction.removeFromQueue),
        isTrue,
      );
      expect(
        D2dChannelRolePolicy.can('SUPERVISOR', D2dChannelAction.confirmPickup),
        isTrue,
      );
      expect(
        D2dChannelRolePolicy.can('SUPERVISOR', D2dChannelAction.stopTrip),
        isFalse,
      );
    });

    test('super_admin monitors: connect/board/remove, no add, no stop', () {
      expect(
        D2dChannelRolePolicy.can('SUPER_ADMIN', D2dChannelAction.connect),
        isTrue,
      );
      expect(
        D2dChannelRolePolicy.can('SUPER_ADMIN', D2dChannelAction.addCommuter),
        isFalse,
      );
      expect(
        D2dChannelRolePolicy.can('SUPER_ADMIN', D2dChannelAction.confirmPickup),
        isTrue,
      );
      expect(
        D2dChannelRolePolicy.can('SUPER_ADMIN', D2dChannelAction.removeFromQueue),
        isTrue,
      );
      expect(
        D2dChannelRolePolicy.can('SUPER_ADMIN', D2dChannelAction.stopTrip),
        isFalse,
      );
    });

    test('staff cannot mutate live trip', () {
      expect(
        D2dChannelRolePolicy.can('STAFF', D2dChannelAction.connect),
        isFalse,
      );
      expect(
        D2dChannelRolePolicy.can('STAFF', D2dChannelAction.addCommuter),
        isFalse,
      );
    });

    test('denial messages for stop mention driver', () {
      expect(
        D2dChannelRolePolicy.denialMessage(D2dChannelAction.stopTrip),
        contains('driver'),
      );
    });
  });
}
