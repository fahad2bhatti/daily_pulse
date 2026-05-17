import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/student_hub/group_model.dart';
import 'dart:math';

class StudentHubGroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ✨ Generate random invite code (6 characters)
  String generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  /// 📝 Create New Group (Teacher ke liye)
  Future<GroupModel> createGroup({
    required String name,
    required String subject,
    required String adminUid,
  }) async {
    try {
      final groupId = _firestore.collection('groups').doc().id;
      final inviteCode = generateInviteCode();

      final group = GroupModel(
        groupId: groupId,
        name: name,
        subject: subject,
        adminUid: adminUid,
        inviteCode: inviteCode,
        memberUids: [adminUid], // Admin ko add karte hain
        createdAt: DateTime.now(),
      );

      await _firestore.collection('groups').doc(groupId).set(group.toJson());

      // Admin ke profile mein group add karte hain
      await _firestore.collection('users').doc(adminUid).update({
        'enrolledGroups': FieldValue.arrayUnion([groupId]),
      });

       return group;
     } catch (e) {
       debugPrint('❌ Create Group Error: $e');
       rethrow;
     }
   }

  /// 🔗 Join Group with Invite Code (Student ke liye)
  Future<GroupModel?> joinGroupWithCode({
    required String inviteCode,
    required String userUid,
  }) async {
    try {
      // Invite code se group find karte hain
      final groupSnapshot = await _firestore
          .collection('groups')
          .where('inviteCode', isEqualTo: inviteCode)
          .limit(1)
          .get();

       if (groupSnapshot.docs.isEmpty) {
         debugPrint('❌ Group not found with this invite code');
         return null;
       }

      final groupDoc = groupSnapshot.docs.first;
      final groupId = groupDoc.id;
      final group = GroupModel.fromJson(groupDoc.data());

       // Check agar user already member hai
       if (group.isMember(userUid)) {
         debugPrint('⚠️ User already a member of this group');
         return group;
       }

      // Group mein member add karte hain
      await _firestore.collection('groups').doc(groupId).update({
        'memberUids': FieldValue.arrayUnion([userUid]),
      });

      // Student ke profile mein group add karte hain
      await _firestore.collection('users').doc(userUid).update({
        'enrolledGroups': FieldValue.arrayUnion([groupId]),
      });

       return group;
     } catch (e) {
       debugPrint('❌ Join Group Error: $e');
       rethrow;
     }
   }

  /// 👥 Get All Groups for User
  Future<List<GroupModel>> getUserGroups(String userUid) async {
    try {
      final userDoc =
          await _firestore.collection('users').doc(userUid).get();

      if (!userDoc.exists) return [];

      final enrolledGroupIds =
          List<String>.from(userDoc.data()?['enrolledGroups'] ?? []);

      if (enrolledGroupIds.isEmpty) return [];

      final groupDocs = await _firestore
          .collection('groups')
          .where(FieldPath.documentId, whereIn: enrolledGroupIds)
          .get();

       return groupDocs.docs
           .map((doc) => GroupModel.fromJson(doc.data()))
           .toList();
     } catch (e) {
       debugPrint('❌ Get User Groups Error: $e');
       return [];
     }
   }

  /// 🔍 Get Single Group
  Future<GroupModel?> getGroupById(String groupId) async {
    try {
      final doc = await _firestore.collection('groups').doc(groupId).get();

      if (doc.exists) {
        return GroupModel.fromJson(doc.data()!);
       }
       return null;
     } catch (e) {
       debugPrint('❌ Get Group Error: $e');
       return null;
     }
   }

  /// 📝 Update Group Details (Admin ke liye)
  Future<void> updateGroup({
    required String groupId,
    String? name,
    String? subject,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (name != null) updates['name'] = name;
      if (subject != null) updates['subject'] = subject;

      if (updates.isNotEmpty) {
        await _firestore.collection('groups').doc(groupId).update(updates);
      }
    } catch (e) {
      print('❌ Update Group Error: $e');
      rethrow;
    }
  }

  /// 🧑‍💼 Remove Member from Group (Admin ke liye)
  Future<void> removeMember({
    required String groupId,
    required String memberUid,
  }) async {
    try {
      // Group se member remove karte hain
      await _firestore.collection('groups').doc(groupId).update({
        'memberUids': FieldValue.arrayRemove([memberUid]),
      });

      // Student ke profile se group remove karte hain
      await _firestore.collection('users').doc(memberUid).update({
        'enrolledGroups': FieldValue.arrayRemove([groupId]),
      });
    } catch (e) {
      print('❌ Remove Member Error: $e');
      rethrow;
    }
  }

  /// 🚪 Leave Group (Student ke liye)
  Future<void> leaveGroup({
    required String groupId,
    required String userUid,
  }) async {
    try {
      await removeMember(groupId: groupId, memberUid: userUid);
    } catch (e) {
      print('❌ Leave Group Error: $e');
      rethrow;
    }
  }

  /// 🔐 Regenerate Invite Code (Admin ke liye)
  Future<String> regenerateInviteCode(String groupId) async {
    try {
      final newCode = generateInviteCode();

      await _firestore.collection('groups').doc(groupId).update({
        'inviteCode': newCode,
      });

      return newCode;
    } catch (e) {
      print('❌ Regenerate Invite Code Error: $e');
      rethrow;
    }
  }

  /// 🗑️ Delete Group (Admin ke liye - soft delete)
  Future<void> deleteGroup(String groupId) async {
    try {
      // Group ko delete karte hain
      await _firestore.collection('groups').doc(groupId).delete();

      // Iss group se related assignments/quizzes ko bhi delete karna padega
      // Ya phir unhe archive mark kara sakte hain
    } catch (e) {
      print('❌ Delete Group Error: $e');
      rethrow;
    }
  }

  /// 📊 Get Group Statistics
  Future<Map<String, dynamic>> getGroupStats(String groupId) async {
    try {
      final group = await getGroupById(groupId);
      if (group == null) return {};

      // Assignment counts
      final assignmentSnapshot = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('assignments')
          .get();

      // Quiz counts
      final quizSnapshot = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('quizzes')
          .get();

      return {
        'totalMembers': group.memberUids.length,
        'totalAssignments': assignmentSnapshot.docs.length,
        'totalQuizzes': quizSnapshot.docs.length,
        'createdAt': group.createdAt.toString(),
      };
    } catch (e) {
      print('❌ Get Group Stats Error: $e');
      return {};
    }
  }
}

