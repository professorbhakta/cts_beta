import 'package:cts/features/d2d/providers/d2d_channel_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('STOP snapshot with isActive false marks the trip ended', () {
    expect(
      d2dResultMarksTripEnded({'data': [], 'isActive': false, 'D2D_id': 8}),
      isTrue,
    );
  });

  test('live snapshot does not mark the trip ended', () {
    expect(
      d2dResultMarksTripEnded({'data': [], 'isActive': true, 'D2D_id': 8}),
      isFalse,
    );
    expect(d2dResultMarksTripEnded({'data': [], 'D2D_id': 8}), isFalse);
  });

  test('snake_case is_active false is treated as ended', () {
    expect(d2dResultMarksTripEnded({'is_active': false}), isTrue);
  });
}
