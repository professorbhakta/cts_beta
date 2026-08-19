import 'package:cts/app/router/auth_redirect.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveAuthRedirect', () {
    test('splash allowed while auth resolves', () {
      expect(
        resolveAuthRedirect(
          location: RouteName.splashScreen,
          authReady: false,
          loggedIn: false,
          userType: null,
        ),
        isNull,
      );
    });

    test('signUp redirects to signIn', () {
      expect(
        resolveAuthRedirect(
          location: RouteName.signUp,
          authReady: true,
          loggedIn: false,
          userType: null,
        ),
        RouteName.signIn,
      );
    });

    test('protected route sends guest to signIn', () {
      expect(
        resolveAuthRedirect(
          location: RouteName.adminHomeScreen,
          authReady: true,
          loggedIn: false,
          userType: null,
        ),
        RouteName.signIn,
      );
    });

    test('logged-in user leaves signIn for role home', () {
      expect(
        resolveAuthRedirect(
          location: RouteName.signIn,
          authReady: true,
          loggedIn: true,
          userType: 'DRIVER',
        ),
        RouteName.driverHomeScreen,
      );
    });

    test('driver blocked from admin CRUD', () {
      expect(
        resolveAuthRedirect(
          location: RouteName.batchScreen,
          authReady: true,
          loggedIn: true,
          userType: 'DRIVER',
        ),
        RouteName.driverHomeScreen,
      );
    });

    test('commuter blocked from driver return route', () {
      expect(
        resolveAuthRedirect(
          location: '${RouteName.driverReturnCommuter}/4',
          authReady: true,
          loggedIn: true,
          userType: 'COMMUTER',
        ),
        RouteName.commuterHomeScreen,
      );
    });

    test('admin may access driver-only route', () {
      expect(
        resolveAuthRedirect(
          location: RouteName.driverHomeScreen,
          authReady: true,
          loggedIn: true,
          userType: 'ADMIN',
        ),
        isNull,
      );
    });
  });
}
