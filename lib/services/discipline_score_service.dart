import '../models/discipline_score.dart';

class DisciplineScoreService {
  // Points system
  static const int _taskCompletePoints = 10;
  static const int _streakBonus = 50;
  static const int _missPenalty = 20;
  static const int _perfectDayBonus = 100;

  // Calculate score for completing a task
  static int calculateTaskScore({
    required bool isOnTime,
    required int currentStreak,
  }) {
    int basePoints = _taskCompletePoints;

    // Bonus for on-time completion
    if (isOnTime) basePoints += 5;

    // Streak multiplier (max 3x)
    double streakMultiplier = 1.0 + (currentStreak * 0.1);
    if (streakMultiplier > 3.0) streakMultiplier = 3.0;

    return (basePoints * streakMultiplier).round();
  }

  // Calculate daily score
  static int calculateDailyScore({
    required int tasksCompleted,
    required int tasksTotal,
    required int currentStreak,
    required int missedTasks,
  }) {
    int score = 0;

    // Points for completed tasks
    score += tasksCompleted * _taskCompletePoints;

    // Streak bonus
    if (currentStreak > 0) {
      score += _streakBonus;
    }

    // Perfect day bonus
    if (tasksCompleted == tasksTotal && tasksTotal > 0) {
      score += _perfectDayBonus;
    }

    // Miss penalty
    score -= (missedTasks * _missPenalty);

    return score < 0 ? 0 : score;
  }

  // Get rank based on total score
  static String getRank(int totalScore) {
    if (totalScore >= 10000) return 'Grand Master';
    if (totalScore >= 5000) return 'Master';
    if (totalScore >= 2500) return 'Expert';
    if (totalScore >= 1000) return 'Advanced';
    if (totalScore >= 500) return 'Intermediate';
    if (totalScore >= 100) return 'Beginner';
    return 'Novice';
  }

  // Get rank color
  static String getRankColor(String rank) {
    switch (rank) {
      case 'Grand Master': return '#FFD700'; // Gold
      case 'Master': return '#C0C0C0'; // Silver
      case 'Expert': return '#CD7F32'; // Bronze
      case 'Advanced': return '#4CAF50';
      case 'Intermediate': return '#2196F3';
      case 'Beginner': return '#9C27B0';
      default: return '#757575';
    }
  }

  // Calculate level progress (0.0 to 1.0)
  static double calculateLevelProgress(int totalScore) {
    int currentLevel = (totalScore / 500).floor();
    int nextLevelScore = (currentLevel + 1) * 500;
    int currentLevelBase = currentLevel * 500;

    int progressInLevel = totalScore - currentLevelBase;
    int levelRange = nextLevelScore - currentLevelBase;

    return progressInLevel / levelRange;
  }

  // Get level number
  static int getLevel(int totalScore) {
    return (totalScore / 500).floor() + 1;
  }

  // Generate daily report
  static Map<String, dynamic> generateDailyReport(DisciplineScore score) {
    double completionRate = score.tasksCompleted > 0
        ? (score.tasksCompleted / (score.tasksCompleted + score.tasksMissed)) * 100
        : 0;

    return {
      'totalScore': score.totalScore,
      'todayScore': score.todayScore,
      'completionRate': completionRate.round(),
      'rank': getRank(score.totalScore),
      'level': getLevel(score.totalScore),
      'levelProgress': calculateLevelProgress(score.totalScore),
      'streak': score.currentStreak,
      'bestStreak': score.bestStreak,
    };
  }
}
