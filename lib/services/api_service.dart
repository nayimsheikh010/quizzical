import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/question.dart';
import '../models/quiz_config.dart';

class ApiService {
  static const String _baseUrl = 'https://opentdb.com';

  // In-memory cache for session as required:
  // "Categories load once and are cached during session."
  List<CategoryModel>? _cachedCategories;

  Future<List<CategoryModel>> getCategories({bool forceRefresh = false}) async {
    if (_cachedCategories != null && !forceRefresh) {
      return _cachedCategories!;
    }

    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api_category.php'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final rawList = data['trivia_categories'] as List<dynamic>? ?? [];
        final categories = <CategoryModel>[];
        for (int i = 0; i < rawList.length; i++) {
          categories.add(CategoryModel.fromJson(rawList[i] as Map<String, dynamic>, i));
        }
        _cachedCategories = categories;
        return categories;
      } else {
        throw Exception('Failed to load categories (Status ${response.statusCode})');
      }
    } catch (e) {
      // If network fails and we have no cache, return default fallback categories
      if (_cachedCategories != null) return _cachedCategories!;
      return _getFallbackCategories();
    }
  }

  Future<List<QuestionModel>> getQuestions(QuizConfig config) async {
    final queryParams = <String, String>{
      'amount': config.amount.toString(),
    };

    if (config.categoryId != null && config.categoryId! > 0) {
      queryParams['category'] = config.categoryId.toString();
    }

    if (config.difficulty != 'any') {
      queryParams['difficulty'] = config.difficulty.toLowerCase();
    }

    if (config.type != 'any') {
      queryParams['type'] = config.type.toLowerCase();
    }

    final uri = Uri.parse('$_baseUrl/api.php').replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final responseCode = data['response_code'] as int? ?? 0;

        if (responseCode == 0) {
          final results = data['results'] as List<dynamic>? ?? [];
          return results.map((e) => QuestionModel.fromJson(e as Map<String, dynamic>)).toList();
        } else if (responseCode == 1) {
          // Code 1: Not enough questions for this specific combination.
          // Retry with loosened parameters (e.g. without difficulty)
          if (config.difficulty != 'any') {
            final fallbackConfig = config.copyWith(difficulty: 'any');
            return await getQuestions(fallbackConfig);
          }
          throw Exception('No questions available for this category and amount. Please choose fewer questions.');
        } else if (responseCode == 5) {
          throw Exception('Rate limited. Please wait a few seconds and try again.');
        } else {
          throw Exception('Could not fetch questions (Code $responseCode).');
        }
      } else {
        throw Exception('Network error: ${response.statusCode}');
      }
    } catch (e) {
      // In case OpenTDB fails or is unreachable, use robust fallback trivia questions
      return _getFallbackQuestions(config);
    }
  }

  List<CategoryModel> _getFallbackCategories() {
    final fallbackList = [
      {'id': 9, 'name': 'General Knowledge'},
      {'id': 10, 'name': 'Entertainment: Books'},
      {'id': 11, 'name': 'Entertainment: Film'},
      {'id': 12, 'name': 'Entertainment: Music'},
      {'id': 14, 'name': 'Entertainment: Television'},
      {'id': 15, 'name': 'Entertainment: Video Games'},
      {'id': 17, 'name': 'Science & Nature'},
      {'id': 18, 'name': 'Science: Computers'},
      {'id': 19, 'name': 'Science: Mathematics'},
      {'id': 21, 'name': 'Sports'},
      {'id': 22, 'name': 'Geography'},
      {'id': 23, 'name': 'History'},
      {'id': 27, 'name': 'Animals'},
      {'id': 28, 'name': 'Vehicles'},
    ];
    final list = <CategoryModel>[];
    for (int i = 0; i < fallbackList.length; i++) {
      list.add(CategoryModel.fromJson(fallbackList[i], i));
    }
    _cachedCategories = list;
    return list;
  }

  List<QuestionModel> _getFallbackQuestions(QuizConfig config) {
    final rawList = [
      {
        'type': 'multiple',
        'difficulty': 'easy',
        'category': 'General Knowledge',
        'question': 'In what year did the United States host the FIFA World Cup for the first time?',
        'correct_answer': '1994',
        'incorrect_answers': ['1986', '2000', '2007']
      },
      {
        'type': 'multiple',
        'difficulty': 'easy',
        'category': 'General Knowledge',
        'question': 'How many colors are there in a rainbow?',
        'correct_answer': '7',
        'incorrect_answers': ['6', '8', '9']
      },
      {
        'type': 'boolean',
        'difficulty': 'easy',
        'category': 'General Knowledge',
        'question': 'When you cry in space, your tears stick to your face.',
        'correct_answer': 'True',
        'incorrect_answers': ['False']
      },
      {
        'type': 'multiple',
        'difficulty': 'medium',
        'category': 'General Knowledge',
        'question': 'Which planet is known as the Red Planet?',
        'correct_answer': 'Mars',
        'incorrect_answers': ['Jupiter', 'Venus', 'Saturn']
      },
      {
        'type': 'multiple',
        'difficulty': 'easy',
        'category': 'General Knowledge',
        'question': 'What is the largest ocean on Earth?',
        'correct_answer': 'Pacific Ocean',
        'incorrect_answers': ['Atlantic Ocean', 'Indian Ocean', 'Arctic Ocean']
      },
      {
        'type': 'multiple',
        'difficulty': 'medium',
        'category': 'General Knowledge',
        'question': 'Who painted the Mona Lisa?',
        'correct_answer': 'Leonardo da Vinci',
        'incorrect_answers': ['Vincent van Gogh', 'Pablo Picasso', 'Claude Monet']
      },
      {
        'type': 'boolean',
        'difficulty': 'easy',
        'category': 'General Knowledge',
        'question': 'The Great Wall of China is visible from the Moon with the naked eye.',
        'correct_answer': 'False',
        'incorrect_answers': ['True']
      },
      {
        'type': 'multiple',
        'difficulty': 'easy',
        'category': 'General Knowledge',
        'question': 'What chemical element has the symbol O?',
        'correct_answer': 'Oxygen',
        'incorrect_answers': ['Osmium', 'Gold', 'Ozone']
      },
      {
        'type': 'multiple',
        'difficulty': 'medium',
        'category': 'General Knowledge',
        'question': 'Which country won the FIFA World Cup in 2022?',
        'correct_answer': 'Argentina',
        'incorrect_answers': ['France', 'Brazil', 'Croatia']
      },
      {
        'type': 'multiple',
        'difficulty': 'easy',
        'category': 'General Knowledge',
        'question': 'What is the capital city of France?',
        'correct_answer': 'Paris',
        'incorrect_answers': ['Rome', 'Berlin', 'Madrid']
      },
    ];

    var filtered = rawList;
    if (config.type != 'any') {
      filtered = rawList.where((q) => q['type'] == config.type).toList();
      if (filtered.isEmpty) filtered = rawList;
    }

    final questions = filtered
        .map((e) => QuestionModel.fromJson(e))
        .take(config.amount)
        .toList();

    return questions.isNotEmpty ? questions : rawList.map((e) => QuestionModel.fromJson(e)).toList();
  }
}
