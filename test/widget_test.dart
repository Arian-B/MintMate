import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/main.dart';

void main() {
  testWidgets('Splash Screen navigates to Login Screen',
      (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the Splash Screen is shown.
    expect(find.text('MintMate'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for 3 seconds to allow the splash screen to complete its timer.
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify that the Login Screen is displayed.
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
