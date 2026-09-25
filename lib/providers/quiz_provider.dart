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

  // User State
  String _userName = 'Alex';
  String get userName => _userName;

  // Category State
  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;
  bool _isLoadingCategories = false;
  bool get isLoadingCategories => _isLoadingCategories;
  String? _categoryError;
  String? get categoryError => _categoryError;

  // Selected Category & Configuration
  CategoryModel? _selectedCategory;
  CategoryModel? get selectedCategory => _selectedCategory;

  QuizConfig _config = const QuizConfig();
  QuizConfig get config => _config;

  // Quiz Game State
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

  // Timer & Stats
  static const int questionDuration = 20; // 20s per question
  int _remainingSeconds = questionDuration;
  int get remainingSeconds => _remainingSeconds;
  Timer? _timer;
  final Stopwatch _totalStopwatch = Stopwatch();
  int _totalTimeSpentSeconds = 0;
  int get totalTimeSpentSeconds => _totalTimeSpentSeconds;

  bool _isAnswerSubmitted = false;
  bool get isAnswerSubmitted => _isAnswerSubmitted;
  int? _selectedAnswerIndex;
  int? get selectedAnswerIndex => _selectedAnswerIndex;

  QuestionModel? get currentQuestion =>
      (_questions.isNotEmpty && _currentIndex < _questions.length)
          ? _questions[_currentIndex]
          : null;

  double get progress => _questions.isEmpty
      ? 0.0
      : (_currentIndex + (_isAnswerSubmitted ? 1 : 0)) / _questions.length;

  int get totalQuestions => _questions.length;

  double get accuracy =>
      _questions.isEmpty ? 0.0 : (_score / _questions.length) * 100.0;

  bool get isQuizFinished =>
      _questions.isNotEmpty && _currentIndex >= _questions.length;

  QuizProvider() {
    _init();
  }

  Future<void> _init() async {
    _userName = await _prefsService.loadUserName();
    final savedConfig = await _prefsService.loadConfig();
    if (savedConfig != null) {
      _config = savedConfig;
    }
    notifyListeners();
    fetchCategories();
  }

  void setUserName(String name) {
    _userName = name.trim().isEmpty ? 'Alex' : name.trim();
    _prefsService.saveUserName(_userName);
    notifyListeners();
  }

  // --- Categories ---
  Future<void> fetchCategories({bool force = false}) async {
    _isLoadingCategories = true;
    _categoryError = null;
    notifyListeners();

    try {
      _categories = await _apiService.getCategories(forceRefresh: force);
      if (_selectedCategory == null && _categories.isNotEmpty) {
        // Match saved config category or default to first
        final found = _categories.firstWhere(
          (c) => c.id == _config.categoryId,
          orElse: () => _categories.first,
        );
        _selectedCategory = found;
        _config = _config.copyWith(
          categoryId: found.id,
          categoryName: found.name,
        );
      }
    } catch (e) {
      _categoryError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  void selectCategory(CategoryModel category) {
    _selectedCategory = category;
    _config = _config.copyWith(
      categoryId: category.id,
      categoryName: category.name,
    );
    _prefsService.saveConfig(_config);
    notifyListeners();
  }

  // --- Configuration ---
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

  // --- Quiz Session ---
  Future<bool> startQuiz() async {
    _cancelTimer();
    _isQuizLoading = true;
    _quizError = null;
    _questions = [];
    _currentIndex = 0;
    _score = 0;
    _isAnswerSubmitted = false;
    _selectedAnswerIndex = null;
    _totalTimeSpentSeconds = 0;
    notifyListeners();

    try {
      final fetched = await _apiService.getQuestions(_config);
      if (fetched.isEmpty) {
        throw Exception('No questions returned. Please adjust configuration.');
      }
      _questions = fetched;
      _isQuizLoading = false;
      _totalStopwatch.reset();
      _totalStopwatch.start();
      _startQuestionTimer();
      notifyListeners();
      return true;
    } catch (e) {
      _isQuizLoading = false;
      _quizError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void _startQuestionTimer() {
    _cancelTimer();
    _remainingSeconds = questionDuration;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 1) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _remainingSeconds = 0;
        _handleTimeout();
      }
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _handleTimeout() {
    _cancelTimer();
    if (_isAnswerSubmitted || currentQuestion == null) return;

    _isAnswerSubmitted = true;
    currentQuestion!.isAnswered = true;
    currentQuestion!.isTimedOut = true;
    currentQuestion!.selectedAnswerIndex = -1; // Unanswered
    notifyListeners();

    // Auto-advance after 1.5 seconds on timeout
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (_isAnswerSubmitted && currentQuestion?.isTimedOut == true) {
        nextQuestion();
      }
    });
  }

  void selectAnswer(int index) {
    if (_isAnswerSubmitted || currentQuestion == null) return;

    _cancelTimer();
    _selectedAnswerIndex = index;
    _isAnswerSubmitted = true;

    currentQuestion!.isAnswered = true;
    currentQuestion!.selectedAnswerIndex = index;

    if (currentQuestion!.isCorrect) {
      _score++;
    }

    notifyListeners();
  }

  bool nextQuestion() {
    _cancelTimer();

    if (_currentIndex + 1 < _questions.length) {
      _currentIndex++;
      _isAnswerSubmitted = false;
      _selectedAnswerIndex = null;
      _startQuestionTimer();
      notifyListeners();
      return true; // Continues
    } else {
      // Quiz Finished!
      _totalStopwatch.stop();
      _totalTimeSpentSeconds = _totalStopwatch.elapsed.inSeconds;
      _currentIndex = _questions.length;
      _prefsService.saveLastResult(_score, _questions.length);
      notifyListeners();
      return false; // Finished
    }
  }

  void setDemoScore({required int score, required int total, int timeSeconds = 45}) {
    _score = score;
    _totalTimeSpentSeconds = timeSeconds;
    if (_questions.isEmpty || _questions.length != total) {
      _questions = List.generate(
        total,
        (i) => QuestionModel(
          category: 'General Knowledge',
          type: 'multiple',
          difficulty: 'easy',
          question: 'Sample Question',
          correctAnswer: 'A',
          incorrectAnswers: ['B', 'C', 'D'],
          allAnswers: ['A', 'B', 'C', 'D'],
        ),
      );
    }
    notifyListeners();
  }

  void setupDemoQuestion({required bool isCorrect}) {
    _cancelTimer();
    final q = QuestionModel(
      category: 'General Knowledge',
      type: 'multiple',
      difficulty: 'easy',
      question: 'In what year did the United States host the FIFA World Cup for the first time?',
      correctAnswer: '1994',
      incorrectAnswers: ['1986', '2000', '2007'],
      allAnswers: ['1986', '1994', '2000', '2007'],
    );
    _questions = List.generate(10, (i) => i == 6 ? q : QuestionModel(
      category: 'General Knowledge',
      type: 'multiple',
      difficulty: 'easy',
      question: 'Sample Question ${i+1}',
      correctAnswer: 'A',
      incorrectAnswers: ['B', 'C', 'D'],
      allAnswers: ['A', 'B', 'C', 'D'],
    ));
    _currentIndex = 6; // 7/10
    _remainingSeconds = 18;
    if (isCorrect) {
      q.selectedAnswerIndex = 1; // '1994'
      q.isAnswered = true;
      _isAnswerSubmitted = true;
      _selectedAnswerIndex = 1;
      _score = 7;
    } else {
      q.selectedAnswerIndex = 0; // '1986'
      q.isAnswered = true;
      _isAnswerSubmitted = true;
      _selectedAnswerIndex = 0;
      _score = 6;
    }
    notifyListeners();
  }

  void resetQuiz() {
    _cancelTimer();
    _totalStopwatch.reset();
    _questions = [];
    _currentIndex = 0;
    _score = 0;
    _isAnswerSubmitted = false;
    _selectedAnswerIndex = null;
    _quizError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelTimer();
    _totalStopwatch.stop();
    super.dispose();
  }
}
