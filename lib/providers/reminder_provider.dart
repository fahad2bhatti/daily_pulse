import 'package:flutter/material.dart';
import '../models/reminder_model.dart';
import '../models/streak_model.dart';
import '../services/local_storage_service.dart';
import '../services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  List<ReminderModel> _reminders = [];
  List<double> _weeklyData = List.filled(7, 0.0);
  bool _isLoading = false;

  // ─── NEW: Streak Model ────────────────────────────────
  StreakModel _streakModel = StreakModel();

  // ─── GETTERS ──────────────────────────────────────────
  List<ReminderModel> get reminders => _reminders;
  List<double> get weeklyData => _weeklyData;
  bool get isLoading => _isLoading;

  // Streak getters (ab StreakModel se aayenge)
  StreakModel get streakModel => _streakModel;
  int get streak => _streakModel.currentStreak;
  int get bestStreak => _streakModel.bestStreak;
  int get freezeCount => _streakModel.streakFreezeCount;
  String get streakEmoji => _streakModel.streakEmoji;
  String get streakLevel => _streakModel.streakLevel;
  String? get milestoneReached => _streakModel.milestoneReached;
  bool get isTodayCompleted => _streakModel.isTodayCompleted;
  bool get isStreakActive => _streakModel.isStreakActive;

  // Task getters
  int get doneCount => _reminders.where((r) => r.isDone).length;
  int get totalCount => _reminders.length;
  double get progress => _reminders.isEmpty ? 0 : doneCount / totalCount;

  // Aaj ke pending tasks
  List<ReminderModel> get pendingToday =>
      _reminders.where((r) => !r.isDone).toList();

  // Aaj ke complete tasks
  List<ReminderModel> get completedToday =>
      _reminders.where((r) => r.isDone).toList();

  // ─── NEW GETTERS ──────────────────────────────────────

  /// Get reminders by category
  List<ReminderModel> getRemindersByCategory(String category) {
    return _reminders.where((r) => r.category == category).toList();
  }

  /// Get unique categories
  List<String> get categories {
    final cats = _reminders.map((r) => r.category).toSet().toList();
    cats.sort();
    return cats;
  }

  /// Check if any reminder exists
  bool get hasReminders => _reminders.isNotEmpty;

  /// Check if all tasks are done today
  bool get allTasksDone =>
      _reminders.isNotEmpty && doneCount == totalCount;

  // ─── INIT ─────────────────────────────────────────────

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Daily reset check
      await LocalStorageService.checkDailyReset();

      // Notification service initialize
      await NotificationService.init();
      await NotificationService.requestPermissions();

      // Data load karo
      _reminders = await LocalStorageService.loadReminders();
      _streakModel = await LocalStorageService.loadStreakModel();
      _weeklyData = await LocalStorageService.loadWeeklyDataImproved();

      // Existing reminders ke liye notifications schedule karo
      for (var reminder in _reminders) {
        await NotificationService.scheduleReminder(reminder);
      }

      debugPrint('✅ Provider Initialized - ${_reminders.length} reminders');
      debugPrint('🔥 Streak: ${_streakModel.currentStreak} | Best: ${_streakModel.bestStreak}');
      debugPrint('❄️ Freezes: ${_streakModel.streakFreezeCount}');
    } catch (e) {
      debugPrint('❌ Error in init: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── REFRESH (Pull to refresh) ────────────────────────

  Future<void> refresh() async {
    try {
      _reminders = await LocalStorageService.loadReminders();
      _streakModel = await LocalStorageService.loadStreakModel();
      _weeklyData = await LocalStorageService.loadWeeklyDataImproved();
      debugPrint('🔄 Data refreshed');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error refreshing: $e');
    }
  }

  // ─── CRUD ─────────────────────────────────────────────

  Future<bool> addReminder(ReminderModel r) async {
    try {
      final success = await LocalStorageService.addReminder(r);

      if (success) {
        _reminders.add(r);
        await NotificationService.scheduleReminder(r);
        debugPrint('➕ Reminder added & scheduled: ${r.title}');
        notifyListeners();
        return true;
      } else {
        debugPrint('⚠️ Failed to add reminder: ${r.title}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error adding reminder: $e');
      return false;
    }
  }

  Future<bool> deleteReminder(String id) async {
    try {
      final success = await LocalStorageService.deleteReminder(id);

      if (success) {
        _reminders.removeWhere((r) => r.id == id);
        await NotificationService.cancelReminder(id);
        debugPrint('🗑️ Reminder deleted & cancelled: $id');

        // Weekly data update karo
        _weeklyData = await LocalStorageService.loadWeeklyDataImproved();

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error deleting reminder: $e');
      return false;
    }
  }

  Future<bool> toggleDone(String id) async {
    try {
      final success = await LocalStorageService.toggleDone(id);

      if (success) {
        final index = _reminders.indexWhere((r) => r.id == id);
        if (index != -1) {
          _reminders[index].isDone = !_reminders[index].isDone;

          // ─── STREAK UPDATE: Jab sab tasks complete ho ──
          if (allTasksDone) {
            _streakModel = await LocalStorageService.updateStreak(
              allTasksCompleted: true,
            );

            // Milestone check - har 7 din pe free freeze!
            final milestone = _streakModel.milestoneReached;
            if (milestone != null) {
              debugPrint('🏆 MILESTONE: $milestone');

              if (_streakModel.currentStreak % 7 == 0) {
                _streakModel = await LocalStorageService.addStreakFreeze();
                debugPrint('🎁 Bonus freeze earned!');
              }
            }

            debugPrint('🎉 All tasks done! Streak: ${_streakModel.currentStreak}');
          }

          // Weekly data update karo
          _weeklyData = await LocalStorageService.loadWeeklyDataImproved();

          debugPrint(
            '${_reminders[index].isDone ? "✅" : "↩️"} Toggled: ${_reminders[index].title}',
          );
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error toggling reminder: $e');
      return false;
    }
  }

  // ─── UPDATE REMINDER ──────────────────────────────────

  Future<bool> updateReminder(String id, ReminderModel updatedReminder) async {
    try {
      final index = _reminders.indexWhere((r) => r.id == id);

      if (index != -1) {
        // Delete old
        await LocalStorageService.deleteReminder(id);
        await NotificationService.cancelReminder(id);

        // Add new
        final success =
        await LocalStorageService.addReminder(updatedReminder);

        if (success) {
          _reminders[index] = updatedReminder;
          await NotificationService.scheduleReminder(updatedReminder);

          debugPrint('📝 Reminder updated: ${updatedReminder.title}');
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error updating reminder: $e');
      return false;
    }
  }

  // ─── STREAK FREEZE ────────────────────────────────────

  Future<bool> useStreakFreeze() async {
    try {
      if (_streakModel.streakFreezeCount <= 0) {
        debugPrint('❌ No freezes available');
        return false;
      }

      _streakModel = await LocalStorageService.useStreakFreeze();
      notifyListeners();

      debugPrint(
        '❄️ Freeze used! Remaining: ${_streakModel.streakFreezeCount}',
      );
      return true;
    } catch (e) {
      debugPrint('❌ Error using freeze: $e');
      return false;
    }
  }

  // ─── BATCH OPERATIONS ─────────────────────────────────

  /// Mark all tasks as done
  Future<void> markAllDone() async {
    try {
      for (var reminder in _reminders) {
        if (!reminder.isDone) {
          await toggleDone(reminder.id);
        }
      }
      debugPrint('✅ All tasks marked as done');
    } catch (e) {
      debugPrint('❌ Error marking all done: $e');
    }
  }

  /// Reset all tasks
  Future<void> resetAllTasks() async {
    try {
      for (var reminder in _reminders) {
        if (reminder.isDone) {
          await toggleDone(reminder.id);
        }
      }
      debugPrint('↩️ All tasks reset');
    } catch (e) {
      debugPrint('❌ Error resetting tasks: $e');
    }
  }

  // ─── CLEAR ALL DATA ──────────────────────────────────

  Future<void> clearAllData() async {
    try {
      await LocalStorageService.clearAll();
      await NotificationService.cancelAll();

      _reminders = [];
      _streakModel = StreakModel();
      _weeklyData = List.filled(7, 0.0);

      debugPrint('🧹 All data cleared');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error clearing data: $e');
    }
  }

  // ─── BACKUP & RESTORE ────────────────────────────────

  Future<Map<String, dynamic>?> exportData() async {
    try {
      final data = await LocalStorageService.exportData();
      debugPrint('📤 Data exported');
      return data;
    } catch (e) {
      debugPrint('❌ Error exporting data: $e');
      return null;
    }
  }

  Future<bool> importData(Map<String, dynamic> data) async {
    try {
      final success = await LocalStorageService.importData(data);

      if (success) {
        // Reload everything
        await refresh();

        // Reschedule notifications
        for (var reminder in _reminders) {
          await NotificationService.scheduleReminder(reminder);
        }

        debugPrint('📥 Data imported & notifications rescheduled');
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error importing data: $e');
      return false;
    }
  }

  // ─── TEST NOTIFICATION ────────────────────────────────

  Future<void> testNotification() async {
    try {
      await NotificationService.showInstantNotification(
        'DailyPulse Test ⚡',
        'Notification system kaam kar raha hai! 🔥',
      );
      debugPrint('🧪 Test notification sent');
    } catch (e) {
      debugPrint('❌ Error sending test notification: $e');
    }
  }

  // ─── GET PENDING NOTIFICATIONS COUNT ──────────────────

  Future<int> getPendingNotificationsCount() async {
    try {
      return await NotificationService.getPendingCount();
    } catch (e) {
      debugPrint('❌ Error getting pending count: $e');
      return 0;
    }
  }

  // ─── STATS HELPERS ────────────────────────────────────

  /// Get completion rate percentage (0-100)
  int get completionPercentage => (progress * 100).round();

  /// Get motivational message based on progress
  String get motivationalMessage {
    if (_reminders.isEmpty) return 'Add your first reminder! 📝';

    final percent = completionPercentage;

    if (percent == 100) return 'Perfect! Sab khatam! 🎉';
    if (percent >= 75) return 'Almost there! Keep going! 💪';
    if (percent >= 50) return 'Halfway done! Great job! 👍';
    if (percent >= 25) return 'Good start! Continue! 🚀';
    return 'Let\'s get started! 💪';
  }

  /// Get streak message
  String get streakMessage {
    if (streak == 0) return 'Start your streak today! 🌱';
    if (streak >= 100) return 'LEGENDARY! $streak days! 👑';
    if (streak >= 50) return 'MASTER level! $streak days! 💎';
    if (streak >= 30) return 'WARRIOR! $streak days! 🔥🔥🔥';
    if (streak >= 21) return 'CHAMPION! $streak days! 🔥🔥';
    if (streak >= 14) return '2 weeks strong! $streak days! 🔥';
    if (streak >= 7) return '1 week done! $streak days! ⚡';
    if (streak >= 3) return 'Building momentum! $streak days! ✨';
    return '$streak day streak! Keep going! 🌱';
  }

  /// Get freeze status message
  String get freezeMessage {
    if (freezeCount == 0) return 'No freezes left! Be careful! ⚠️';
    return '$freezeCount freeze${freezeCount > 1 ? 's' : ''} available ❄️';
  }
}


