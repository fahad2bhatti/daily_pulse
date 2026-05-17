import 'package:cloud_firestore/cloud_firestore.dart';

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctIndex: json['correctIndex'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correctIndex': correctIndex,
    };
  }
}

class QuizModel {
  final String quizId;
  final String groupId;
  final String title;
  final List<QuizQuestion> questions;
  final int timeLimitMin;
  final DateTime dueDate;
  final DateTime createdAt;

  QuizModel({
    required this.quizId,
    required this.groupId,
    required this.title,
    required this.questions,
    required this.timeLimitMin,
    required this.dueDate,
    required this.createdAt,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      quizId: json['quizId'] as String,
      groupId: json['groupId'] as String,
      title: json['title'] as String,
      questions: (json['questions'] as List)
          .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
      timeLimitMin: json['timeLimitMin'] as int,
      dueDate: (json['dueDate'] as Timestamp).toDate(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quizId': quizId,
      'groupId': groupId,
      'title': title,
      'questions': questions.map((q) => q.toJson()).toList(),
      'timeLimitMin': timeLimitMin,
      'dueDate': Timestamp.fromDate(dueDate),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  int get totalMarks => questions.length;
  bool get isOverdue => DateTime.now().isAfter(dueDate);
}