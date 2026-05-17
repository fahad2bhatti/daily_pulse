import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student_hub/assignment_model.dart';
import '../models/student_hub/submission_model.dart';
import '../services/student_hub_assignment_service.dart';
import 'student_hub_user_provider.dart';

// 🔧 Service Provider
final studentHubAssignmentServiceProvider =
    Provider((ref) => StudentHubAssignmentService());

// 📋 Get Group Assignments
final groupAssignmentsProvider = FutureProvider.family<List<AssignmentModel>, String>((ref, groupId) async {
  final assignmentService = ref.watch(studentHubAssignmentServiceProvider);
  return await assignmentService.getGroupAssignments(groupId);
});

// 🔍 Get Single Assignment
final assignmentProvider = FutureProvider.family<AssignmentModel?, (String, String)>((ref, params) async {
  final assignmentService = ref.watch(studentHubAssignmentServiceProvider);
  return await assignmentService.getAssignmentById(
    groupId: params.$1,
    assignmentId: params.$2,
  );
});

// 🔍 Get Assignment Detail
final assignmentDetailProvider = FutureProvider.family<AssignmentModel?, (String, String)>((ref, params) async {
  final assignmentService = ref.watch(studentHubAssignmentServiceProvider);
  return await assignmentService.getAssignmentById(
    groupId: params.$1,
    assignmentId: params.$2,
  );
});

// 📮 Get Student's Submission for Assignment
final mySubmissionProvider = FutureProvider.family<SubmissionModel?, (String, String)>((ref, params) async {
  final assignmentService = ref.watch(studentHubAssignmentServiceProvider);
  final currentUser = ref.watch(currentSHUserNotifierProvider);
  
  if (currentUser == null) return null;
  
  return await assignmentService.getSubmission(
    groupId: params.$1,
    assignmentId: params.$2,
    userId: currentUser.uid,
  );
});

// 📮 Get Student's Submission for Assignment
final assignmentSubmissionProvider = FutureProvider.family<SubmissionModel?, (String, String, String)>((ref, params) async {
  final assignmentService = ref.watch(studentHubAssignmentServiceProvider);
  return await assignmentService.getSubmission(
    groupId: params.$1,
    assignmentId: params.$2,
    userId: params.$3,
  );
});

// 📊 Get Assignment Statistics
final assignmentStatsProvider = FutureProvider.family<Map<String, dynamic>, (String, String)>((ref, params) async {
  final assignmentService = ref.watch(studentHubAssignmentServiceProvider);
  return await assignmentService.getAssignmentStats(
    groupId: params.$1,
    assignmentId: params.$2,
  );
});

// 🔄 Assignment Notifier
final assignmentNotifierProvider = StateNotifierProvider<AssignmentNotifier, Map<String, AssignmentModel?>>((ref) {
  final assignmentService = ref.watch(studentHubAssignmentServiceProvider);
  return AssignmentNotifier(assignmentService);
});

class AssignmentNotifier extends StateNotifier<Map<String, AssignmentModel?>> {
  final StudentHubAssignmentService _assignmentService;

  AssignmentNotifier(this._assignmentService) : super({});

  // Create Assignment
  Future<AssignmentModel?> createAssignment({
    required String groupId,
    required String title,
    required String description,
    required DateTime dueDate,
    String? fileUrl,
  }) async {
    try {
      final assignment = await _assignmentService.createAssignment(
        groupId: groupId,
        title: title,
        description: description,
        dueDate: dueDate,
        fileUrl: fileUrl,
      );

      state = {...state, assignment.assignmentId: assignment};
      return assignment;
    } catch (e) {
      print('❌ Create Assignment Error: $e');
      rethrow;
    }
  }

  // Submit Assignment
  Future<SubmissionModel?> submitAssignment({
    required String groupId,
    required String assignmentId,
    required String userId,
    String? fileUrl,
  }) async {
    try {
      final submission = await _assignmentService.submitAssignment(
        groupId: groupId,
        assignmentId: assignmentId,
        userId: userId,
        fileUrl: fileUrl,
      );

      return submission;
    } catch (e) {
      print('❌ Submit Assignment Error: $e');
      rethrow;
    }
  }

  // Update Assignment
  Future<void> updateAssignment({
    required String groupId,
    required String assignmentId,
    String? title,
    String? description,
    DateTime? dueDate,
    String? fileUrl,
  }) async {
    try {
      await _assignmentService.updateAssignment(
        groupId: groupId,
        assignmentId: assignmentId,
        title: title,
        description: description,
        dueDate: dueDate,
        fileUrl: fileUrl,
      );

      // Refresh
      final assignment = await _assignmentService.getAssignmentById(
        groupId: groupId,
        assignmentId: assignmentId,
      );

      if (assignment != null) {
        state = {...state, assignmentId: assignment};
      }
    } catch (e) {
      print('❌ Update Assignment Error: $e');
      rethrow;
    }
  }

  // Delete Assignment
  Future<void> deleteAssignment({
    required String groupId,
    required String assignmentId,
  }) async {
    try {
      await _assignmentService.deleteAssignment(
        groupId: groupId,
        assignmentId: assignmentId,
      );

      state = {...state, assignmentId: null};
    } catch (e) {
      print('❌ Delete Assignment Error: $e');
      rethrow;
    }
  }

  // Grade Submission
  Future<void> gradeSubmission({
    required String groupId,
    required String submissionId,
    required int score,
  }) async {
    try {
      await _assignmentService.gradeSubmission(
        groupId: groupId,
        submissionId: submissionId,
        score: score,
      );
    } catch (e) {
      print('❌ Grade Submission Error: $e');
      rethrow;
    }
  }
}

