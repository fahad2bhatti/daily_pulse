import 'package:flutter/material.dart';

class HabitModel {
  final String id;
  final String title;
  final String iconCodePoint;

  final bool isSelected;
  final DateTime createdAt;
  final String category;

  final int currentStreak;
  final int bestStreak;
  final List<String> completedDates;

  HabitModel({
    required this.id,
    required this.title,
    required this.iconCodePoint,
    this.isSelected = false,
    DateTime? createdAt,
    this.category = 'General',
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.completedDates = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  // ─── ICON GETTER ───
  IconData get icon => IconData(
    int.parse(iconCodePoint),
    fontFamily: 'MaterialIcons',
  );

  // ─── JSON ───
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'iconCodePoint': iconCodePoint,
      'isSelected': isSelected,
      'createdAt': createdAt.toIso8601String(),
      'category': category,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'completedDates': completedDates,
    };
  }

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'],
      title: json['title'],
      iconCodePoint: json['iconCodePoint'] ?? '0xe3af',
      isSelected: json['isSelected'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      category: json['category'] ?? 'General',
      currentStreak: json['currentStreak'] ?? 0,
      bestStreak: json['bestStreak'] ?? 0,
      completedDates: List<String>.from(json['completedDates'] ?? []),
    );
  }

  // ─── COPY WITH ───
  HabitModel copyWith({
    String? id,
    String? title,
    String? iconCodePoint,
    bool? isSelected,
    DateTime? createdAt,
    String? category,
    int? currentStreak,
    int? bestStreak,
    List<String>? completedDates,
  }) {
    return HabitModel(
      id: id ?? this.id,
      title: title ?? this.title,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      isSelected: isSelected ?? this.isSelected,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      completedDates: completedDates ?? this.completedDates,
    );
  }

  // ─── HELPERS ───
  bool get isCompletedToday {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return completedDates.contains(todayStr);
  }

  @override
  String toString() => 'Habit(id: $id, title: $title)';
}


