import 'package:flutter_test/flutter_test.dart';
import 'package:pantry_quest/main.dart';

void main() {
  testWidgets('App renders placeholder title cards smoke test', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('OOP'), findsOneWidget);
    expect(find.text('JAVA'), findsOneWidget);
    expect(find.text('FLUTTER'), findsOneWidget);
  });
}
