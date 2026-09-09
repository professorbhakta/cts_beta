import 'package:cts/api/api_list.dart';
import 'package:cts/features/batches/widgets/return_boarding_qr_panel.dart';
import 'package:cts/features/d2d/widgets/boarding_qr_panel.dart';
import 'package:cts/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ReturnBoardingQrPanel wraps BoardingQrPanel with trip=return',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: ReturnBoardingQrPanel(batchId: '7', enabled: false),
        ),
      ),
    );

    final panel = tester.widget<BoardingQrPanel>(find.byType(BoardingQrPanel));
    expect(panel.batchId, '7');
    expect(panel.trip, ApiUrl.boardingTripReturn);
    expect(panel.compact, isTrue);
  });

  test('ApiUrl.boardingQr appends trip=return query', () {
    expect(
      ApiUrl.boardingQr('12', trip: ApiUrl.boardingTripReturn),
      'd2d/boarding_qr/12/?trip=return',
    );
    expect(ApiUrl.boardingQr('12'), 'd2d/boarding_qr/12/');
    expect(
      ApiUrl.boardingQr('12', trip: ApiUrl.boardingTripMorning),
      'd2d/boarding_qr/12/?trip=morning',
    );
  });
}
