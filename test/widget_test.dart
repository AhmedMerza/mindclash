import 'package:flutter_test/flutter_test.dart';
import 'package:mindclash/main.dart';

void main() {
  testWidgets('app renders MindClash text', (tester) async {
    await tester.pumpWidget(const MindClashApp());

    expect(find.text('MindClash'), findsOneWidget);
  });
}
