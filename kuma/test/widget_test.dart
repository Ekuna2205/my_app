// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap
// and scroll gestures. You can also use WidgetTester to find child
// widgets in the widget tree, read text, and verify that the values of
// widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/main.dart'; // ЭНД ТӨСЛИЙН НЭРЭЭ ЗӨВ БИЧНЭ ҮҮ!
// Жишээ: хэрвээ таны pubspec.yaml-д name: quiz_master гэж байвал package:quiz_master/main.dart

void main() {
  testWidgets('QuizMasterApp starts and shows home screen', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const QuizMasterApp());

    // Verify that the app title "QuizMaster" is shown in the AppBar
    expect(find.text('QuizMaster'), findsOneWidget);

    // Verify that some category cards are visible (example: "Түүх")
    expect(find.text('Түүх'), findsOneWidget);

    // Verify that score and streak cards are present
    expect(find.text('Нийт оноо'), findsOneWidget);
    expect(find.text('Streak 🔥'), findsOneWidget);

    // Optional: Check if the floating action button (+) exists
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Theme toggle button exists', (WidgetTester tester) async {
    await tester.pumpWidget(const QuizMasterApp());

    // AppBar дээрх theme toggle icon (dark/light mode) байгаа эсэхийг шалгана
    final themeButton = find.byIcon(Icons.dark_mode).hitTestable();
    final themeButtonLight = find.byIcon(Icons.light_mode).hitTestable();

    // Аль нэг нь байвал зүгээр (эхэндээ light mode байж болно)
    expect(themeButton.or(themeButtonLight), findsOneWidget);
  });
}
