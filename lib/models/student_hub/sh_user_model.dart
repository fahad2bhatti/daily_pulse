import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { student, teacher, admin }

class SHUserModel {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String? profileImage;
  final List<String> enrolledGroups; // groups ke IDs
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isActive;

  SHUserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.profileImage,
    this.enrolledGroups = const [],
    required this.createdAt,
    this.lastLogin,
    this.isActive = true,
  });

  /// Firestore se data fetch karte waqt use karte hain
  factory SHUserModel.fromJson(Map<String, dynamic> json) {
    return SHUserModel(
      uid: json['uid'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => UserRole.student,
      ),
      profileImage: json['profileImage'] as String?,
      enrolledGroups: List<String>.from(json['enrolledGroups'] as List? ?? []),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      lastLogin: json['lastLogin'] != null
          ? (json['lastLogin'] as Timestamp).toDate()
          : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Firestore mein save karte hain
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role.name,
      'profileImage': profileImage,
      'enrolledGroups': enrolledGroups,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'isActive': isActive,
    };
  }

  /// App mein state update karte hain
  SHUserModel copyWith({
    String? uid,
    String? name,
    String? email,
    UserRole? role,
    String? profileImage,
    List<String>? enrolledGroups,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isActive,
  }) {
    return SHUserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      enrolledGroups: enrolledGroups ?? this.enrolledGroups,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Group join karte hain
  SHUserModel addGroup(String groupId) {
    if (!enrolledGroups.contains(groupId)) {
      return copyWith(
        enrolledGroups: [...enrolledGroups, groupId],
      );
    }
    return this;
  }

  /// Group leave karte hain
  SHUserModel removeGroup(String groupId) {
    return copyWith(
      enrolledGroups: enrolledGroups
          .where((id) => id != groupId)
          .toList(),
    );
  }

  /// Teacher ya student check karte hain
  bool get isTeacher => role == UserRole.teacher;
  bool get isStudent => role == UserRole.student;
  bool get isAdmin => role == UserRole.admin;

  @override
  String toString() =>
      'SHUser(uid: $uid, name: $name, role: ${role.name}, groups: ${enrolledGroups.length})';
}
