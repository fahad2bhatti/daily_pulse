import 'package:cloud_firestore/cloud_firestore.dart';

enum SubmissionType { assignment, quiz }
enum SubmissionStatus { pending, submitted, graded, late }

class SubmissionModel {
  final String submissionId;
  final String refId;          // assignmentId or quizId
  final SubmissionType type;
  final String userId;
  final SubmissionStatus status;
  final int? score;            // out of total questions (quiz) or marks (assignment)
  final String? fileUrl;       // for assignment submissions
  final List<int>? answers;    // selected option indexes (quiz only)
  final DateTime submittedAt;

  SubmissionModel({
    required this.submissionId,
    required this.refId,
    required this.type,
    required this.userId,
    required this.status,
    this.score,
    this.fileUrl,
    this.answers,
    required this.submittedAt,
  });

  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    return SubmissionModel(
      submissionId: json['submissionId'] as String,
      refId: json['refId'] as String,
      type: json['type'] == 'quiz' ? SubmissionType.quiz : SubmissionType.assignment,
      userId: json['userId'] as String,
      status: SubmissionStatus.values.firstWhere(
            (s) => s.name == json['status'],
        orElse: () => SubmissionStatus.pending,
      ),
      score: json['score'] as int?,
      fileUrl: json['fileUrl'] as String?,
      answers: json['answers'] != null
          ? List<int>.from(json['answers'] as List)
          : null,
      submittedAt: (json['submittedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'submissionId': submissionId,
      'refId': refId,
      'type': type.name,
      'userId': userId,
      'status': status.name,
      'score': score,
      'fileUrl': fileUrl,
      'answers': answers,
      'submittedAt': Timestamp.fromDate(submittedAt),
    };
  }

  bool get isGraded => status == SubmissionStatus.graded;
}