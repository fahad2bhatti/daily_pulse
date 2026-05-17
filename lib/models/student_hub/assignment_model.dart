import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentModel {
  final String assignmentId;
  final String groupId;
  final String title;
  final String description;
  final String? fileUrl;
  final DateTime dueDate;
  final DateTime createdAt;

  AssignmentModel({
    required this.assignmentId,
    required this.groupId,
    required this.title,
    required this.description,
    this.fileUrl,
    required this.dueDate,
    required this.createdAt,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      assignmentId: json['assignmentId'] as String,
      groupId: json['groupId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      fileUrl: json['fileUrl'] as String?,
      dueDate: (json['dueDate'] as Timestamp).toDate(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assignmentId': assignmentId,
      'groupId': groupId,
      'title': title,
      'description': description,
      'fileUrl': fileUrl,
      'dueDate': Timestamp.fromDate(dueDate),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  bool get isOverdue => DateTime.now().isAfter(dueDate);

  Duration get timeRemaining => dueDate.difference(DateTime.now());
}