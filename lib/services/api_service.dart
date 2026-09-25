import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/question.dart';
import '../models/quiz_config.dart';

class ApiService {
  static const String _baseUrl = 'https://opentdb.com';
  List<CategoryModel>? _cachedCategories;

  Future<List<CategoryModel>> getCategories({bool forceRefresh = false}) async {
    if (_cachedCategories != null && !forceRefresh) {
      return _cachedCategories!;
    }
    final response = await http.get(Uri.parse('$_baseUrl/api_category.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final rawList = data['trivia_categories'] as List<dynamic>? ?? [];
      final categories = <CategoryModel>[];
      for (int i = 0; i < rawList.length; i++) {
        categories.add(CategoryModel.fromJson(rawList[i] as Map<String, dynamic>, i));
      }
      _cachedCategories = categories;
      return categories;
    }
    throw Exception('Failed to load categories');
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
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>? ?? [];
      return results.map((e) => QuestionModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to fetch questions');
  }
}
