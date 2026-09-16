import 'package:cts/features/d2d/helpers/d2d_batch_membership.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('D2dBatchMembership', () {
    test('isOtherBatch when home differs from trip', () {
      final m = D2dBatchMembership.fromUserBatchMap({4: '1', 5: '2'});
      expect(m.isOtherBatch(4, '1'), isFalse);
      expect(m.isOtherBatch(5, '1'), isTrue);
      expect(m.isOtherBatch(99, '1'), isFalse);
    });

    test('knownHomeBatchId from WS wins over luggage', () {
      final m = D2dBatchMembership.fromUserBatchMap({4: '1'});
      expect(
        m.isOtherBatch(4, '1', knownHomeBatchId: '9'),
        isTrue,
      );
      expect(
        m.isOtherBatch(99, '1', knownHomeBatchId: '1'),
        isFalse,
      );
    });

    test('fromCommuterRows skips incomplete rows', () {
      final m = D2dBatchMembership.fromCommuterRows([
        (userId: 1, batchId: '10'),
        (userId: null, batchId: '10'),
        (userId: 2, batchId: ''),
        (userId: 3, batchId: ' 11 '),
      ]);
      expect(m.size, 2);
      expect(m.homeBatchIdFor(1), '10');
      expect(m.homeBatchIdFor(3), '11');
    });
  });

  group('d2dBoardBeepKind', () {
    test('same vs other', () {
      expect(
        d2dBoardBeepKind(isOtherBatch: false),
        D2dBoardBeepKind.sameBatch,
      );
      expect(
        d2dBoardBeepKind(isOtherBatch: true),
        D2dBoardBeepKind.otherBatch,
      );
    });
  });

  group('d2dNewAlreadyInIds', () {
    test('skips initial hydrate', () {
      expect(
        d2dNewAlreadyInIds(
          previous: {},
          current: {1, 2},
          skipBecauseInitialHydrate: true,
        ),
        isEmpty,
      );
    });

    test('returns only newcomers after hydrate', () {
      expect(
        d2dNewAlreadyInIds(
          previous: {1},
          current: {1, 2, 3},
          skipBecauseInitialHydrate: false,
        ),
        {2, 3},
      );
    });
  });

  group('d2dBoardBeepForNewcomers', () {
    test('null when no newcomers', () {
      expect(
        d2dBoardBeepForNewcomers(
          newcomers: {},
          isOtherBatch: (_) => true,
        ),
        isNull,
      );
    });

    test('other wins when any newcomer is other-batch', () {
      expect(
        d2dBoardBeepForNewcomers(
          newcomers: {1, 2, 3},
          isOtherBatch: (id) => id == 2,
        ),
        D2dBoardBeepKind.otherBatch,
      );
    });

    test('same when all newcomers are home batch', () {
      expect(
        d2dBoardBeepForNewcomers(
          newcomers: {1, 2},
          isOtherBatch: (_) => false,
        ),
        D2dBoardBeepKind.sameBatch,
      );
    });
  });
}
