import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/question.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_theme.dart';
import 'result_screen.dart';

class QuizPlayScreen extends StatefulWidget {
  const QuizPlayScreen({super.key});

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<QuizProvider>();
      if (provider.questions.isEmpty && !provider.isQuizLoading) {
        provider.startQuiz();
      }
    });
  }

  void _confirmExit(BuildContext context, QuizProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Exit Quiz?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to exit? Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Stay', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              provider.resetQuiz();
              Navigator.pop(context);
            },
            child: const Text('Exit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuizProvider>();
    final currentQ = provider.currentQuestion;

    if (provider.isQuizLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.primaryTeal),
              SizedBox(height: 16),
              Text(
                'Loading questions...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5B5F77),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (currentQ == null || provider.questions.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No questions loaded.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      );
    }

    final currentIndexDisplay = provider.currentIndex + 1;
    final totalCount = provider.totalQuestions;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _confirmExit(context, provider);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Timer Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: provider.remainingSeconds <= 5
                      ? Colors.red.shade50
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: provider.remainingSeconds <= 5
                        ? Colors.red.shade300
                        : Colors.blue.shade200,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: provider.remainingSeconds <= 5
                          ? Colors.red.shade700
                          : Colors.blue.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${provider.remainingSeconds}s',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: provider.remainingSeconds <= 5
                            ? Colors.red.shade700
                            : Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              // Progress Indicator: e.g. "7/10"
              Text(
                '$currentIndexDisplay/$totalCount',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2B2D42),
                ),
              ),

              // EXIT button
              InkWell(
                onTap: () => _confirmExit(context, provider),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'EXIT',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2B2D42),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.logout_rounded, size: 18, color: Color(0xFF2B2D42)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(6.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: provider.progress,
                minHeight: 4,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  children: [
                    // Question Card
                    Expanded(
                      flex: 4,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: SingleChildScrollView(
                            child: Text(
                              currentQ.question,
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2B2D42),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Options List
                    Expanded(
                      flex: 6,
                      child: ListView.separated(
                        itemCount: currentQ.allAnswers.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final optionText = currentQ.allAnswers[index];
                          return _buildOptionTile(
                            context,
                            provider,
                            currentQ,
                            optionText,
                            index,
                          );
                        },
                      ),
                    ),

                    // Next / Finish Button
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: provider.isAnswerSubmitted
                              ? AppTheme.primaryTeal
                              : AppTheme.primaryTeal.withValues(alpha: 0.4),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: provider.isAnswerSubmitted
                            ? () {
                                final hasMore = provider.nextQuestion();
                                if (!hasMore) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ResultScreen(),
                                    ),
                                  );
                                }
                              }
                            : null,
                        child: Text(
                          currentIndexDisplay == totalCount ? 'FINISH' : 'Next',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context,
    QuizProvider provider,
    QuestionModel q,
    String optionText,
    int index,
  ) {
    final isSubmitted = provider.isAnswerSubmitted;
    final isSelected = provider.selectedAnswerIndex == index;
    final isCorrectOption = optionText == q.correctAnswer;

    Color bgColor = const Color(0xFFF8F9FA);
    Color borderColor = const Color(0xFFE5E7EB);
    Color textColor = const Color(0xFF2B2D42);
    Widget iconWidget = const Icon(
      Icons.radio_button_unchecked_rounded,
      color: Color(0xFF9CA3AF),
      size: 22,
    );

    if (isSubmitted) {
      if (isCorrectOption) {
        // Correct option: Green
        bgColor = const Color(0xFFA7D7C5);
        borderColor = const Color(0xFF2E7D5B);
        textColor = const Color(0xFF134E3A);
        iconWidget = const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF005954),
          size: 24,
        );
      } else if (isSelected && !isCorrectOption) {
        // User selected this and it's wrong: Red
        bgColor = const Color(0xFFF8A5A5);
        borderColor = const Color(0xFFD32F2F);
        textColor = const Color(0xFF7F1D1D);
        iconWidget = const Icon(
          Icons.cancel_rounded,
          color: Color(0xFFD32F2F),
          size: 24,
        );
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isSubmitted ? null : () => provider.selectAnswer(index),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              if (isSelected || (isSubmitted && isCorrectOption))
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  optionText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              iconWidget,
            ],
          ),
        ),
      ),
    );
  }
}
