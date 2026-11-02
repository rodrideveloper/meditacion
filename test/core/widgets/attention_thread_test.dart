import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meditation_app/core/widgets/attention_thread.dart';

void main() {
  testWidgets('attention thread is exposed as one labeled visual', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AttentionThread(semanticLabel: 'A line returns')),
      ),
    );
    expect(find.bySemanticsLabel('A line returns'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AttentionThread),
        matching: find.byType(CustomPaint),
      ),
      findsOneWidget,
    );
  });
}
