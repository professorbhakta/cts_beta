import 'package:cts/features/batches/models/return_trip_log_placeholders.dart';
import 'package:cts/features/d2d/models/boarding_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('return trip log refs', () {
    test('carry batch and optional returnTripLogId', () {
      const trip = ReturnTripLogRef(batchId: '12', returnTripLogId: '99');
      const rclist = RclistRef(batchId: '12', returnTripLogId: '99');
      expect(trip.batchId, '12');
      expect(trip.returnTripLogId, '99');
      expect(rclist.returnTripLogId, '99');
    });
  });

  group('BoardingQrPayload returnTripLogId / tripLeg', () {
    test('parses return_trip_id and trip from return mint JSON', () {
      final payload = BoardingQrPayload.fromJson({
        'token': 'tok',
        'qr_payload': 'tok',
        'expires_in': 60,
        'batch_id': '1',
        'd2d_id': 0,
        'trip_date': '2026-09-08',
        'return_trip_id': 42,
        'trip': 'return',
      });
      expect(payload.token, 'tok');
      expect(payload.returnTripLogId, '42');
      expect(payload.tripLeg, 'return');
      expect(payload.isReturnLeg, isTrue);
    });

    test('morning mint leaves returnTripLogId null', () {
      final payload = BoardingQrPayload.fromJson({
        'token': 'tok',
        'expires_in': 60,
        'batch_id': '1',
        'd2d_id': 3,
        'trip_date': '2026-09-08',
        'trip': 'morning',
      });
      expect(payload.returnTripLogId, isNull);
      expect(payload.tripLeg, 'morning');
      expect(payload.isReturnLeg, isFalse);
    });
  });
}
