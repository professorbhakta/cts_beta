import 'package:cts/features/d2d/models/odometer_models.dart';
import 'package:cts/features/drivers/helpers/driver_yesterday_nudge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('incomplete flag needs attention', () {
    expect(
      legNeedsDriverAttention(
        const OdometerLegSnapshot(incomplete: true, startKm: 10, endKm: 10),
      ),
      isTrue,
    );
  });

  test('auto_closed flag needs attention', () {
    expect(
      legNeedsDriverAttention(const OdometerLegSnapshot(autoClosed: true)),
      isTrue,
    );
  });

  test('started incomplete odo needs attention', () {
    expect(
      legNeedsDriverAttention(
        const OdometerLegSnapshot(startKm: 12, complete: false),
      ),
      isTrue,
    );
  });

  test('clean complete unequal km does not', () {
    expect(
      legNeedsDriverAttention(
        const OdometerLegSnapshot(
          startKm: 10,
          endKm: 40,
          complete: true,
        ),
      ),
      isFalse,
    );
  });

  test('auto-close equal km heuristic', () {
    expect(
      legNeedsDriverAttention(
        const OdometerLegSnapshot(
          startKm: 10,
          endKm: 10,
          complete: true,
        ),
      ),
      isTrue,
    );
  });
}
