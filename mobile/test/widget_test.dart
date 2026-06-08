import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('VoiceFlow App UI render test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VoiceFlowApp());

    // Verify that the AppBar title is displayed
    expect(find.text('VoiceFlow AI'), findsOneWidget);

    // Verify that the microphone card is present
    expect(find.byKey(const Key('record_card')), findsOneWidget);

    // Verify that the initial empty state message is present
    expect(find.text("No candidate profiles processed yet"), findsOneWidget);
  });
}
