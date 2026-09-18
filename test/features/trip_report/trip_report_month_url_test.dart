import 'package:cts/features/trip_report/repositories/trip_report_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildMonthUrl encodes year month and optional admin_code', () {
    final withCode = TripReportRepositoryImpl.buildMonthUrl(
      year: 2026,
      month: 9,
      adminCode: 'ORG1',
    );
    expect(withCode.contains('d2d/trip_report/month/'), isTrue);
    expect(withCode.contains('year=2026'), isTrue);
    expect(withCode.contains('month=9'), isTrue);
    expect(withCode.contains('admin_code=ORG1'), isTrue);

    final noCode = TripReportRepositoryImpl.buildMonthUrl(
      year: 2026,
      month: 9,
      adminCode: '',
    );
    expect(noCode.contains('admin_code='), isFalse);
  });
}
