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

  QuizConfig _config = const QuizConfig();
  QuizConfig get config => _config;

  QuizProvider();
}
