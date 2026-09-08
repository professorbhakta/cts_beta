import 'package:cts/features/batches/models/return_trip_log_placeholders.dart';
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
    expect(find.textContaining('RCList'), findsOneWidget);
    expect(find.textContaining('user-ID list'), findsOneWidget);
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

  testWidgets('ReturnBoardingQrPanel shows QR face when viewModel has payload',
      (tester) async {
    const vm = ReturnBoardingQrViewModel(
      tripLog: ReturnTripLogRef(batchId: '1'),
      rclist: RclistRef(batchId: '1'),
      qrPayload: 'test-return-qr-payload',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: ReturnBoardingQrPanel(batchId: '1', viewModel: vm),
        ),
      ),
    );

    expect(find.textContaining('Awaiting Dock'), findsNothing);
  });
}
