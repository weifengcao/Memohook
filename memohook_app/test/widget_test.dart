// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memohook_app/app/app.dart';

void main() {
  testWidgets('Voice capture entry point is available', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MemohookApp());
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('remember or ask'), findsOneWidget);
    final speakButton = find.text('Tap to Speak');
    final loadingButton = find.text('Loading…');
    expect(
      speakButton.evaluate().isNotEmpty || loadingButton.evaluate().isNotEmpty,
      isTrue,
      reason:
          'Expected microphone button to show either speak prompt or loading state.',
    );
    expect(find.byIcon(Icons.mic), findsOneWidget);
  });
}
