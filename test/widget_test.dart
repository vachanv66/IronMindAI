import 'package:flutter_test/flutter_test.dart';
import 'package:ironmind_ai/main.dart';

void main() {
  testWidgets('IronMindApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const IronMindApp());
    expect(find.textContaining('Train Smarter.'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
