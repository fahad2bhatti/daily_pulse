import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student_hub/quiz_model.dart';
import '../models/student_hub/submission_model.dart';
import '../services/student_hub_quiz_service.dart';
import 'student_hub_user_provider.dart';

// 🔧 Service Provider
final studentHubQuizServiceProvider =
    Provider((ref) => StudentHubQuizService());

// 📋 Get Group Quizzes
final groupQuizzesProvider = FutureProvider.family<List<QuizModel>, String>((ref, groupId) async {
  final quizService = ref.watch(studentHubQuizServiceProvider);
  return await quizService.getGroupQuizzes(groupId);
});

// 🔍 Get Single Quiz
final quizProvider = FutureProvider.family<QuizModel?, (String, String)>((ref, params) async {
  final quizService = ref.watch(studentHubQuizServiceProvider);
  return await quizService.getQuizById(
    groupId: params.$1,
    quizId: params.$2,
  );
});

// 🔍 Get Quiz Detail
final quizDetailProvider = FutureProvider.family<QuizModel?, (String, String)>((ref, params) async {
  final quizService = ref.watch(studentHubQuizServiceProvider);
  return await quizService.getQuizById(
    groupId: params.$1,
    quizId: params.$2,
  );
});

// 📮 Get Student's Quiz Submission (current user)
final myQuizSubmissionProvider = FutureProvider.family<SubmissionModel?, (String, String)>((ref, params) async {
  final quizService = ref.watch(studentHubQuizServiceProvider);
  final currentUser = ref.watch(currentSHUserNotifierProvider);

  if (currentUser == null) return null;

  return await quizService.getQuizSubmission(
    groupId: params.$1,
    quizId: params.$2,
    userId: currentUser.uid,
  );
});

// 📊 Get Quiz Statistics
final quizStatsProvider = FutureProvider.family<Map<String, dynamic>, (String, String)>((ref, params) async {
  final quizService = ref.watch(studentHubQuizServiceProvider);
  return await quizService.getQuizStats(
    groupId: params.$1,
    quizId: params.$2,
  );
});

// 🎯 Check if student can attempt quiz
final canAttemptQuizProvider = FutureProvider.family<bool, (String, String, String)>((ref, params) async {
  final quizService = ref.watch(studentHubQuizServiceProvider);
  return await quizService.canAttemptQuiz(
    groupId: params.$1,
    quizId: params.$2,
    userId: params.$3,
  );
});

// 🔄 Quiz Notifier
final quizNotifierProvider = StateNotifierProvider<QuizNotifier, Map<String, QuizModel?>>((ref) {
  final quizService = ref.watch(studentHubQuizServiceProvider);
  return QuizNotifier(quizService);
});

class QuizNotifier extends StateNotifier<Map<String, QuizModel?>> {
  final StudentHubQuizService _quizService;

  QuizNotifier(this._quizService) : super({});

  // Create Quiz
  Future<QuizModel?> createQuiz({
    required String groupId,
    required String title,
    required List<QuizQuestion> questions,
    required int timeLimitMin,
    required DateTime dueDate,
  }) async {
    try {
      final quiz = await _quizService.createQuiz(
        groupId: groupId,
        title: title,
        questions: questions,
        timeLimitMin: timeLimitMin,
        dueDate: dueDate,
      );

      state = {...state, quiz.quizId: quiz};
      return quiz;
    } catch (e) {
      print('❌ Create Quiz Error: $e');
      rethrow;
    }
  }

  // Submit Quiz (Auto-graded)
  Future<SubmissionModel?> submitQuiz({
    required String groupId,
    required String quizId,
    required String userId,
    required List<int> answers,
  }) async {
    try {
      final submission = await _quizService.submitQuiz(
        groupId: groupId,
        quizId: quizId,
        userId: userId,
        answers: answers,
      );

      return submission;
    } catch (e) {
      print('❌ Submit Quiz Error: $e');
      rethrow;
    }
  }

  // Update Quiz
  Future<void> updateQuiz({
    required String groupId,
    required String quizId,
    String? title,
    List<QuizQuestion>? questions,
    int? timeLimitMin,
    DateTime? dueDate,
  }) async {
    try {
      await _quizService.updateQuiz(
        groupId: groupId,
        quizId: quizId,
        title: title,
        questions: questions,
        timeLimitMin: timeLimitMin,
        dueDate: dueDate,
      );

      // Refresh
      final quiz = await _quizService.getQuizById(
        groupId: groupId,
        quizId: quizId,
      );

      if (quiz != null) {
        state = {...state, quizId: quiz};
      }
    } catch (e) {
      print('❌ Update Quiz Error: $e');
      rethrow;
    }
  }

  // Delete Quiz
  Future<void> deleteQuiz({
    required String groupId,
    required String quizId,
  }) async {
    try {
      await _quizService.deleteQuiz(
        groupId: groupId,
        quizId: quizId,
      );

      state = {...state, quizId: null};
    } catch (e) {
      print('❌ Delete Quiz Error: $e');
      rethrow;
    }
  }

  // Get Time Remaining
  Duration getTimeRemaining(QuizModel quiz) {
    return _quizService.getTimeRemaining(quiz);
  }
}

