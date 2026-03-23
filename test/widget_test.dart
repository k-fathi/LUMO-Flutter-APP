// Basic smoke test for LumoAI app.

import 'package:flutter_test/flutter_test.dart';
import 'package:lumo_ai/app.dart';

void main() {
  testWidgets('LumoAIApp smoke test', (WidgetTester tester) async {
    // Verify the app widget can be created.
    await tester.pumpWidget(const LumoAIApp());
  });
}
