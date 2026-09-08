import 'package:cts/features/batches/models/return_trip_log_placeholders.dart';
import 'package:cts/features/d2d/models/boarding_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('return trip log refs', () {
    test('carry batch and optional return_trip_id', () {
      const trip = ReturnTripLogRef(batchId: '12', returnTripId: '99');
      const rclist = RclistRef(batchId: '12', returnTripId: '99');
      expect(trip.batchId, '12');
      expect(trip.returnTripId, '99');
      expect(rclist.returnTripId, '99');
    });
  });

  group('BoardingQrPayload return_trip_id', () {
    test('parses return_trip_id from return mint JSON', () {
      final payload = BoardingQrPayload.fromJson({
        'token': 'tok',
        'qr_payload': 'tok',
        'expires_in': 60,
        'batch_id': '1',
        'd2d_id': 0,
        'trip_date': '2026-09-08',
        'return_trip_id': 42,
      });
      expect(payload.token, 'tok');
      expect(payload.returnTripId, '42');
    });

    test('morning mint leaves returnTripId null', () {
      final payload = BoardingQrPayload.fromJson({
        'token': 'tok',
        'expires_in': 60,
        'batch_id': '1',
        'd2d_id': 3,
        'trip_date': '2026-09-08',
      });
      expect(payload.returnTripId, isNull);
    });
  });
}
