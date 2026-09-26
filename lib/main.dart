import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/quiz_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/category_screen.dart';
import 'screens/quiz_config_screen.dart';
import 'screens/quiz_play_screen.dart';
import 'screens/result_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QuizzicalApp());
}

class QuizzicalApp extends StatelessWidget {
  final String? initialRoute;
  const QuizzicalApp({super.key, this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QuizProvider(),
      child: MaterialApp(
        title: 'Quizzical',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: initialRoute ?? '/',
        routes: {
          '/': (_) => const WelcomeScreen(),
          '/category': (_) => const CategoryScreen(),
          '/config': (_) => const QuizConfigScreen(),
          '/quiz': (_) => const QuizPlayScreen(),
          '/quiz-correct': (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<QuizProvider>().setupDemoQuestion(isCorrect: true);
            });
            return const QuizPlayScreen();
          },
          '/quiz-incorrect': (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<QuizProvider>().setupDemoQuestion(isCorrect: false);
            });
            return const QuizPlayScreen();
          },
          '/result': (_) => const ResultScreen(),
          '/result-celebrate': (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<QuizProvider>().setDemoScore(score: 8, total: 10, timeSeconds: 45);
            });
            return const ResultScreen();
          },
          '/result-retry': (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<QuizProvider>().setDemoScore(score: 3, total: 9, timeSeconds: 52);
            });
            return const ResultScreen();
          },
        },
      ),
    );
  }
}
