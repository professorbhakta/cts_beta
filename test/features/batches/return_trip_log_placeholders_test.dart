import 'package:cts/features/batches/models/return_trip_log_placeholders.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('return trip log placeholders', () {
    test('refs carry batch identity only (no invented wire fields)', () {
      const trip = ReturnTripLogRef(batchId: '12');
      const rclist = RclistRef(batchId: '12');
      const vm = ReturnBoardingQrViewModel(
        tripLog: trip,
        rclist: rclist,
      );

      expect(trip.batchId, '12');
      expect(rclist.batchId, '12');
      expect(vm.qrPayload, isNull);
    });

    test('view model may hold opaque qrPayload without field inventing', () {
      const vm = ReturnBoardingQrViewModel(
        tripLog: ReturnTripLogRef(batchId: '1'),
        rclist: RclistRef(batchId: '1'),
        qrPayload: 'opaque-token-placeholder',
      );
      expect(vm.qrPayload, 'opaque-token-placeholder');
    });
  });
}
