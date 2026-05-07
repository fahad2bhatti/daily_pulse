import 'dart:convert';

class UserModel {
  final String name;
  final String wakeUpTime;      // Format: "06:00 AM"
  final String lifestyle;       // "Early Bird" | "Night Owl" | "Flexible"
  final String? avatarPath;     // Local image path (optional)
  final String? email;
  final DateTime? dateOfBirth;
  final String? gender;         // "Male" | "Female" | "Other"

  UserModel({
    this.name = 'User',
    this.wakeUpTime = '07:00 AM',
    this.lifestyle = 'Flexible',
    this.avatarPath,
    this.email,
    this.dateOfBirth,
    this.gender,
  });

  // Copy with for updates
  UserModel copyWith({
    String? name,
    String? wakeUpTime,
    String? lifestyle,
    String? avatarPath,
    String? email,
    DateTime? dateOfBirth,
    String? gender,
  }) {
    return UserModel(
      name: name ?? this.name,
      wakeUpTime: wakeUpTime ?? this.wakeUpTime,
      lifestyle: lifestyle ?? this.lifestyle,
      avatarPath: avatarPath ?? this.avatarPath,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
    );
  }

  // Convert to Map for SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'wakeUpTime': wakeUpTime,
      'lifestyle': lifestyle,
      'avatarPath': avatarPath,
      'email': email,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
    };
  }

  // Create from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? 'User',
      wakeUpTime: map['wakeUpTime'] ?? '07:00 AM',
      lifestyle: map['lifestyle'] ?? 'Flexible',
      avatarPath: map['avatarPath'],
      email: map['email'],
      dateOfBirth: map['dateOfBirth'] != null
          ? DateTime.parse(map['dateOfBirth'])
          : null,
      gender: map['gender'],
    );
  }

  // JSON helpers
  String toJson() => jsonEncode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(jsonDecode(source));

  @override
  String toString() {
    return 'UserModel(name: $name, wakeUpTime: $wakeUpTime, lifestyle: $lifestyle)';
  }
}
