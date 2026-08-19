import 'dart:math';

import 'package:cts/core/concurrency/batched_runner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('runWithConcurrency', () {
    test('returns empty list for empty input', () async {
      final results = await runWithConcurrency<int, int>(
        [],
        concurrency: 5,
        task: (item) async => item,
      );
      expect(results, isEmpty);
    });

    test('runs all items and preserves order', () async {
      final results = await runWithConcurrency<int, int>(
        [1, 2, 3, 4, 5],
        concurrency: 2,
        task: (item) async => item * 10,
      );
      expect(results, [10, 20, 30, 40, 50]);
    });

    test('limits in-flight tasks to concurrency', () async {
      var inFlight = 0;
      var maxInFlight = 0;

      await runWithConcurrency<int, int>(
        List.generate(25, (index) => index),
        concurrency: 4,
        task: (item) async {
          inFlight++;
          maxInFlight = max(maxInFlight, inFlight);
          await Future<void>.delayed(const Duration(milliseconds: 10));
          inFlight--;
          return item;
        },
      );

      expect(maxInFlight, lessThanOrEqualTo(4));
      expect(maxInFlight, greaterThan(1));
    });

    test('rejects concurrency below 1', () {
      expect(
        () => runWithConcurrency<int, int>(
          [1],
          concurrency: 0,
          task: (item) async => item,
        ),
        throwsArgumentError,
      );
    });
  });
}
