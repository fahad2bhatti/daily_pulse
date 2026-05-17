import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student_hub/group_model.dart';
import '../services/student_hub_group_service.dart';

// 🔧 Service Provider
final studentHubGroupServiceProvider =
    Provider((ref) => StudentHubGroupService());

// 📋 Get User's Groups
final userGroupsProvider =
    FutureProvider.family<List<GroupModel>, String>((ref, userUid) async {
  final groupService = ref.watch(studentHubGroupServiceProvider);
  return await groupService.getUserGroups(userUid);
});

// 🔍 Get Single Group
final groupProvider =
    FutureProvider.family<GroupModel?, String>((ref, groupId) async {
  final groupService = ref.watch(studentHubGroupServiceProvider);
  return await groupService.getGroupById(groupId);
});

// 👥 Get Group Members
final groupMembersProvider =
    FutureProvider.family<List<GroupModel>, String>((ref, groupId) async {
  final groupService = ref.watch(studentHubGroupServiceProvider);
  final group = await groupService.getGroupById(groupId);
  if (group == null) return [];

  // Return group info with member details fetch from SHUserModel
  return [group];
});

// 📊 Get Group Statistics
final groupStatsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, groupId) async {
  final groupService = ref.watch(studentHubGroupServiceProvider);
  return await groupService.getGroupStats(groupId);
});

// 🔄 Group Notifier for state management
final groupNotifierProvider = StateNotifierProvider<GroupNotifier, Map<String, GroupModel?>>((ref) {
  final groupService = ref.watch(studentHubGroupServiceProvider);
  return GroupNotifier(groupService);
});

class GroupNotifier extends StateNotifier<Map<String, GroupModel?>> {
  final StudentHubGroupService _groupService;

  GroupNotifier(this._groupService) : super({});

  // Create Group (Teachers)
  Future<GroupModel?> createGroup({
    required String name,
    required String subject,
    required String adminUid,
  }) async {
    try {
      final group = await _groupService.createGroup(
        name: name,
        subject: subject,
        adminUid: adminUid,
      );

      state = {...state, group.groupId: group};
      return group;
    } catch (e) {
      print('❌ Create Group Error: $e');
      rethrow;
    }
  }

  // Join Group (Students)
  Future<GroupModel?> joinGroup({
    required String inviteCode,
    required String userUid,
  }) async {
    try {
      final group = await _groupService.joinGroupWithCode(
        inviteCode: inviteCode,
        userUid: userUid,
      );

      if (group != null) {
        state = {...state, group.groupId: group};
      }

      return group;
    } catch (e) {
      print('❌ Join Group Error: $e');
      rethrow;
    }
  }

  // Update Group
  Future<void> updateGroup({
    required String groupId,
    String? name,
    String? subject,
  }) async {
    try {
      await _groupService.updateGroup(
        groupId: groupId,
        name: name,
        subject: subject,
      );

      // Refresh group data
      final group = await _groupService.getGroupById(groupId);
      if (group != null) {
        state = {...state, groupId: group};
      }
    } catch (e) {
      print('❌ Update Group Error: $e');
      rethrow;
    }
  }

  // Remove Member
  Future<void> removeMember({
    required String groupId,
    required String memberUid,
  }) async {
    try {
      await _groupService.removeMember(
        groupId: groupId,
        memberUid: memberUid,
      );

      // Refresh group
      final group = await _groupService.getGroupById(groupId);
      if (group != null) {
        state = {...state, groupId: group};
      }
    } catch (e) {
      print('❌ Remove Member Error: $e');
      rethrow;
    }
  }

  // Leave Group
  Future<void> leaveGroup({
    required String groupId,
    required String userUid,
  }) async {
    try {
      await _groupService.leaveGroup(
        groupId: groupId,
        userUid: userUid,
      );

      state = {...state, groupId: null};
    } catch (e) {
      print('❌ Leave Group Error: $e');
      rethrow;
    }
  }

  // Regenerate Invite Code
  Future<String> regenerateInviteCode(String groupId) async {
    try {
      final newCode = await _groupService.regenerateInviteCode(groupId);

      // Refresh group
      final group = await _groupService.getGroupById(groupId);
      if (group != null) {
        state = {...state, groupId: group};
      }

      return newCode;
    } catch (e) {
      print('❌ Regenerate Invite Code Error: $e');
      rethrow;
    }
  }

  // Delete Group
  Future<void> deleteGroup(String groupId) async {
    try {
      await _groupService.deleteGroup(groupId);
      state = {...state, groupId: null};
    } catch (e) {
      print('❌ Delete Group Error: $e');
      rethrow;
    }
  }
}

