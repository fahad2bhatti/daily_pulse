import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_hub/assignment_model.dart';
import '../models/student_hub/submission_model.dart';

class StudentHubAssignmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 📝 Create Assignment (Teacher ke liye)
  Future<AssignmentModel> createAssignment({
    required String groupId,
    required String title,
    required String description,
    required DateTime dueDate,
    String? fileUrl,
  }) async {
    try {
      final assignmentId =
          _firestore.collection('groups').doc(groupId).collection('assignments').doc().id;

      final assignment = AssignmentModel(
        assignmentId: assignmentId,
        groupId: groupId,
        title: title,
        description: description,
        fileUrl: fileUrl,
        dueDate: dueDate,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('assignments')
          .doc(assignmentId)
          .set(assignment.toJson());

      return assignment;
    } catch (e) {
      print('❌ Create Assignment Error: $e');
      rethrow;
    }
  }

  /// 🔍 Get All Assignments for a Group
  Future<List<AssignmentModel>> getGroupAssignments(String groupId) async {
    try {
      final querySnapshot = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('assignments')
          .orderBy('dueDate', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => AssignmentModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Get Assignments Error: $e');
      return [];
    }
  }

  /// 🔍 Get Single Assignment
  Future<AssignmentModel?> getAssignmentById({
    required String groupId,
    required String assignmentId,
  }) async {
    try {
      final doc = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('assignments')
          .doc(assignmentId)
          .get();

      if (doc.exists) {
        return AssignmentModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('❌ Get Assignment Error: $e');
      return null;
    }
  }

  /// ✏️ Update Assignment (Teacher ke liye)
  Future<void> updateAssignment({
    required String groupId,
    required String assignmentId,
    String? title,
    String? description,
    DateTime? dueDate,
    String? fileUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (dueDate != null) updates['dueDate'] = Timestamp.fromDate(dueDate);
      if (fileUrl != null) updates['fileUrl'] = fileUrl;

      if (updates.isNotEmpty) {
        await _firestore
            .collection('groups')
            .doc(groupId)
            .collection('assignments')
            .doc(assignmentId)
            .update(updates);
      }
    } catch (e) {
      print('❌ Update Assignment Error: $e');
      rethrow;
    }
  }

  /// 🗑️ Delete Assignment (Teacher ke liye)
  Future<void> deleteAssignment({
    required String groupId,
    required String assignmentId,
  }) async {
    try {
      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('assignments')
          .doc(assignmentId)
          .delete();
    } catch (e) {
      print('❌ Delete Assignment Error: $e');
      rethrow;
    }
  }

  /// 📤 Submit Assignment (Student ke liye)
  Future<SubmissionModel> submitAssignment({
    required String groupId,
    required String assignmentId,
    required String userId,
    String? fileUrl,
  }) async {
    try {
      final submissionId = _firestore
          .collection('groups')
          .doc(groupId)
          .collection('submissions')
          .doc()
          .id;

      final assignment = await getAssignmentById(
        groupId: groupId,
        assignmentId: assignmentId,
      );

      if (assignment == null) throw Exception('Assignment not found');

      final isLate = DateTime.now().isAfter(assignment.dueDate);

      final submission = SubmissionModel(
        submissionId: submissionId,
        refId: assignmentId,
        type: SubmissionType.assignment,
        userId: userId,
        status: isLate ? SubmissionStatus.late : SubmissionStatus.submitted,
        fileUrl: fileUrl,
        submittedAt: DateTime.now(),
      );

      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('submissions')
          .doc(submissionId)
          .set(submission.toJson());

      return submission;
    } catch (e) {
      print('❌ Submit Assignment Error: $e');
      rethrow;
    }
  }

  /// 👀 Get Student's Submission for Assignment
  Future<SubmissionModel?> getSubmission({
    required String groupId,
    required String assignmentId,
    required String userId,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('submissions')
          .where('refId', isEqualTo: assignmentId)
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: 'assignment')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return SubmissionModel.fromJson(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      print('❌ Get Submission Error: $e');
      return null;
    }
  }

  /// 📋 Get All Submissions for Assignment (Teacher ke liye)
  Future<List<SubmissionModel>> getAssignmentSubmissions({
    required String groupId,
    required String assignmentId,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('submissions')
          .where('refId', isEqualTo: assignmentId)
          .where('type', isEqualTo: 'assignment')
          .get();

      return querySnapshot.docs
          .map((doc) => SubmissionModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Get Assignment Submissions Error: $e');
      return [];
    }
  }

  /// ✔️ Grade Submission (Teacher ke liye)
  Future<void> gradeSubmission({
    required String groupId,
    required String submissionId,
    required int score,
  }) async {
    try {
      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('submissions')
          .doc(submissionId)
          .update({
        'score': score,
        'status': 'graded',
      });
    } catch (e) {
      print('❌ Grade Submission Error: $e');
      rethrow;
    }
  }

  /// 📊 Get Assignment Statistics
  Future<Map<String, dynamic>> getAssignmentStats({
    required String groupId,
    required String assignmentId,
  }) async {
    try {
      final submissions = await getAssignmentSubmissions(
        groupId: groupId,
        assignmentId: assignmentId,
      );

      int submitted = 0;
      int graded = 0;
      int late = 0;
      int pending = 0;

      for (var sub in submissions) {
        if (sub.status == SubmissionStatus.submitted) submitted++;
        if (sub.status == SubmissionStatus.graded) graded++;
        if (sub.status == SubmissionStatus.late) late++;
        if (sub.status == SubmissionStatus.pending) pending++;
      }

      return {
        'totalSubmissions': submissions.length,
        'submitted': submitted,
        'graded': graded,
        'late': late,
        'pending': pending,
      };
    } catch (e) {
      print('❌ Get Stats Error: $e');
      return {};
    }
  }
}

