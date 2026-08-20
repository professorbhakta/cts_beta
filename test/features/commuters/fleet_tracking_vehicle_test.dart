import 'package:cts/features/commuters/constants/fleet_tracking_urls.dart';
import 'package:cts/features/commuters/models/commuter_model.dart';
import 'package:cts/models/cab_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FleetTrackingUrls', () {
    test('resolveVehicleId uses cab id when present', () {
      expect(
        FleetTrackingUrls.resolveVehicleId(
          cabTrackingVehicleId: 'ref-cab-99',
        ),
        'ref-cab-99',
      );
    });

    test('resolveVehicleId falls back to lab default', () {
      expect(
        FleetTrackingUrls.resolveVehicleId(cabTrackingVehicleId: null),
        FleetTrackingUrls.defaultVehicleId,
      );
      expect(
        FleetTrackingUrls.resolveVehicleId(cabTrackingVehicleId: '  '),
        FleetTrackingUrls.defaultVehicleId,
      );
    });

    test('trackingUrl embeds resolved id in query', () {
      final url = FleetTrackingUrls.trackingUrl(vehicleId: 'ref-abc');
      expect(url, contains('id=ref-abc'));
    });
  });

  group('CommuterModel cab tracking', () {
    test('cabTrackingVehicleId reads nested cab field', () {
      final commuter = CommuterModel(
        cabId: CabModel(trackingVehicleId: 'ref-from-api'),
      );
      expect(commuter.cabTrackingVehicleId, 'ref-from-api');
    });

    test('CabModel parses trackingVehicleId from JSON aliases', () {
      final cab = CabModel.fromJson({
        'id': 1,
        'regNumber': 'GJ01AB1234',
        'trackingVehicleId': 'ref-json',
      });
      expect(cab.trackingVehicleId, 'ref-json');
    });
  });
}
