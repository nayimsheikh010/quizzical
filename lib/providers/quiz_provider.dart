import 'dart:async';
import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/question.dart';
import '../models/quiz_config.dart';
import '../services/api_service.dart';
import '../services/preferences_service.dart';

class QuizProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final PreferencesService _prefsService = PreferencesService();

  String _userName = 'Alex';
  String get userName => _userName;

  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;
  bool _isLoadingCategories = false;
  bool get isLoadingCategories => _isLoadingCategories;
  String? _categoryError;
  String? get categoryError => _categoryError;

  CategoryModel? _selectedCategory;
  CategoryModel? get selectedCategory => _selectedCategory;

  QuizConfig _config = const QuizConfig();
  QuizConfig get config => _config;

  List<QuestionModel> _questions = [];
  List<QuestionModel> get questions => _questions;
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  int _score = 0;
  int get score => _score;
  bool _isQuizLoading = false;
  bool get isQuizLoading => _isQuizLoading;
  String? _quizError;
  String? get quizError => _quizError;

  Future<void> fetchCategories({bool force = false}) async {
    _isLoadingCategories = true;
    _categoryError = null;
    notifyListeners();
    try {
      _categories = await _apiService.getCategories(forceRefresh: force);
      if (_selectedCategory == null && _categories.isNotEmpty) {
        _selectedCategory = _categories.first;
      }
    } catch (e) {
      _categoryError = e.toString();
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  void selectCategory(CategoryModel category) {
    _selectedCategory = category;
    _config = _config.copyWith(categoryId: category.id, categoryName: category.name);
    _prefsService.saveConfig(_config);
    notifyListeners();
  }

  void updateAmount(int amount) {
    _config = _config.copyWith(amount: amount.clamp(1, 50));
    _prefsService.saveConfig(_config);
    notifyListeners();
  }

  void updateDifficulty(String difficulty) {
    _config = _config.copyWith(difficulty: difficulty);
    _prefsService.saveConfig(_config);
    notifyListeners();
  }

  void updateType(String type) {
    _config = _config.copyWith(type: type);
    _prefsService.saveConfig(_config);
    notifyListeners();
  }

  Future<bool> startQuiz() async {
    _isQuizLoading = true;
    _quizError = null;
    _questions = [];
    _currentIndex = 0;
    _score = 0;
    notifyListeners();
    try {
      _questions = await _apiService.getQuestions(_config);
      _isQuizLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isQuizLoading = false;
      _quizError = e.toString();
      notifyListeners();
      return false;
    }
  }

  void resetQuiz() {
    _questions = [];
    _currentIndex = 0;
    _score = 0;
    notifyListeners();
  }
}
