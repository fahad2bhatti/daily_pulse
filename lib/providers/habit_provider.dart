import 'package:flutter/material.dart';
import '../models/habit_model.dart';
import '../services/local_storage_service.dart';

class HabitProvider extends ChangeNotifier {
  List<HabitModel> _habits = [];
  bool _isLoading = false;

  List<HabitModel> get habits => _habits;
  bool get isLoading => _isLoading;
  bool get hasHabits => _habits.isNotEmpty;

  // Selected habits
  List<HabitModel> get selectedHabits =>
      _habits.where((h) => h.isSelected).toList();

  // Today completed
  List<HabitModel> get completedToday =>
      _habits.where((h) => h.isCompletedToday).toList();

  // Today pending
  List<HabitModel> get pendingToday =>
      _habits.where((h) => !h.isCompletedToday).toList();

  // ─── INIT ─────────────────────────────
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _habits = await LocalStorageService.loadHabits();
      debugPrint('✅ Habits loaded: ${_habits.length}');
    } catch (e) {
      debugPrint('❌ Error loading habits: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── ADD HABIT ────────────────────────
  Future<bool> addHabit(HabitModel habit) async {
    try {
      _habits.add(habit);
      await LocalStorageService.saveHabits(_habits);
      debugPrint('➕ Habit added: ${habit.title}');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Error adding habit: $e');
      return false;
    }
  }

  // ─── DELETE HABIT ─────────────────────
  Future<bool> deleteHabit(String id) async {
    try {
      _habits.removeWhere((h) => h.id == id);
      await LocalStorageService.saveHabits(_habits);
      debugPrint('🗑️ Habit deleted: $id');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting habit: $e');
      return false;
    }
  }

  // ─── TOGGLE TODAY COMPLETION ──────────
  Future<bool> toggleHabitToday(String id) async {
    try {
      final index = _habits.indexWhere((h) => h.id == id);
      if (index == -1) return false;

      final habit = _habits[index];
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      List<String> dates = List.from(habit.completedDates);

      if (dates.contains(todayStr)) {
        // Undo completion
        dates.remove(todayStr);
        debugPrint('↩️ Habit uncompleted: ${habit.title}');
      } else {
        // Mark complete
        dates.add(todayStr);
        debugPrint('✅ Habit completed: ${habit.title}');
      }

      _habits[index] = habit.copyWith(
        completedDates: dates,
        currentStreak: _calculateStreak(dates),
        bestStreak: _calculateBestStreak(dates, habit.bestStreak),
      );

      await LocalStorageService.saveHabits(_habits);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Error toggling habit: $e');
      return false;
    }
  }

  // ─── STREAK CALCULATION ───────────────
  int _calculateStreak(List<String> dates) {
    if (dates.isEmpty) return 0;

    dates.sort((a, b) => b.compareTo(a)); // Latest first
    int streak = 0;
    DateTime current = DateTime.now();

    for (int i = 0; i < dates.length; i++) {
      final checkDate = DateTime.parse(dates[i]);
      final diff = DateTime(
        current.year, current.month, current.day,
      ).difference(DateTime(
        checkDate.year, checkDate.month, checkDate.day,
      )).inDays;

      if (diff == streak) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  int _calculateBestStreak(List<String> dates, int currentBest) {
    final newStreak = _calculateStreak(dates);
    return newStreak > currentBest ? newStreak : currentBest;
  }
}