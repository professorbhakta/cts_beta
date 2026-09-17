import 'package:cts/features/admin_bootstrap/mappers/admin_bootstrap_list_mapper.dart';
import 'package:cts/features/admin_bootstrap/models/admin_bootstrap_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdminBootstrapListMapper', () {
    late AdminBootstrapResponse luggage;

    setUp(() {
      luggage = const AdminBootstrapResponse(
        status: 'ok',
        generatedAt: '2026-09-10T00:00:00+05:30',
        adminCode: 'admin-1',
        routes: [
          BootstrapRoute(id: 1, routeName: 'North'),
        ],
        pickUpPoints: [
          BootstrapPickUpPoint(
            id: 10,
            pickUpPointName: 'Gate A',
            routeId: 1,
            inLine: 2,
          ),
        ],
        batches: [
          BootstrapBatch(
            id: '42',
            batchName: 'Morning',
            batchTime: '07:00:00',
            endTime: '18:00:00',
          ),
        ],
        cabs: [
          BootstrapCab(
            id: 5,
            regNumber: 'GJ-01',
            capacity: 12,
            routeId: 1,
            km: 1200,
            trackingVehicleId: 'fleet-1',
          ),
        ],
        drivers: [
          BootstrapDriver(
            driverId: 7,
            userId: 70,
            username: 'driver1',
            mobileNumber: '9000000001',
            batchId: '42',
            cabId: 5,
          ),
        ],
        organizations: [
          BootstrapOrganization(id: 'org-1', orgName: 'Parul University'),
        ],
        commuters: [
          BootstrapCommuter(
            commuterId: 9,
            userId: 90,
            username: 'student1',
            mobileNumber: '9000000002',
            userType: 'COMMUTER',
            batchId: '42',
            popId: 10,
            cabId: 5,
            isComing: true,
            hasPaid: true,
            organizationId: 'org-1',
          ),
        ],
      );
    });

    test('maps nested list models from flat luggage', () {
      final routes = AdminBootstrapListMapper.routes(luggage);
      final batches = AdminBootstrapListMapper.batches(luggage);
      final pops = AdminBootstrapListMapper.pops(luggage);
      final cabs = AdminBootstrapListMapper.cabs(luggage);
      final drivers = AdminBootstrapListMapper.drivers(luggage);
      final commuters = AdminBootstrapListMapper.commuters(luggage);

      expect(routes.single.routeName, 'North');
      expect(batches.single.id, 42);
      expect(batches.single.returnTime, '18:00:00');
      expect(pops.single.routeId?.routeName, 'North');
      expect(cabs.single.trackingVehicleId, 'fleet-1');
      expect(cabs.single.km, 1200);
      expect(cabs.single.driver, isNotEmpty);
      expect(drivers.single.userId?.username, 'driver1');
      expect(drivers.single.batchId?.batchName, 'Morning');
      expect(commuters.single.isComing, isTrue);
      expect(commuters.single.organizationId, 'org-1');
      expect(commuters.single.organizationName, 'Parul University');
      expect(commuters.single.popId?.pickUpPointName, 'Gate A');
      expect(commuters.single.userId?.hasPaid, isTrue);
    });
  });
}
