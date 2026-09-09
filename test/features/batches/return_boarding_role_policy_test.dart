import 'package:cts/features/batches/models/return_boarding_role_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReturnBoardingRolePolicy', () {
    test('canShowQr allows DRIVER ADMIN SUPERVISOR only', () {
      expect(ReturnBoardingRolePolicy.canShowQr('DRIVER'), isTrue);
      expect(ReturnBoardingRolePolicy.canShowQr('ADMIN'), isTrue);
      expect(ReturnBoardingRolePolicy.canShowQr('SUPERVISOR'), isTrue);
      expect(ReturnBoardingRolePolicy.canShowQr('COMMUTER'), isFalse);
      expect(ReturnBoardingRolePolicy.canShowQr('STAFF'), isFalse);
      expect(ReturnBoardingRolePolicy.canShowQr(null), isFalse);
    });

    test('canScan allows COMMUTER and STAFF only', () {
      expect(ReturnBoardingRolePolicy.canScan('COMMUTER'), isTrue);
      expect(ReturnBoardingRolePolicy.canScan('STAFF'), isTrue);
      expect(ReturnBoardingRolePolicy.canScan('DRIVER'), isFalse);
      expect(ReturnBoardingRolePolicy.canScan('ADMIN'), isFalse);
      expect(ReturnBoardingRolePolicy.canScan('SUPERVISOR'), isFalse);
      expect(ReturnBoardingRolePolicy.canScan(null), isFalse);
    });
  });
}
