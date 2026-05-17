import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_hub/quiz_model.dart';
import '../models/student_hub/submission_model.dart';

class StudentHubQuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 📝 Create Quiz (Teacher ke liye)
  Future<QuizModel> createQuiz({
    required String groupId,
    required String title,
    required List<QuizQuestion> questions,
    required int timeLimitMin,
    required DateTime dueDate,
  }) async {
    try {
      final quizId =
          _firestore.collection('groups').doc(groupId).collection('quizzes').doc().id;

      final quiz = QuizModel(
        quizId: quizId,
        groupId: groupId,
        title: title,
        questions: questions,
        timeLimitMin: timeLimitMin,
        dueDate: dueDate,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('quizzes')
          .doc(quizId)
          .set(quiz.toJson());

      return quiz;
    } catch (e) {
      print('❌ Create Quiz Error: $e');
      rethrow;
    }
  }

  /// 🔍 Get All Quizzes for a Group
  Future<List<QuizModel>> getGroupQuizzes(String groupId) async {
    try {
      final querySnapshot = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('quizzes')
          .orderBy('dueDate', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => QuizModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Get Quizzes Error: $e');
      return [];
    }
  }

  /// 🔍 Get Single Quiz
  Future<QuizModel?> getQuizById({
    required String groupId,
    required String quizId,
  }) async {
    try {
      final doc = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('quizzes')
          .doc(quizId)
          .get();

      if (doc.exists) {
        return QuizModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('❌ Get Quiz Error: $e');
      return null;
    }
  }

  /// ✏️ Update Quiz (Teacher ke liye)
  Future<void> updateQuiz({
    required String groupId,
    required String quizId,
    String? title,
    List<QuizQuestion>? questions,
    int? timeLimitMin,
    DateTime? dueDate,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (title != null) updates['title'] = title;
      if (questions != null) {
        updates['questions'] = questions.map((q) => q.toJson()).toList();
      }
      if (timeLimitMin != null) updates['timeLimitMin'] = timeLimitMin;
      if (dueDate != null) updates['dueDate'] = Timestamp.fromDate(dueDate);

      if (updates.isNotEmpty) {
        await _firestore
            .collection('groups')
            .doc(groupId)
            .collection('quizzes')
            .doc(quizId)
            .update(updates);
      }
    } catch (e) {
      print('❌ Update Quiz Error: $e');
      rethrow;
    }
  }

  /// 🗑️ Delete Quiz (Teacher ke liye)
  Future<void> deleteQuiz({
    required String groupId,
    required String quizId,
  }) async {
    try {
      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('quizzes')
          .doc(quizId)
          .delete();
    } catch (e) {
      print('❌ Delete Quiz Error: $e');
      rethrow;
    }
  }

  /// 📤 Submit Quiz & Auto-Grade (Student ke liye)
  Future<SubmissionModel> submitQuiz({
    required String groupId,
    required String quizId,
    required String userId,
    required List<int> answers, // Selected option indexes
  }) async {
    try {
      final submissionId = _firestore
          .collection('groups')
          .doc(groupId)
          .collection('submissions')
          .doc()
          .id;

      final quiz = await getQuizById(
        groupId: groupId,
        quizId: quizId,
      );

      if (quiz == null) throw Exception('Quiz not found');

      // Auto-grade the quiz
      int score = 0;
      for (int i = 0; i < answers.length && i < quiz.questions.length; i++) {
        if (answers[i] == quiz.questions[i].correctIndex) {
          score++;
        }
      }

      final submission = SubmissionModel(
        submissionId: submissionId,
        refId: quizId,
        type: SubmissionType.quiz,
        userId: userId,
        status: SubmissionStatus.graded,
        score: score,
        answers: answers,
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
      print('❌ Submit Quiz Error: $e');
      rethrow;
    }
  }

  /// 👀 Get Student's Quiz Submission
  Future<SubmissionModel?> getQuizSubmission({
    required String groupId,
    required String quizId,
    required String userId,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('submissions')
          .where('refId', isEqualTo: quizId)
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: 'quiz')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return SubmissionModel.fromJson(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      print('❌ Get Quiz Submission Error: $e');
      return null;
    }
  }

  /// 📋 Get All Submissions for Quiz (Teacher ke liye)
  Future<List<SubmissionModel>> getQuizSubmissions({
    required String groupId,
    required String quizId,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('submissions')
          .where('refId', isEqualTo: quizId)
          .where('type', isEqualTo: 'quiz')
          .get();

      return querySnapshot.docs
          .map((doc) => SubmissionModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Get Quiz Submissions Error: $e');
      return [];
    }
  }

  /// 📊 Get Quiz Statistics
  Future<Map<String, dynamic>> getQuizStats({
    required String groupId,
    required String quizId,
  }) async {
    try {
      final quiz = await getQuizById(
        groupId: groupId,
        quizId: quizId,
      );

      if (quiz == null) return {};

      final submissions = await getQuizSubmissions(
        groupId: groupId,
        quizId: quizId,
      );

      if (submissions.isEmpty) {
        return {
          'totalAttempts': 0,
          'averageScore': 0.0,
          'highestScore': 0,
          'lowestScore': 0,
          'maxScore': quiz.totalMarks,
        };
      }

      final scores = submissions
          .where((s) => s.score != null)
          .map((s) => s.score!)
          .toList();

      double avg = scores.isEmpty ? 0 : scores.reduce((a, b) => a + b) / scores.length;
      int highest = scores.isEmpty ? 0 : scores.reduce((a, b) => a > b ? a : b);
      int lowest = scores.isEmpty ? 0 : scores.reduce((a, b) => a < b ? a : b);

      return {
        'totalAttempts': submissions.length,
        'averageScore': (avg * 100 / quiz.totalMarks).toStringAsFixed(2),
        'highestScore': highest,
        'lowestScore': lowest,
        'maxScore': quiz.totalMarks,
      };
    } catch (e) {
      print('❌ Get Quiz Stats Error: $e');
      return {};
    }
  }

  /// 🔄 Check Quiz Availability (can student attempt?)
  Future<bool> canAttemptQuiz({
    required String groupId,
    required String quizId,
    required String userId,
  }) async {
    try {
      final quiz = await getQuizById(
        groupId: groupId,
        quizId: quizId,
      );

      if (quiz == null) return false;

      // Check if quiz deadline passed
      if (DateTime.now().isAfter(quiz.dueDate)) {
        return false; // Quiz expired
      }

      // Check if student already submitted
      final existingSubmission = await getQuizSubmission(
        groupId: groupId,
        quizId: quizId,
        userId: userId,
      );

      return existingSubmission == null; // Can attempt if no submission
    } catch (e) {
      print('❌ Can Attempt Quiz Error: $e');
      return false;
    }
  }

  /// ⏱️ Calculate Time Remaining for Quiz
  Duration getTimeRemaining(QuizModel quiz) {
    final now = DateTime.now();
    if (now.isAfter(quiz.dueDate)) {
      return Duration.zero;
    }
    return quiz.dueDate.difference(now);
  }
}

