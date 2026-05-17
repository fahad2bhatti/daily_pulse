import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String groupId;
  final String name;
  final String subject;
  final String adminUid;
  final String inviteCode;
  final List<String> memberUids;
  final DateTime createdAt;

  GroupModel({
    required this.groupId,
    required this.name,
    required this.subject,
    required this.adminUid,
    required this.inviteCode,
    required this.memberUids,
    required this.createdAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      groupId: json['groupId'] as String,
      name: json['name'] as String,
      subject: json['subject'] as String,
      adminUid: json['adminUid'] as String,
      inviteCode: json['inviteCode'] as String,
      memberUids: List<String>.from(json['memberUids'] as List),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'name': name,
      'subject': subject,
      'adminUid': adminUid,
      'inviteCode': inviteCode,
      'memberUids': memberUids,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  bool isMember(String uid) => memberUids.contains(uid);
  bool isAdmin(String uid) => adminUid == uid;
}