import 'package:html_unescape/html_unescape.dart';

class QuestionModel {
  final String category;
  final String type;
  final String difficulty;
  final String question;
  final String correctAnswer;
  final List<String> incorrectAnswers;
  final List<String> allAnswers;

  int? selectedAnswerIndex;
  bool isAnswered;
  bool isTimedOut;

  QuestionModel({
    required this.category,
    required this.type,
    required this.difficulty,
    required this.question,
    required this.correctAnswer,
    required this.incorrectAnswers,
    required this.allAnswers,
    this.selectedAnswerIndex,
    this.isAnswered = false,
    this.isTimedOut = false,
  });

  bool get isCorrect {
    if (selectedAnswerIndex == null || selectedAnswerIndex! < 0 || selectedAnswerIndex! >= allAnswers.length) {
      return false;
    }
    return allAnswers[selectedAnswerIndex!] == correctAnswer;
  }

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final unescape = HtmlUnescape();

    final category = unescape.convert(json['category'] as String? ?? '');
    final type = json['type'] as String? ?? 'multiple';
    final difficulty = json['difficulty'] as String? ?? 'easy';
    final question = unescape.convert(json['question'] as String? ?? '');
    final correctAnswer = unescape.convert(json['correct_answer'] as String? ?? '');

    final rawIncorrect = (json['incorrect_answers'] as List<dynamic>? ?? []);
    final incorrectAnswers = rawIncorrect
        .map((e) => unescape.convert(e.toString()))
        .toList();

    final allAnswers = <String>[correctAnswer, ...incorrectAnswers];

    if (type == 'boolean') {
      // Standardize True / False order
      allAnswers.sort((a, b) => b.compareTo(a)); // "True", "False"
    } else {
      allAnswers.shuffle();
    }

    return QuestionModel(
      category: category,
      type: type,
      difficulty: difficulty,
      question: question,
      correctAnswer: correctAnswer,
      incorrectAnswers: incorrectAnswers,
      allAnswers: allAnswers,
    );
  }
}
