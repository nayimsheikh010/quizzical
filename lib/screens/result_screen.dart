import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_theme.dart';
import 'category_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    }
    final mins = seconds ~/ 60;
    final remSecs = seconds % 60;
    return '${mins}m ${remSecs}s';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuizProvider>();
    final accuracyPercent = provider.accuracy.round();
    final isSuccess = accuracyPercent >= 60;

    final title = isSuccess ? 'Congratulation' : 'Keep Trying!';
    final message = isSuccess
        ? "You've got a great foundation. Ready to try a different category?"
        : "Dont give up!Practice makes perfect. Try again to improveyour score";

    final illustrationAsset = isSuccess
        ? 'assets/images/congrats_illustration.png'
        : 'assets/images/try_again_illustration.png';

    final badgeColor = isSuccess ? const Color(0xFF6EE7B7) : const Color(0xFFFF5722);
    final badgeGlowColor = isSuccess
        ? const Color(0xFF6EE7B7).withValues(alpha: 0.3)
        : const Color(0xFFFF5722).withValues(alpha: 0.25);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 10),

                  // Center Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),
                          // Illustration
                          Image.asset(
                            illustrationAsset,
                            height: 220,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              isSuccess ? Icons.emoji_events_rounded : Icons.replay_rounded,
                              size: 100,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Title
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2B2D42),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Score Badge (e.g. 80% or 33%)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: badgeGlowColor,
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              '$accuracyPercent%',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Motivational Message
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2B2D42),
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Quick Stats Card: Score, Accuracy, Time
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  icon: Icons.check_circle_outline_rounded,
                                  label: 'Score',
                                  value: '${provider.score}/${provider.totalQuestions}',
                                  color: AppTheme.primaryTeal,
                                ),
                                Container(width: 1, height: 36, color: const Color(0xFFE5E7EB)),
                                _buildStatItem(
                                  icon: Icons.pie_chart_outline_rounded,
                                  label: 'Accuracy',
                                  value: '$accuracyPercent%',
                                  color: const Color(0xFF2563EB),
                                ),
                                Container(width: 1, height: 36, color: const Color(0xFFE5E7EB)),
                                _buildStatItem(
                                  icon: Icons.timer_outlined,
                                  label: 'Time',
                                  value: _formatDuration(provider.totalTimeSpentSeconds),
                                  color: const Color(0xFFF59E0B),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Play Again Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0, top: 12.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryTeal,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        provider.resetQuiz();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const CategoryScreen()),
                          (route) => route.isFirst,
                        );
                      },
                      child: const Text(
                        'PLAY AGAIN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
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
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2B2D42),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF71758B),
          ),
        ),
      ],
    );
  }
}
