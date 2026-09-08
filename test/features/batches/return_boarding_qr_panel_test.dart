import 'package:cts/features/batches/widgets/return_boarding_qr_panel.dart';
import 'package:cts/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ReturnBoardingQrPanel stub shows await-Dock chrome by default',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: ReturnBoardingQrPanel(batchId: '1'),
        ),
      ),
    );

    expect(find.textContaining('Awaiting Dock'), findsOneWidget);
    expect(find.textContaining('BoardingQrPanel'), findsOneWidget);
    // Stub must not mount live morning panel network chrome title alone.
    expect(find.text('Refreshes in'), findsNothing);
  });

  testWidgets('ReturnBoardingQrPanel disabled renders nothing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: ReturnBoardingQrPanel(batchId: '1', enabled: false),
        ),
      ),
    );

    expect(find.byType(SizedBox), findsWidgets);
    expect(find.textContaining('Awaiting Dock'), findsNothing);
  });
}
