import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cts/theme/app_theme.dart';

void main() {
  testWidgets('AppTheme light MaterialApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: Center(child: Text('CTS')),
        ),
      ),
    );

    expect(find.text('CTS'), findsOneWidget);
  });
}
