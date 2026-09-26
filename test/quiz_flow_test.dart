import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:quizzical/models/category.dart';
import 'package:quizzical/models/question.dart';
import 'package:quizzical/providers/quiz_provider.dart';
import 'package:quizzical/screens/welcome_screen.dart';
import 'package:quizzical/screens/category_screen.dart';
import 'package:quizzical/screens/quiz_config_screen.dart';
import 'package:quizzical/screens/quiz_play_screen.dart';
import 'package:quizzical/screens/result_screen.dart';

void main() {
  testWidgets('WelcomeScreen renders properly', (WidgetTester tester) async {
    final provider = QuizProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider<QuizProvider>.value(
        value: provider,
        child: const MaterialApp(home: WelcomeScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Quizzical'), findsOneWidget);
    expect(find.text('GET STARTED'), findsOneWidget);
  });

  testWidgets('CategoryScreen renders properly', (WidgetTester tester) async {
    final provider = QuizProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider<QuizProvider>.value(
        value: provider,
        child: const MaterialApp(home: CategoryScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Select Category'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('QuizConfigScreen renders properly', (WidgetTester tester) async {
    final provider = QuizProvider();
    provider.selectCategory(
      CategoryModel(
        id: 9,
        name: 'General Knowledge',
        backgroundColor: Colors.white,
        icon: Icons.lightbulb,
      ),
    );
    await tester.pumpWidget(
      ChangeNotifierProvider<QuizProvider>.value(
        value: provider,
        child: const MaterialApp(home: QuizConfigScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('START'), findsOneWidget);
    expect(find.text('General Knowledge'), findsOneWidget);
  });

  testWidgets('ResultScreen renders with stats and play again', (WidgetTester tester) async {
    final provider = QuizProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider<QuizProvider>.value(
        value: provider,
        child: const MaterialApp(home: ResultScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('PLAY AGAIN'), findsOneWidget);
    expect(find.text('Score'), findsOneWidget);
    expect(find.text('Accuracy'), findsOneWidget);
    expect(find.text('Time'), findsOneWidget);
  });
}
