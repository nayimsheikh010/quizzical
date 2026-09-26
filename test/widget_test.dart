import 'package:flutter_test/flutter_test.dart';
import 'package:quizzical/main.dart';

void main() {
  testWidgets('QuizzicalApp launches and shows welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(const QuizzicalApp());
    expect(find.text('Quizzical'), findsOneWidget);
    expect(find.text('GET STARTED'), findsOneWidget);
  });
}
