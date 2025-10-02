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
    await tester.pumpAndSettle();

    expect(find.textContaining('remember or ask'), findsOneWidget);
    expect(find.text('Tap to Speak'), findsOneWidget);
    expect(find.byIcon(Icons.mic), findsOneWidget);
  });
}
