import 'package:cts/utils/sort_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('sortListAZ', () {
    test('sorts non-empty strings A-Z', () {
      final input = [
        _Named('Charlie'),
        _Named('alice'),
        _Named('Bob'),
      ];
      final sorted = sortListAZ(input, (item) => item.name);
      expect(sorted.map((e) => e.name).toList(), ['alice', 'Bob', 'Charlie']);
    });

    test('puts empty values at the end', () {
      final input = [_Named(''), _Named('Beta'), _Named(null)];
      final sorted = sortListAZ(input, (item) => item.name);
      expect(sorted.map((e) => e.name ?? '').toList(), ['Beta', '', '']);
    });
  });

  group('sortListAZMultiple', () {
    test('uses secondary field when primary ties', () {
      final withMobile = [
        _Pair('Same', '222'),
        _Pair('Same', '111'),
      ];
      final sorted = sortListAZMultiple<_Pair>(withMobile, [
        (item) => item.primary,
        (item) => item.secondary,
      ]);
      expect(sorted.map((e) => e.secondary).toList(), ['111', '222']);
    });
  });

  group('sortListNumeric', () {
    test('sorts ascending by default', () {
      final input = [_Num(3), _Num(1), _Num(2)];
      final sorted = sortListNumeric(input, (item) => item.value);
      expect(sorted.map((e) => e.value).toList(), [1, 2, 3]);
    });
  });
}

class _Named {
  _Named(this.name);
  final String? name;
}

class _Pair {
  _Pair(this.primary, this.secondary);
  final String primary;
  final String secondary;
}

class _Num {
  _Num(this.value);
  final int value;
}
