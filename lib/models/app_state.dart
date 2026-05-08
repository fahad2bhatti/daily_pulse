import 'package:flutter/material.dart';

// Enums
enum Lifestyle { earlyBird, nightOwl, flexible }
enum TaskCategory { morning, afternoon, evening, anytime }
enum RepeatOption { daily, weekdays, weekends, weekly, custom, none }

// Habit Task Model
class HabitTask {
  final String id;
  String title;
  IconData icon;
  TimeOfDay time;
  TaskCategory category;
  RepeatOption repeat;
  bool reminderEnabled;
  bool isCompleted;
  Color color;

  HabitTask({
    required this.id,
    required this.title,
    required this.icon,
    required this.time,
    this.category = TaskCategory.morning,
    this.repeat = RepeatOption.daily,
    this.reminderEnabled = true,
    this.isCompleted = false,
    this.color = const Color(0xFF6C63FF),
  });

  // JSON serialization for SharedPreferences
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'iconCodePoint': icon.codePoint,
    'hour': time.hour,
    'minute': time.minute,
    'category': category.index,
    'repeat': repeat.index,
    'reminderEnabled': reminderEnabled,
    'isCompleted': isCompleted,
    'color': color.value,
  };

  factory HabitTask.fromJson(Map<String, dynamic> json) => HabitTask(
    id: json['id'],
    title: json['title'],
    icon: IconData(json['iconCodePoint'], fontFamily: 'MaterialIcons'),
    time: TimeOfDay(hour: json['hour'], minute: json['minute']),
    category: TaskCategory.values[json['category']],
    repeat: RepeatOption.values[json['repeat']],
    reminderEnabled: json['reminderEnabled'],
    isCompleted: json['isCompleted'],
    color: Color(json['color']),
  );
}

// Day Stats Model
class DayStats {
  final DateTime date;
  final int completed;
  final int total;

  DayStats({required this.date, required this.completed, required this.total});

  double get rate => total == 0 ? 0 : completed / total;

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'completed': completed,
    'total': total,
  };

  factory DayStats.fromJson(Map<String, dynamic> json) => DayStats(
    date: DateTime.parse(json['date']),
    completed: json['completed'],
    total: json['total'],
  );
}

// Complete App State
class AppState {
  String userName;
  Lifestyle lifestyle;
  TimeOfDay wakeUpTime;
  List<HabitTask> tasks;
  int streakDays;
  int disciplineScore;
  String rank;
  int level;
  List<DayStats> weekStats;

  AppState({
    this.userName = 'Fahad',
    this.lifestyle = Lifestyle.earlyBird,
    this.wakeUpTime = const TimeOfDay(hour: 6, minute: 30),
    List<HabitTask>? tasks,
    this.streakDays = 0,
    this.disciplineScore = 0,
    this.rank = 'Novice',
    this.level = 1,
    List<DayStats>? weekStats,
  })  : tasks = tasks ?? [],
        weekStats = weekStats ?? [];

  // Getters
  int get completedToday => tasks.where((t) => t.isCompleted).length;
  int get totalToday => tasks.length;
  double get todayProgress => totalToday == 0 ? 0 : completedToday / totalToday;

  List<HabitTask> get morningTasks =>
      tasks.where((t) => t.category == TaskCategory.morning).toList();
  List<HabitTask> get afternoonTasks =>
      tasks.where((t) => t.category == TaskCategory.afternoon).toList();
  List<HabitTask> get eveningTasks =>
      tasks.where((t) => t.category == TaskCategory.evening).toList();

  // Score calculation
  void calculateScore() {
    disciplineScore = completedToday * 10 + streakDays * 50;
    level = (disciplineScore / 500).floor() + 1;

    // Rank system
    if (disciplineScore >= 10000) rank = 'Grand Master';
    else if (disciplineScore >= 5000) rank = 'Master';
    else if (disciplineScore >= 2500) rank = 'Expert';
    else if (disciplineScore >= 1000) rank = 'Advanced';
    else if (disciplineScore >= 500) rank = 'Intermediate';
    else if (disciplineScore >= 100) rank = 'Beginner';
    else rank = 'Novice';
  }

  // JSON serialization
  Map<String, dynamic> toJson() => {
    'userName': userName,
    'lifestyle': lifestyle.index,
    'wakeUpHour': wakeUpTime.hour,
    'wakeUpMinute': wakeUpTime.minute,
    'tasks': tasks.map((t) => t.toJson()).toList(),
    'streakDays': streakDays,
    'disciplineScore': disciplineScore,
    'rank': rank,
    'level': level,
    'weekStats': weekStats.map((s) => s.toJson()).toList(),
  };

  factory AppState.fromJson(Map<String, dynamic> json) => AppState(
    userName: json['userName'],
    lifestyle: Lifestyle.values[json['lifestyle']],
    wakeUpTime: TimeOfDay(hour: json['wakeUpHour'], minute: json['wakeUpMinute']),
    tasks: (json['tasks'] as List).map((t) => HabitTask.fromJson(t)).toList(),
    streakDays: json['streakDays'],
    disciplineScore: json['disciplineScore'],
    rank: json['rank'],
    level: json['level'],
    weekStats: (json['weekStats'] as List).map((s) => DayStats.fromJson(s)).toList(),
  );
}


