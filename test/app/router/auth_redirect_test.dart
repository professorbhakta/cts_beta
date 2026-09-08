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

    test('supervisor lands on admin home from signIn', () {
      expect(
        resolveAuthRedirect(
          location: RouteName.signIn,
          authReady: true,
          loggedIn: true,
          userType: 'SUPERVISOR',
        ),
        RouteName.adminHomeScreen,
      );
    });

    test('supervisor may access allow-listed admin CRUD', () {
      expect(
        resolveAuthRedirect(
          location: RouteName.batchScreen,
          authReady: true,
          loggedIn: true,
          userType: 'SUPERVISOR',
        ),
        isNull,
      );
      expect(
        resolveAuthRedirect(
          location: RouteName.commuterScreen,
          authReady: true,
          loggedIn: true,
          userType: 'SUPERVISOR',
        ),
        isNull,
      );
      expect(
        resolveAuthRedirect(
          location: '${RouteName.d2dChannel}/12',
          authReady: true,
          loggedIn: true,
          userType: 'SUPERVISOR',
        ),
        isNull,
      );
    });

    test('staff lands on commuter home and cannot open admin CRUD', () {
      expect(
        resolveAuthRedirect(
          location: RouteName.signIn,
          authReady: true,
          loggedIn: true,
          userType: 'STAFF',
        ),
        RouteName.commuterHomeScreen,
      );
      expect(
        resolveAuthRedirect(
          location: RouteName.batchScreen,
          authReady: true,
          loggedIn: true,
          userType: 'STAFF',
        ),
        RouteName.commuterHomeScreen,
      );
      expect(
        resolveAuthRedirect(
          location: RouteName.adminHomeScreen,
          authReady: true,
          loggedIn: true,
          userType: 'STAFF',
        ),
        RouteName.commuterHomeScreen,
      );
    });

    test('staff may access commuter home prefixes', () {
      expect(
        resolveAuthRedirect(
          location: RouteName.commuterHomeScreen,
          authReady: true,
          loggedIn: true,
          userType: 'STAFF',
        ),
        isNull,
      );
      expect(
        resolveAuthRedirect(
          location: RouteName.boardingScan,
          authReady: true,
          loggedIn: true,
          userType: 'STAFF',
        ),
        isNull,
      );
    });
  });
}
