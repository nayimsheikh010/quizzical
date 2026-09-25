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
}
