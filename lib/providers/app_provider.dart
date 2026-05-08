import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/app_state.dart';

class AppProvider extends ChangeNotifier {
  AppState _state = AppState();
  bool _isLoading = false;

  AppState get state => _state;
  bool get isLoading => _isLoading;

  AppProvider() {
    loadState();
  }

  // Load from SharedPreferences
  Future<void> loadState() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final stateJson = prefs.getString('app_state');

      if (stateJson != null) {
        _state = AppState.fromJson(jsonDecode(stateJson));
      }
    } catch (e) {
      debugPrint('Error loading state: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Save to SharedPreferences
  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_state', jsonEncode(_state.toJson()));
    } catch (e) {
      debugPrint('Error saving state: $e');
    }
  }

  // Update user name
  Future<void> updateName(String name) async {
    _state.userName = name;
    await _saveState();
    notifyListeners();
  }

  // Update lifestyle
  Future<void> updateLifestyle(Lifestyle lifestyle) async {
    _state.lifestyle = lifestyle;
    await _saveState();
    notifyListeners();
  }

  // Update wake up time
  Future<void> updateWakeUpTime(TimeOfDay time) async {
    _state.wakeUpTime = time;
    await _saveState();
    notifyListeners();
  }

  // Add task
  Future<void> addTask(HabitTask task) async {
    _state.tasks.add(task);
    await _saveState();
    notifyListeners();
  }

  // Toggle task completion
  Future<void> toggleTask(String id) async {
    final task = _state.tasks.firstWhere((t) => t.id == id);
    task.isCompleted = !task.isCompleted;

    // Recalculate score
    _state.calculateScore();

    // Update streak
    if (task.isCompleted) {
      _state.streakDays++;
    }

    await _saveState();
    notifyListeners();
  }

  // Delete task
  Future<void> deleteTask(String id) async {
    _state.tasks.removeWhere((t) => t.id == id);
    await _saveState();
    notifyListeners();
  }

  // Reset all
  Future<void> resetAll() async {
    _state = AppState();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('app_state');
    notifyListeners();
  }
}


