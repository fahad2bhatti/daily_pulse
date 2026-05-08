import 'package:flutter/material.dart';

class ReminderModel {
  final String id;
  final String title;
  final String iconCodePoint;
  final int timeHour;
  final int timeMinute;
  final String repeat;
  final bool sound;
  final bool vibration;
  bool isDone;

  // ─── NEW FIELDS (Backend ke liye) ─────────────────────
  final DateTime createdAt;           // Kab banaya gaya
  String? lastCompletedDate;          // Last kab complete kiya
  final String category;              // Category (optional)

  ReminderModel({
    required this.id,
    required this.title,
    required this.iconCodePoint,
    required this.timeHour,
    required this.timeMinute,
    this.repeat    = 'Daily',
    this.sound     = true,
    this.vibration = true,
    this.isDone    = false,
    DateTime? createdAt,              // NEW
    this.lastCompletedDate,           // NEW
    this.category  = 'General',       // NEW
  }) : createdAt = createdAt ?? DateTime.now();

  // ─── EXISTING GETTERS ─────────────────────────────────

  TimeOfDay get time => TimeOfDay(
    hour: timeHour,
    minute: timeMinute,
  );

  IconData get icon => IconData(
    int.parse(iconCodePoint),
    fontFamily: 'MaterialIcons',
  );

  // ─── NEW METHODS (Backend logic) ──────────────────────

  /// Check if reminder should reset today
  bool shouldResetToday() {
    if (lastCompletedDate == null) return false;

    final today = _dateOnly(DateTime.now());
    final lastDate = DateTime.parse(lastCompletedDate!);
    final lastDateOnly = _dateOnly(lastDate);

    // Agar last completion aaj se pehle ki hai, toh reset karo
    return today.isAfter(lastDateOnly);
  }

  /// Get full DateTime from timeHour and timeMinute
  DateTime get fullDateTime {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      timeHour,
      timeMinute,
    );
  }

  /// Check if reminder time has passed today
  bool get isTimePassed {
    return DateTime.now().isAfter(fullDateTime);
  }

  /// Helper: Date without time
  static DateTime _dateOnly(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  // ─── UPDATED TO JSON ──────────────────────────────────

  Map<String, dynamic> toJson() => {
    'id':            id,
    'title':         title,
    'iconCodePoint': iconCodePoint,
    'timeHour':      timeHour,
    'timeMinute':    timeMinute,
    'repeat':        repeat,
    'sound':         sound,
    'vibration':     vibration,
    'isDone':        isDone,
    'createdAt':     createdAt.toIso8601String(),        // NEW
    'lastCompletedDate': lastCompletedDate,              // NEW
    'category':      category,                            // NEW
  };

  // ─── UPDATED FROM JSON ────────────────────────────────

  factory ReminderModel.fromJson(Map<String, dynamic> json) => ReminderModel(
    id:            json['id'],
    title:         json['title'],
    iconCodePoint: json['iconCodePoint'],
    timeHour:      json['timeHour'],
    timeMinute:    json['timeMinute'],
    repeat:        json['repeat']     ?? 'Daily',
    sound:         json['sound']      ?? true,
    vibration:     json['vibration']  ?? true,
    isDone:        json['isDone']     ?? false,
    createdAt:     json['createdAt'] != null              // NEW
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
    lastCompletedDate: json['lastCompletedDate'],         // NEW
    category:      json['category']   ?? 'General',       // NEW
  );

  // ─── COPY WITH METHOD (useful for updates) ────────────

  ReminderModel copyWith({
    String? id,
    String? title,
    String? iconCodePoint,
    int? timeHour,
    int? timeMinute,
    String? repeat,
    bool? sound,
    bool? vibration,
    bool? isDone,
    DateTime? createdAt,
    String? lastCompletedDate,
    String? category,
  }) {
    return ReminderModel(
      id:            id ?? this.id,
      title:         title ?? this.title,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      timeHour:      timeHour ?? this.timeHour,
      timeMinute:    timeMinute ?? this.timeMinute,
      repeat:        repeat ?? this.repeat,
      sound:         sound ?? this.sound,
      vibration:     vibration ?? this.vibration,
      isDone:        isDone ?? this.isDone,
      createdAt:     createdAt ?? this.createdAt,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      category:      category ?? this.category,
    );
  }

  // ─── DEBUG HELPER ─────────────────────────────────────

  @override
  String toString() {
    return 'Reminder(id: $id, title: $title, time: $timeHour:$timeMinute, isDone: $isDone)';
  }
}


