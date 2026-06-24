import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_bio/main.dart';

void main() {
  testWidgets('App smoke test - language select is shown initially', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp(
      hasUserData: false,
      seenOnboarding: false,
      isDarkMode: true,
      languageCode: 'vi',
      languageChosen: false,
    ));

    // Verify that the initial screen contains language choice options.
    expect(find.textContaining('Choose language'), findsOneWidget);
    expect(find.text('Tiếng Việt'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
  });
}
