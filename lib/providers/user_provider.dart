import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  static const String _userKey = 'user_data';

  UserModel _user = UserModel();
  bool _isLoading = false;

  UserModel get user => _user;
  bool get isLoading => _isLoading;

  UserProvider() {
    loadUser();
  }

  // Load from SharedPreferences
  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson != null) {
        _user = UserModel.fromJson(userJson);
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Save to SharedPreferences
  Future<void> saveUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, _user.toJson());
    } catch (e) {
      debugPrint('Error saving user: $e');
    }
  }

  // Update name
  Future<void> updateName(String name) async {
    _user = _user.copyWith(name: name);
    await saveUser();
    notifyListeners();
  }

  // Update wake up time
  Future<void> updateWakeUpTime(String time) async {
    _user = _user.copyWith(wakeUpTime: time);
    await saveUser();
    notifyListeners();
  }

  // Update lifestyle
  Future<void> updateLifestyle(String lifestyle) async {
    _user = _user.copyWith(lifestyle: lifestyle);
    await saveUser();
    notifyListeners();
  }

  // Update avatar
  Future<void> updateAvatar(String? path) async {
    _user = _user.copyWith(avatarPath: path);
    await saveUser();
    notifyListeners();
  }

  // Update email
  Future<void> updateEmail(String? email) async {
    _user = _user.copyWith(email: email);
    await saveUser();
    notifyListeners();
  }

  // Update gender
  Future<void> updateGender(String? gender) async {
    _user = _user.copyWith(gender: gender);
    await saveUser();
    notifyListeners();
  }

  // Update date of birth
  Future<void> updateDateOfBirth(DateTime? dob) async {
    _user = _user.copyWith(dateOfBirth: dob);
    await saveUser();
    notifyListeners();
  }

  // Full update
  Future<void> updateUser(UserModel newUser) async {
    _user = newUser;
    await saveUser();
    notifyListeners();
  }

  // Reset to default
  Future<void> resetUser() async {
    _user = UserModel();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    notifyListeners();
  }
}
