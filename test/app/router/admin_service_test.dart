import 'package:cts/app/router/admin_service.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdminCapabilities', () {
    test('ADMIN gets full catalog', () {
      expect(
        AdminCapabilities.forRole('ADMIN'),
        AdminCapabilities.all,
      );
    });

    test('SUPERVISOR gets Phase A allow-list including commuter + d2d', () {
      final allowed = AdminCapabilities.forRole('SUPERVISOR');
      expect(allowed, AdminCapabilities.supervisorAllowList);
      expect(allowed, contains(AdminService.batch));
      expect(allowed, contains(AdminService.cab));
      expect(allowed, contains(AdminService.route));
      expect(allowed, contains(AdminService.pop));
      expect(allowed, contains(AdminService.driver));
      expect(allowed, contains(AdminService.d2d));
      expect(allowed, contains(AdminService.commuter));
    });

    test('STAFF and DRIVER get no admin services', () {
      expect(AdminCapabilities.forRole('STAFF'), isEmpty);
      expect(AdminCapabilities.forRole('DRIVER'), isEmpty);
      expect(AdminCapabilities.forRole('COMMUTER'), isEmpty);
    });

    test('admin home allowed for SUPERVISOR shell', () {
      expect(
        AdminCapabilities.canAccessAdminLocation(
          'SUPERVISOR',
          RouteName.adminHomeScreen,
        ),
        isTrue,
      );
      expect(
        AdminCapabilities.canAccessAdminLocation(
          'STAFF',
          RouteName.adminHomeScreen,
        ),
        isFalse,
      );
    });

    test('serviceForLocation maps CRUD and D2D prefixes', () {
      expect(
        AdminCapabilities.serviceForLocation(RouteName.batchForm),
        AdminService.batch,
      );
      expect(
        AdminCapabilities.serviceForLocation('${RouteName.d2dChannel}/9'),
        AdminService.d2d,
      );
      expect(
        AdminCapabilities.serviceForLocation(RouteName.commuterScreen),
        AdminService.commuter,
      );
    });

    test('drawer catalog filters to allow-listed services', () {
      final items = AdminServiceCatalog.drawerItemsForRole('SUPERVISOR');
      expect(
        items.map((e) => e.service).toSet(),
        {
          AdminService.commuter,
          AdminService.pop,
          AdminService.batch,
          AdminService.cab,
          AdminService.driver,
          AdminService.route,
        },
      );
    });
  });

  group('RouteName role helpers', () {
    test('homeForRole maps STAFF to commuter and SUPERVISOR to admin', () {
      expect(RouteName.homeForRole('STAFF'), RouteName.commuterHomeScreen);
      expect(RouteName.homeForRole('SUPERVISOR'), RouteName.adminHomeScreen);
      expect(RouteName.homeForRole('ADMIN'), RouteName.adminHomeScreen);
      expect(RouteName.homeForRole('COMMUTER'), RouteName.commuterHomeScreen);
    });

    test('isAdminLike excludes STAFF', () {
      expect(RouteName.isAdminLike('ADMIN'), isTrue);
      expect(RouteName.isAdminLike('SUPERVISOR'), isTrue);
      expect(RouteName.isAdminLike('STAFF'), isFalse);
    });

    test('isCommuterLike includes STAFF', () {
      expect(RouteName.isCommuterLike('COMMUTER'), isTrue);
      expect(RouteName.isCommuterLike('STAFF'), isTrue);
      expect(RouteName.isCommuterLike('SUPERVISOR'), isFalse);
    });
  });
}
