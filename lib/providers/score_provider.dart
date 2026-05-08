import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/discipline_score.dart';
import '../services/discipline_score_service.dart';

class ScoreProvider extends ChangeNotifier {
  static const String _scoreKey = 'discipline_score';

  DisciplineScore _score = DisciplineScore();
  bool _isLoading = false;

  DisciplineScore get score => _score;
  bool get isLoading => _isLoading;

  // Getters for easy access
  int get totalScore => _score.totalScore;
  int get todayScore => _score.todayScore;
  String get rank => DisciplineScoreService.getRank(_score.totalScore);
  int get level => DisciplineScoreService.getLevel(_score.totalScore);
  double get levelProgress => DisciplineScoreService.calculateLevelProgress(_score.totalScore);

  ScoreProvider() {
    loadScore();
  }

  Future<void> loadScore() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final scoreJson = prefs.getString(_scoreKey);

      if (scoreJson != null) {
        _score = DisciplineScore.fromJson(scoreJson);

        // Reset today score if it's a new day
        final now = DateTime.now();
        final lastUpdate = _score.lastUpdated;

        if (lastUpdate != null &&
            (lastUpdate.day != now.day ||
                lastUpdate.month != now.month ||
                lastUpdate.year != now.year)) {
          _score = _score.copyWith(todayScore: 0);
          await _saveScore();
        }
      }
    } catch (e) {
      debugPrint('Error loading score: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scoreWithTime = _score.copyWith(
        lastUpdated: DateTime.now(),
      );
      await prefs.setString(_scoreKey, scoreWithTime.toJson());
    } catch (e) {
      debugPrint('Error saving score: $e');
    }
  }

  // Complete a task
  Future<void> completeTask({required bool isOnTime, required int currentStreak}) async {
    final points = DisciplineScoreService.calculateTaskScore(
      isOnTime: isOnTime,
      currentStreak: currentStreak,
    );


    _score = _score.copyWith(
      totalScore: _score.totalScore + points,
      todayScore: _score.todayScore + points,
      tasksCompleted: _score.tasksCompleted + 1,
    );

    await _saveScore();
    notifyListeners();
  }

  // Miss a task
  Future<void> missTask() async {
    _score = _score.copyWith(
      tasksMissed: _score.tasksMissed + 1,
    );

    await _saveScore();
    notifyListeners();
  }

  // Update streak
  Future<void> updateStreak(int streak, int bestStreak) async {
    _score = _score.copyWith(
      currentStreak: streak,
      bestStreak: bestStreak > _score.bestStreak ? bestStreak : _score.bestStreak,
    );

    await _saveScore();
    notifyListeners();
  }

  // Add daily history
  Future<void> addDailyHistory({
    required int tasksDone,
    required int tasksTotal,
  }) async {
    final dailyScore = DisciplineScoreService.calculateDailyScore(
      tasksCompleted: tasksDone,
      tasksTotal: tasksTotal,
      currentStreak: _score.currentStreak,
      missedTasks: tasksTotal - tasksDone,
    );

    final newEntry = ScoreHistory(
      date: DateTime.now(),
      score: dailyScore,
      tasksDone: tasksDone,
      tasksTotal: tasksTotal,
    );

    final newHistory = List<ScoreHistory>.from(_score.history)..add(newEntry);

    // Keep only last 30 days
    if (newHistory.length > 30) {
      newHistory.removeAt(0);
    }

    _score = _score.copyWith(
      history: newHistory,
      todayScore: 0, // Reset for new day
    );

    await _saveScore();
    notifyListeners();
  }

  // Get daily report
  Map<String, dynamic> getDailyReport() {
    return DisciplineScoreService.generateDailyReport(_score);
  }

  // Reset score
  Future<void> resetScore() async {
    _score = DisciplineScore();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_scoreKey);
    notifyListeners();
  }
}


