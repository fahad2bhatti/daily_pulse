class StreakModel {
  int currentStreak;
  int bestStreak;
  int totalCompletedDays;
  String? lastCompletedDate;
  int streakFreezeCount;      // Kitni freeze baqi hain
  bool isFreezeActive;         // Aaj freeze use hua?
  List<String> completedDates; // Saari dates jab tasks complete hue
  List<String> freezeUsedDates; // Dates jab freeze use kiya

  StreakModel({
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalCompletedDays = 0,
    this.lastCompletedDate,
    this.streakFreezeCount = 2,    // Default 2 freeze milenge
    this.isFreezeActive = false,
    this.completedDates = const [],
    this.freezeUsedDates = const [],
  });

  // ─── TO JSON ──────────────────────────────
  Map<String, dynamic> toJson() => {
    'currentStreak': currentStreak,
    'bestStreak': bestStreak,
    'totalCompletedDays': totalCompletedDays,
    'lastCompletedDate': lastCompletedDate,
    'streakFreezeCount': streakFreezeCount,
    'isFreezeActive': isFreezeActive,
    'completedDates': completedDates,
    'freezeUsedDates': freezeUsedDates,
  };

  // ─── FROM JSON ────────────────────────────
  factory StreakModel.fromJson(Map<String, dynamic> json) => StreakModel(
    currentStreak: json['currentStreak'] ?? 0,
    bestStreak: json['bestStreak'] ?? 0,
    totalCompletedDays: json['totalCompletedDays'] ?? 0,
    lastCompletedDate: json['lastCompletedDate'],
    streakFreezeCount: json['streakFreezeCount'] ?? 2,
    isFreezeActive: json['isFreezeActive'] ?? false,
    completedDates: List<String>.from(json['completedDates'] ?? []),
    freezeUsedDates: List<String>.from(json['freezeUsedDates'] ?? []),
  );

  // ─── HELPER: Date without time ────────────
  static String todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static String dateToString(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  // ─── CHECK: Aaj complete hua? ─────────────
  bool get isTodayCompleted {
    return completedDates.contains(todayString());
  }

  // ─── CHECK: Aaj freeze use hua? ───────────
  bool get isTodayFrozen {
    return freezeUsedDates.contains(todayString());
  }

  // ─── CHECK: Streak abhi active hai? ───────
  bool get isStreakActive {
    if (lastCompletedDate == null) return false;

    final today = DateTime.now();
    final lastDate = DateTime.parse(lastCompletedDate!);
    final diff = DateTime(today.year, today.month, today.day)
        .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
        .inDays;

    // 0 = aaj complete kiya, 1 = kal kiya (still active)
    return diff <= 1;
  }

  // ─── STREAK MILESTONE CHECK ───────────────
  String? get milestoneReached {
    const milestones = [7, 14, 21, 30, 50, 75, 100, 150, 200, 365];
    for (var m in milestones) {
      if (currentStreak == m) return '$m Days! 🎉';
    }
    return null;
  }

  // ─── STREAK EMOJI ─────────────────────────
  String get streakEmoji {
    if (currentStreak >= 100) return '👑';
    if (currentStreak >= 50) return '💎';
    if (currentStreak >= 30) return '🔥🔥🔥';
    if (currentStreak >= 21) return '🔥🔥';
    if (currentStreak >= 14) return '🔥';
    if (currentStreak >= 7) return '⚡';
    if (currentStreak >= 3) return '✨';
    return '🌱';
  }

  // ─── STREAK LEVEL ─────────────────────────
  String get streakLevel {
    if (currentStreak >= 100) return 'LEGEND';
    if (currentStreak >= 50) return 'MASTER';
    if (currentStreak >= 30) return 'WARRIOR';
    if (currentStreak >= 21) return 'CHAMPION';
    if (currentStreak >= 14) return 'FIGHTER';
    if (currentStreak >= 7) return 'STARTER';
    if (currentStreak >= 3) return 'BEGINNER';
    return 'NEWBIE';
  }

  // ─── COPY WITH ────────────────────────────
  StreakModel copyWith({
    int? currentStreak,
    int? bestStreak,
    int? totalCompletedDays,
    String? lastCompletedDate,
    int? streakFreezeCount,
    bool? isFreezeActive,
    List<String>? completedDates,
    List<String>? freezeUsedDates,
  }) {
    return StreakModel(
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      totalCompletedDays: totalCompletedDays ?? this.totalCompletedDays,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      streakFreezeCount: streakFreezeCount ?? this.streakFreezeCount,
      isFreezeActive: isFreezeActive ?? this.isFreezeActive,
      completedDates: completedDates ?? this.completedDates,
      freezeUsedDates: freezeUsedDates ?? this.freezeUsedDates,
    );
  }

  @override
  String toString() {
    return 'Streak(current: $currentStreak, best: $bestStreak, freeze: $streakFreezeCount)';
  }
}


