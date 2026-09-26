import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_theme.dart';
import 'quiz_play_screen.dart';

class QuizConfigScreen extends StatelessWidget {
  const QuizConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuizProvider>();
    final config = provider.config;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Top Illustration
                          Image.asset(
                            'assets/images/config_illustration.png',
                            height: 180,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.tune_rounded, size: 100, color: AppTheme.primaryTeal),
                          ),
                          const SizedBox(height: 16),

                          // Titles
                          const Text(
                            'Quizzical',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2B2D42),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Configuration',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5B5F77),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            config.categoryName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF5B5F77),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Number of Questions
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Number of Questions',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2B2D42),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Select 1–50',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF71758B),
                                    ),
                                  ),
                                  Text(
                                    '${config.amount}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                ],
                              ),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: const Color(0xFF2563EB),
                                  inactiveTrackColor: const Color(0xFFE2E8F0),
                                  thumbColor: const Color(0xFF2563EB),
                                  overlayColor: const Color(0xFF2563EB).withValues(alpha: 0.12),
                                  trackHeight: 4,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
                                ),
                                child: Slider(
                                  value: config.amount.toDouble(),
                                  min: 1,
                                  max: 50,
                                  divisions: 49,
                                  onChanged: (val) {
                                    provider.updateAmount(val.round());
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Difficulty Level Dropdown
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Difficulty Level',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2B2D42),
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildDropdown<String>(
                                value: config.difficulty,
                                items: const [
                                  DropdownMenuItem(value: 'any', child: Text('Any Difficulty')),
                                  DropdownMenuItem(value: 'easy', child: Text('Easy')),
                                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                                  DropdownMenuItem(value: 'hard', child: Text('Hard')),
                                ],
                                onChanged: (val) {
                                  if (val != null) provider.updateDifficulty(val);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Question Type Dropdown
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Question Type',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2B2D42),
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildDropdown<String>(
                                value: config.type,
                                items: const [
                                  DropdownMenuItem(value: 'multiple', child: Text('Multiple Choice')),
                                  DropdownMenuItem(value: 'boolean', child: Text('True / False')),
                                  DropdownMenuItem(value: 'any', child: Text('Any Type')),
                                ],
                                onChanged: (val) {
                                  if (val != null) provider.updateType(val);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Action Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0, top: 12.0),
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
                      onPressed: provider.isQuizLoading
                          ? null
                          : () async {
                              final success = await provider.startQuiz();
                              if (context.mounted) {
                                if (success) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const QuizPlayScreen()),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        provider.quizError ?? 'Failed to load questions. Please try again.',
                                      ),
                                      backgroundColor: Colors.red.shade700,
                                      action: SnackBarAction(
                                        label: 'Retry',
                                        textColor: Colors.white,
                                        onPressed: () => provider.startQuiz(),
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                      child: provider.isQuizLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text(
                              'START',
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

  Widget _buildDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF6B7280)),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2B2D42),
          ),
        ),
      ),
    );
  }
}
