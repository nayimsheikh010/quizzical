import 'dart:convert';

class QuizConfig {
  final int? categoryId;
  final String categoryName;
  final int amount;
  final String difficulty; // 'any', 'easy', 'medium', 'hard'
  final String type; // 'any', 'multiple', 'boolean'

  const QuizConfig({
    this.categoryId = 9,
    this.categoryName = 'General Knowledge',
    this.amount = 10,
    this.difficulty = 'any',
    this.type = 'multiple',
  });

  QuizConfig copyWith({
    int? categoryId,
    String? categoryName,
    int? amount,
    String? difficulty,
    String? type,
  }) {
    return QuizConfig(
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      amount: amount ?? this.amount,
      difficulty: difficulty ?? this.difficulty,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'amount': amount,
      'difficulty': difficulty,
      'type': type,
    };
  }

  factory QuizConfig.fromMap(Map<String, dynamic> map) {
    return QuizConfig(
      categoryId: map['categoryId'] as int? ?? 9,
      categoryName: map['categoryName'] as String? ?? 'General Knowledge',
      amount: map['amount'] as int? ?? 10,
      difficulty: map['difficulty'] as String? ?? 'any',
      type: map['type'] as String? ?? 'multiple',
    );
  }

  String toJson() => json.encode(toMap());

  factory QuizConfig.fromJson(String source) =>
      QuizConfig.fromMap(json.decode(source) as Map<String, dynamic>);
}
