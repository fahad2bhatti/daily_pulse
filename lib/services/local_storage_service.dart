import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder_model.dart';
import 'package:flutter/material.dart';
import '../models/streak_model.dart';
import 'package:daily_pulse/models/habit_model.dart';

class LocalStorageService {
  static const _remindersKey  = 'reminders';
  static const _streakKey     = 'streak';
  static const _bestStreakKey = 'best_streak';
  static const _lastOpenKey   = 'last_open';
  static const _completedKey  = 'completed_dates';
  static const _lastResetKey  = 'last_reset_date';  // ← NEW: Daily reset tracking
  // ─── NEW KEY ────────────────────────────
  static const _streakModelKey = 'streak_model';




// ─── SAVE STREAK MODEL ─────────────────
  static Future<bool> saveStreakModel(StreakModel streak) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setString(
        _streakModelKey,
        jsonEncode(streak.toJson()),
      );
      debugPrint('💾 Streak saved: ${streak.currentStreak} days');
      return success;
    } catch (e) {
      debugPrint('❌ Error saving streak: $e');
      return false;
    }
  }

// ─── LOAD STREAK MODEL ─────────────────
  static Future<StreakModel> loadStreakModel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_streakModelKey);

      if (data != null) {
        final streak = StreakModel.fromJson(jsonDecode(data));
        debugPrint('📥 Streak loaded: ${streak.currentStreak} days');
        return streak;
      }

      debugPrint('📥 No streak data - returning default');
      return StreakModel();
    } catch (e) {
      debugPrint('❌ Error loading streak: $e');
      return StreakModel();
    }
  }

// ─── UPDATE STREAK (Smart Logic) ────────
  static Future<StreakModel> updateStreak({
    required bool allTasksCompleted,
  }) async {
    try {
      final streak = await loadStreakModel();
      final today = StreakModel.todayString();

      // Agar aaj pehle se complete hai toh skip
      if (streak.isTodayCompleted) {
        debugPrint('ℹ️ Today already completed');
        return streak;
      }

      if (allTasksCompleted) {
        // ─── TASKS COMPLETE HAIN ──────────
        final dates = List<String>.from(streak.completedDates);
        dates.add(today);

        int newStreak = streak.currentStreak;

        if (streak.lastCompletedDate == null) {
          // Pehli baar
          newStreak = 1;
        } else {
          final lastDate = DateTime.parse(streak.lastCompletedDate!);
          final todayDate = DateTime.now();
          final diff = DateTime(todayDate.year, todayDate.month, todayDate.day)
              .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
              .inDays;

          if (diff == 1) {
            // Consecutive day
            newStreak += 1;
          } else if (diff == 0) {
            // Same day - no change
          } else if (diff == 2 && streak.isTodayFrozen) {
            // Freeze use hua tha kal - streak continue
            newStreak += 1;
          } else {
            // Streak broken
            debugPrint('💔 Streak was broken (gap: $diff days)');
            newStreak = 1;
          }
        }

        final newBest = newStreak > streak.bestStreak
            ? newStreak
            : streak.bestStreak;

        final updatedStreak = streak.copyWith(
          currentStreak: newStreak,
          bestStreak: newBest,
          totalCompletedDays: streak.totalCompletedDays + 1,
          lastCompletedDate: today,
          completedDates: dates,
        );

        await saveStreakModel(updatedStreak);

        debugPrint('🔥 Streak updated: $newStreak | Best: $newBest');
        return updatedStreak;
      }

      return streak;
    } catch (e) {
      debugPrint('❌ Error updating streak: $e');
      return StreakModel();
    }
  }

// ─── USE STREAK FREEZE ──────────────────
  static Future<StreakModel> useStreakFreeze() async {
    try {
      final streak = await loadStreakModel();
      final today = StreakModel.todayString();

      // Check: freeze available hai?
      if (streak.streakFreezeCount <= 0) {
        debugPrint('❌ No freeze available');
        return streak;
      }

      // Check: aaj already use hua?
      if (streak.isTodayFrozen) {
        debugPrint('ℹ️ Freeze already used today');
        return streak;
      }

      final freezeDates = List<String>.from(streak.freezeUsedDates);
      freezeDates.add(today);

      final updatedStreak = streak.copyWith(
        streakFreezeCount: streak.streakFreezeCount - 1,
        isFreezeActive: true,
        freezeUsedDates: freezeDates,
      );

      await saveStreakModel(updatedStreak);
      debugPrint('❄️ Streak freeze used! Remaining: ${updatedStreak.streakFreezeCount}');

      return updatedStreak;
    } catch (e) {
      debugPrint('❌ Error using streak freeze: $e');
      return StreakModel();
    }
  }

// ─── ADD STREAK FREEZE (reward) ─────────
  static Future<StreakModel> addStreakFreeze({int count = 1}) async {
    try {
      final streak = await loadStreakModel();

      final updatedStreak = streak.copyWith(
        streakFreezeCount: streak.streakFreezeCount + count,
      );

      await saveStreakModel(updatedStreak);
      debugPrint('🎁 Streak freeze added! Total: ${updatedStreak.streakFreezeCount}');

      return updatedStreak;
    } catch (e) {
      debugPrint('❌ Error adding freeze: $e');
      return StreakModel();
    }
  }

// ─── WEEKLY DATA IMPROVED ───────────────
  static Future<List<double>> loadWeeklyDataImproved() async {
    try {
      final reminders = await loadReminders();
      final total = reminders.length;

      if (total == 0) return List.filled(7, 0.0);

      final streak = await loadStreakModel();

      return List.generate(7, (i) {
        final day = DateTime.now().subtract(Duration(days: 6 - i));
        final dayStr = StreakModel.dateToString(day);

        if (streak.completedDates.contains(dayStr)) {
          return 1.0; // 100% complete
        }

        if (streak.freezeUsedDates.contains(dayStr)) {
          return 0.5; // Freeze used - show differently
        }

        return 0.0; // Not completed
      });
    } catch (e) {
      debugPrint('❌ Error loading weekly data: $e');
      return List.filled(7, 0.0);
    }
  }

  // ─── DAILY RESET (NEW - Important!) ──────────────────

  /// App khulte waqt check karo - agar naya din hai toh reminders reset karo
  static Future<void> checkDailyReset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _dateOnly(DateTime.now()).toIso8601String();
      final lastReset = prefs.getString(_lastResetKey);

      // Agar aaj reset nahi hua hai
      if (lastReset != today) {
        debugPrint('🔄 Daily reset started...');

        final reminders = await loadReminders();
        bool anyReset = false;

        for (var reminder in reminders) {
          // Agar reminder complete tha aur reset hona chahiye
          if (reminder.isDone && reminder.shouldResetToday()) {
            reminder.isDone = false;
            anyReset = true;
          }
        }

        if (anyReset) {
          await saveReminders(reminders);
          debugPrint('✅ ${reminders.where((r) => !r.isDone).length} reminders reset');
        }

        await prefs.setString(_lastResetKey, today);
        debugPrint('✅ Daily reset complete');
      }
    } catch (e) {
      debugPrint('❌ Daily reset error: $e');
    }
  }

  // ─── REMINDERS ────────────────────────────────────────

  static Future<List<ReminderModel>> loadReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list  = prefs.getStringList(_remindersKey) ?? [];
      final reminders = list.map((e) => ReminderModel.fromJson(jsonDecode(e))).toList();
      debugPrint('📥 Loaded ${reminders.length} reminders');
      return reminders;
    } catch (e) {
      debugPrint('❌ Error loading reminders: $e');
      return [];
    }
  }

  static Future<bool> saveReminders(List<ReminderModel> reminders) async {
    try {
      final prefs  = await SharedPreferences.getInstance();
      final list   = reminders.map((r) => jsonEncode(r.toJson())).toList();
      final success = await prefs.setStringList(_remindersKey, list);
      debugPrint('💾 Saved ${reminders.length} reminders');
      return success;
    } catch (e) {
      debugPrint('❌ Error saving reminders: $e');
      return false;
    }
  }

  static Future<bool> addReminder(ReminderModel r) async {
    try {
      // Validation check (NEW)
      if (!validateReminder(r)) {
        debugPrint('⚠️ Invalid reminder: ${r.title}');
        return false;
      }

      final list = await loadReminders();

      // Duplicate check (NEW)
      if (list.any((existing) => existing.id == r.id)) {
        debugPrint('⚠️ Duplicate reminder ID: ${r.id}');
        return false;
      }

      list.add(r);
      final success = await saveReminders(list);

      if (success) {
        debugPrint('➕ Added reminder: ${r.title}');
      }

      return success;
    } catch (e) {
      debugPrint('❌ Error adding reminder: $e');
      return false;
    }
  }

  static Future<bool> deleteReminder(String id) async {
    try {
      final list = await loadReminders();
      final initialLength = list.length;

      list.removeWhere((r) => r.id == id);

      if (list.length < initialLength) {
        final success = await saveReminders(list);
        if (success) {
          debugPrint('🗑️ Deleted reminder: $id');
        }
        return success;
      }

      debugPrint('⚠️ Reminder not found: $id');
      return false;
    } catch (e) {
      debugPrint('❌ Error deleting reminder: $e');
      return false;
    }
  }

  static Future<bool> toggleDone(String id) async {
    try {
      final list  = await loadReminders();
      final index = list.indexWhere((r) => r.id == id);

      if (index != -1) {
        list[index].isDone = !list[index].isDone;

        // agar task complete hua toh (NEW - improved)
        if (list[index].isDone) {
          list[index].lastCompletedDate = DateTime.now().toIso8601String();
          await _markTodayCompleted();
          debugPrint('✅ Completed: ${list[index].title}');
        } else {
          debugPrint('↩️ Uncompleted: ${list[index].title}');
        }

        return await saveReminders(list);
      }

      debugPrint('⚠️ Reminder not found for toggle: $id');
      return false;
    } catch (e) {
      debugPrint('❌ Error toggling reminder: $e');
      return false;
    }
  }

  // ─── VALIDATION (NEW) ─────────────────────────────────

  static bool validateReminder(ReminderModel reminder) {
    if (reminder.title.trim().isEmpty) {
      debugPrint('⚠️ Validation failed: Empty title');
      return false;
    }
    if (reminder.title.length > 100) {
      debugPrint('⚠️ Validation failed: Title too long (${reminder.title.length} chars)');
      return false;
    }
    if (reminder.timeHour < 0 || reminder.timeHour > 23) {
      debugPrint('⚠️ Validation failed: Invalid hour (${reminder.timeHour})');
      return false;
    }
    if (reminder.timeMinute < 0 || reminder.timeMinute > 59) {
      debugPrint('⚠️ Validation failed: Invalid minute (${reminder.timeMinute})');
      return false;
    }
    return true;
  }

  // ─── STREAK ───────────────────────────────────────────

  static Future<int> loadStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_streakKey) ?? 0;
    } catch (e) {
      debugPrint('❌ Error loading streak: $e');
      return 0;
    }
  }

  static Future<int> loadBestStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_bestStreakKey) ?? 0;
    } catch (e) {
      debugPrint('❌ Error loading best streak: $e');
      return 0;
    }
  }

  static Future<int> checkAndUpdateStreak() async {
    try {
      final prefs       = await SharedPreferences.getInstance();
      final lastOpenStr = prefs.getString(_lastOpenKey);
      final today       = _dateOnly(DateTime.now());

      int streak = prefs.getInt(_streakKey)     ?? 0;
      int best   = prefs.getInt(_bestStreakKey) ?? 0;

      if (lastOpenStr == null) {
        // pehli baar open ho raha hai
        streak = 1;
        debugPrint('🔥 First time streak: $streak');
      } else {
        final lastOpen = DateTime.parse(lastOpenStr);
        final diff     = today.difference(_dateOnly(lastOpen)).inDays;

        if (diff == 0) {
          // same din — koi change nahi
          debugPrint('🔥 Same day - streak unchanged: $streak');
        } else if (diff == 1) {
          // consecutive din — streak badhao
          streak += 1;
          debugPrint('🔥 Consecutive day - streak increased: $streak');
        } else {
          // streak toot gaya
          debugPrint('💔 Streak broken - resetting to 1 (was $streak, gap: $diff days)');
          streak = 1;
        }
      }

      if (streak > best) {
        best = streak;
        debugPrint('🏆 New best streak: $best');
      }

      await prefs.setString(_lastOpenKey,   today.toIso8601String());
      await prefs.setInt(_streakKey,        streak);
      await prefs.setInt(_bestStreakKey,    best);

      return streak;
    } catch (e) {
      debugPrint('❌ Error updating streak: $e');
      return 0;
    }
  }

  // ─── COMPLETED DATES (Stats ke liye) ──────────────────

  static Future<void> _markTodayCompleted() async {
    try {
      final prefs    = await SharedPreferences.getInstance();
      final today    = _dateOnly(DateTime.now()).toIso8601String();
      final dates    = prefs.getStringList(_completedKey) ?? [];

      if (!dates.contains(today)) {
        dates.add(today);
        await prefs.setStringList(_completedKey, dates);
        debugPrint('📅 Today marked as completed');
      }
    } catch (e) {
      debugPrint('❌ Error marking today completed: $e');
    }
  }

  static Future<List<String>> loadCompletedDates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_completedKey) ?? [];
    } catch (e) {
      debugPrint('❌ Error loading completed dates: $e');
      return [];
    }
  }

  // last 7 days ka completion data
  static Future<List<double>> loadWeeklyData() async {
    try {
      final prefs     = await SharedPreferences.getInstance();
      final dates     = prefs.getStringList(_completedKey) ?? [];
      final reminders = await loadReminders();
      final total     = reminders.length;

      return List.generate(7, (i) {
        final day = _dateOnly(
          DateTime.now().subtract(Duration(days: 6 - i)),
        ).toIso8601String();
        if (dates.contains(day) && total > 0) {
          return 1.0;
        }
        return 0.0;
      });
    } catch (e) {
      debugPrint('❌ Error loading weekly data: $e');
      return List.filled(7, 0.0);
    }
  }

  // ─── BACKUP & RESTORE (NEW) ───────────────────────────

  /// Export all data as JSON
  static Future<Map<String, dynamic>> exportData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'reminders': prefs.getStringList(_remindersKey) ?? [],
        'streak': prefs.getInt(_streakKey) ?? 0,
        'bestStreak': prefs.getInt(_bestStreakKey) ?? 0,
        'completedDates': prefs.getStringList(_completedKey) ?? [],
        'lastOpen': prefs.getString(_lastOpenKey),
        'exportedAt': DateTime.now().toIso8601String(),
        'version': '1.0',
      };
      debugPrint('📤 Data exported');
      return data;
    } catch (e) {
      debugPrint('❌ Error exporting data: $e');
      return {};
    }
  }

  /// Import data from JSON
  static Future<bool> importData(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (data.containsKey('reminders')) {
        await prefs.setStringList(
          _remindersKey,
          List<String>.from(data['reminders']),
        );
      }
      if (data.containsKey('streak')) {
        await prefs.setInt(_streakKey, data['streak']);
      }
      if (data.containsKey('bestStreak')) {
        await prefs.setInt(_bestStreakKey, data['bestStreak']);
      }
      if (data.containsKey('completedDates')) {
        await prefs.setStringList(
          _completedKey,
          List<String>.from(data['completedDates']),
        );
      }
      if (data.containsKey('lastOpen')) {
        await prefs.setString(_lastOpenKey, data['lastOpen']);
      }

      debugPrint('📥 Data imported successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error importing data: $e');
      return false;
    }
  }

  // ─── HELPERS ──────────────────────────────────────────

  static DateTime _dateOnly(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      debugPrint('🧹 All data cleared');
    } catch (e) {
      debugPrint('❌ Error clearing data: $e');
    }
  }

  // ─── STATS (NEW) ──────────────────────────────────────

  /// Get total reminders count
  static Future<int> getTotalRemindersCount() async {
    final reminders = await loadReminders();
    return reminders.length;
  }

  /// Get completed reminders count (today)
  static Future<int> getCompletedTodayCount() async {
    final reminders = await loadReminders();
    return reminders.where((r) => r.isDone).length;
  }

  // LocalStorageService mein yeh add karo:

  static const _habitsKey = 'habits';

  static Future<List<HabitModel>> loadHabits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_habitsKey) ?? [];
      return list.map((e) => HabitModel.fromJson(jsonDecode(e))).toList();
    } catch (e) {
      debugPrint('❌ Error loading habits: $e');
      return [];
    }
  }

  static Future<bool> saveHabits(List<HabitModel> habits) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = habits.map((h) => jsonEncode(h.toJson())).toList();
      return await prefs.setStringList(_habitsKey, list);
    } catch (e) {
      debugPrint('❌ Error saving habits: $e');
      return false;
    }
  }

  /// Get completion rate (0.0 to 1.0)
  static Future<double> getTodayCompletionRate() async {
    final reminders = await loadReminders();
    if (reminders.isEmpty) return 0.0;

    final completed = reminders.where((r) => r.isDone).length;
    return completed / reminders.length;
  }
}
