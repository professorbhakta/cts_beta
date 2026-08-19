import 'package:cts/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

Future<void> _login(
  WidgetTester tester, {
  required String mobile,
  required String password,
}) async {
  await tester.pumpAndSettle(const Duration(seconds: 15));

  expect(find.text('Welcome Back'), findsOneWidget);

  final fields = find.byType(TextFormField);
  expect(fields, findsAtLeast(2));

  await tester.enterText(fields.at(0), mobile);
  await tester.enterText(fields.at(1), password);
  await tester.pumpAndSettle();

  await tester.tap(find.text('LOGIN'));
  await tester.pumpAndSettle(const Duration(seconds: 20));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('admin login reaches dashboard on device', (tester) async {
    app.main();
    await _login(
      tester,
      mobile: '7069036462',
      password: 'password',
    );
    expect(find.text('Dashboard'), findsOneWidget);
  });

  testWidgets('driver login reaches driver home on device', (tester) async {
    app.main();
    await _login(
      tester,
      mobile: '9876544111',
      password: 'password',
    );
    expect(find.textContaining('Good'), findsOneWidget);
    expect(find.textContaining('assignment'), findsOneWidget);
  });
}
