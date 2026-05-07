import 'dart:convert';

class DisciplineScore {
  final int totalScore;
  final int todayScore;
  final int tasksCompleted;
  final int tasksMissed;
  final int currentStreak;
  final int bestStreak;
  final List<ScoreHistory> history;
  final DateTime? lastUpdated;

  DisciplineScore({
    this.totalScore = 0,
    this.todayScore = 0,
    this.tasksCompleted = 0,
    this.tasksMissed = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.history = const [],
    this.lastUpdated,  // <-- nullable, no required
  });

  DisciplineScore copyWith({
    int? totalScore,
    int? todayScore,
    int? tasksCompleted,
    int? tasksMissed,
    int? currentStreak,
    int? bestStreak,
    List<ScoreHistory>? history,
    DateTime? lastUpdated,
  }) {
    return DisciplineScore(
      totalScore: totalScore ?? this.totalScore,
      todayScore: todayScore ?? this.todayScore,
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      tasksMissed: tasksMissed ?? this.tasksMissed,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      history: history ?? this.history,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalScore': totalScore,
      'todayScore': todayScore,
      'tasksCompleted': tasksCompleted,
      'tasksMissed': tasksMissed,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'history': history.map((h) => h.toMap()).toList(),
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory DisciplineScore.fromMap(Map<String, dynamic> map) {
    return DisciplineScore(
      totalScore: map['totalScore'] ?? 0,
      todayScore: map['todayScore'] ?? 0,
      tasksCompleted: map['tasksCompleted'] ?? 0,
      tasksMissed: map['tasksMissed'] ?? 0,
      currentStreak: map['currentStreak'] ?? 0,
      bestStreak: map['bestStreak'] ?? 0,
      history: map['history'] != null
          ? List<ScoreHistory>.from(
          map['history'].map((x) => ScoreHistory.fromMap(x)))
          : [],
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'])
          : null,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory DisciplineScore.fromJson(String source) =>
      DisciplineScore.fromMap(jsonDecode(source));
}

class ScoreHistory {
  final DateTime date;
  final int score;
  final int tasksDone;
  final int tasksTotal;

  ScoreHistory({
    required this.date,
    required this.score,
    required this.tasksDone,
    required this.tasksTotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'score': score,
      'tasksDone': tasksDone,
      'tasksTotal': tasksTotal,
    };
  }

  factory ScoreHistory.fromMap(Map<String, dynamic> map) {
    return ScoreHistory(
      date: DateTime.parse(map['date']),
      score: map['score'] ?? 0,
      tasksDone: map['tasksDone'] ?? 0,
      tasksTotal: map['tasksTotal'] ?? 0,
    );
  }
}
