import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../providers/student_hub_quiz_provider.dart';
import '../providers/student_hub_user_provider.dart';

class StudentHubQuizAttemptScreen extends ConsumerStatefulWidget {
  final String quizId;
  final String groupId;

  const StudentHubQuizAttemptScreen({
    required this.quizId,
    required this.groupId,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StudentHubQuizAttemptScreenState();
}

class _StudentHubQuizAttemptScreenState
    extends ConsumerState<StudentHubQuizAttemptScreen> {
  bool _hasStarted = false;

  @override
  Widget build(BuildContext context) {
    if (_hasStarted) {
      return _QuizAttemptWidget(quizId: widget.quizId, groupId: widget.groupId);
    }

    final quizAsyncValue = ref.watch(quizDetailProvider((widget.groupId, widget.quizId)));
    final submissionAsyncValue =
        ref.watch(myQuizSubmissionProvider((widget.groupId, widget.quizId)));

    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quiz',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: quizAsyncValue.when(
        data: (quiz) {
          if (quiz == null) {
            return const Center(
              child: Text(
                'Quiz not found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return submissionAsyncValue.when(
            data: (submission) {
              // Already attempted
              if (submission != null) {
                return _buildResultCard(quiz, submission);
              }

              // Not attempted - show quiz info
              final isDueSoon =
                  quiz.dueDate.isBefore(DateTime.now().add(const Duration(days: 1)));

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Quiz Info Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2329),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[800]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            quiz.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Questions count
                          Row(
                            children: [
                              const Icon(Icons.help_outline,
                                  size: 18, color: Color(0xFF6366F1)),
                              const SizedBox(width: 8),
                              Text(
                                '${quiz.questions.length} Questions',
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Time limit
                          Row(
                            children: [
                              const Icon(Icons.timer_outlined,
                                  size: 18, color: Color(0xFF6366F1)),
                              const SizedBox(width: 8),
                              Text(
                                '${quiz.timeLimitMin} minutes',
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Due date
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 18, color: Color(0xFF6366F1)),
                              const SizedBox(width: 8),
                              Text(
                                'Due: ${DateFormat('MMM dd, yyyy').format(quiz.dueDate)}',
                                style: TextStyle(
                                  color: isDueSoon ? Colors.orange : Colors.grey[300],
                                  fontSize: 14,
                                  fontWeight: isDueSoon
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Warning
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.orange.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline,
                                    color: Colors.orange, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Once started, timer cannot be paused',
                                    style: TextStyle(
                                      color: Colors.orange[300],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Start Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() => _hasStarted = true);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Start Quiz',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => Center(
              child: Text(
                'Error: ${error.toString()}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error: ${error.toString()}',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(dynamic quiz, dynamic submission) {
    final totalQuestions = quiz.questions.length;
    final score = submission.score;
    final percentage = (score / totalQuestions * 100).toStringAsFixed(0);
    final isPassed = double.parse(percentage) >= 60;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          // Result Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: isPassed
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: isPassed ? Colors.green : Colors.red,
                width: 3,
              ),
            ),
            child: Icon(
              isPassed ? Icons.check_circle : Icons.cancel,
              size: 60,
              color: isPassed ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'Quiz Already Attempted',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Score Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2329),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[800]!),
            ),
            child: Column(
              children: [
                Text(
                  'Your Score',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '$score/$totalQuestions',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: (isPassed ? Colors.green : Colors.red)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (isPassed ? Colors.green : Colors.red)
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '$percentage%',
                    style: TextStyle(
                      color: isPassed ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Review Answers
          Text(
            'Review Your Answers',
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(
            quiz.questions.length,
            (index) {
              final question = quiz.questions[index];
              final userAnswer = submission.answers[index];
              final isCorrect = userAnswer == question.correctIndex;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCorrect
                        ? Colors.green.withValues(alpha: 0.3)
                        : Colors.red.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Q${index + 1}: ${question.question}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Correct: ${question.options[question.correctIndex]}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (!isCorrect) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Your Answer: ${question.options[userAnswer]}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Back Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Back to Quizzes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizAttemptWidget extends ConsumerStatefulWidget {
  final String quizId;
  final String groupId;

  const _QuizAttemptWidget({required this.quizId, required this.groupId});

  @override
  ConsumerState<_QuizAttemptWidget> createState() =>
      _QuizAttemptWidgetState();
}

class _QuizAttemptWidgetState extends ConsumerState<_QuizAttemptWidget> {
  late Timer _timer;
  late int _secondsRemaining;
  int _currentQuestionIndex = 0;
  late List<int?> _selectedAnswers;
  bool _isSubmitted = false;
  late int _totalQuestions;

  @override
  void initState() {
    super.initState();
    _initializeQuiz();
  }

   void _initializeQuiz() {
     final quizAsyncValue = ref.read(quizDetailProvider((widget.groupId, widget.quizId)));
     quizAsyncValue.whenData((quiz) {
       if (quiz != null) {
         _totalQuestions = quiz.questions.length;
         _secondsRemaining = quiz.timeLimitMin * 60;
         _selectedAnswers =
             List<int?>.filled(_totalQuestions, null);
         _startTimer();
       }
     });
   }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _submitQuiz();
      }
    });
  }

   void _submitQuiz() async {
     _timer.cancel();

     final quizAsyncValue = ref.read(quizDetailProvider((widget.groupId, widget.quizId)));
     quizAsyncValue.whenData((quiz) async {
       if (quiz != null) {
         final currentUser = ref.read(currentSHUserNotifierProvider);
         if (currentUser != null) {
           try {
             await ref
                 .read(studentHubQuizServiceProvider)
                 .submitQuiz(
                   groupId: widget.groupId,
                   quizId: widget.quizId,
                   userId: currentUser.uid,
                   answers: _selectedAnswers.cast<int>(),
                 );

             if (mounted) {
               setState(() {
                 _isSubmitted = true;
               });
               ref.invalidate(myQuizSubmissionProvider((widget.groupId, widget.quizId)));
             }
           } catch (e) {
             if (mounted) {
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text('Error submitting quiz: ${e.toString()}')),
               );
             }
           }
         }
       }
     });
   }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Color _getTimerColor() {
    if (_secondsRemaining > 60) return Colors.white;
    return Colors.red;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmitted) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F1419),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
         body: ref.watch(myQuizSubmissionProvider((widget.groupId, widget.quizId))).whenData(
           (submission) {
             if (submission != null) {
               return ref.watch(quizDetailProvider((widget.groupId, widget.quizId))).whenData(
                 (quiz) {
                   return _buildResultView(quiz!, submission);
                 },
               ).when(
                data: (data) => data,
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, _) => Center(
                  child: Text('Error: ${error.toString()}',
                      style: const TextStyle(color: Colors.red)),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ).when(
          data: (data) => data,
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, _) => Center(
            child: Text('Error: ${error.toString()}',
                style: const TextStyle(color: Colors.red)),
          ),
        ),
      );
    }

     return ref.watch(quizDetailProvider((widget.groupId, widget.quizId))).when(
       data: (quiz) {
         if (quiz == null) {
           return Scaffold(
             backgroundColor: const Color(0xFF0F1419),
             body: const Center(
               child: Text(
                 'Quiz not found',
                 style: TextStyle(color: Colors.white),
               ),
             ),
           );
         }

         final question = quiz.questions[_currentQuestionIndex];

         return PopScope(
           canPop: false,
           onPopInvokedWithResult: (didPop, result) async {
             if (didPop) return;
             final confirm = await showDialog<bool>(
               context: context,
               builder: (context) => AlertDialog(
                 backgroundColor: const Color(0xFF1E2329),
                 title: const Text(
                   'Exit Quiz?',
                   style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                 ),
                 content: const Text(
                   'Your progress will be lost if you exit',
                   style: TextStyle(color: Colors.grey),
                 ),
                 actions: [
                   TextButton(
                     onPressed: () => Navigator.pop(context, false),
                     child: const Text('Continue',
                         style: TextStyle(color: Color(0xFF6366F1))),
                   ),
                   TextButton(
                     onPressed: () => Navigator.pop(context, true),
                     child: const Text('Exit', style: TextStyle(color: Colors.red)),
                   ),
                 ],
               ),
             );
             if (confirm ?? false) {
               if (mounted) Navigator.pop(context);
             }
           },
           child: Scaffold(
            backgroundColor: const Color(0xFF0F1419),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'Question ${_currentQuestionIndex + 1}/$_totalQuestions',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Column(
              children: [
                // Timer Bar
                Container(
                  color: Colors.grey[900],
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Time Remaining',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getTimerColor().withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getTimerColor()
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              _formatTime(_secondsRemaining),
                              style: TextStyle(
                                color: _getTimerColor(),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _secondsRemaining /
                              (quiz.timeLimitMin * 60),
                          minHeight: 6,
                          backgroundColor: Colors.grey[800],
                          valueColor: AlwaysStoppedAnimation(
                            _getTimerColor(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Question
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question.question,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ...List.generate(
                          question.options.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildOptionButton(
                              option: question.options[index],
                              index: index,
                              isSelected:
                                  _selectedAnswers[_currentQuestionIndex] ==
                                      index,
                              onTap: () {
                                setState(() {
                                  _selectedAnswers[_currentQuestionIndex] =
                                      index;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Navigation
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Question Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _totalQuestions,
                          (index) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  _selectedAnswers[index] != null
                                      ? const Color(0xFF6366F1)
                                      : Colors.grey[800],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (_currentQuestionIndex > 0)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(
                                      () => _currentQuestionIndex--);
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFF6366F1),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                ),
                                child: const Text(
                                  'Previous',
                                  style: TextStyle(
                                    color: Color(0xFF6366F1),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          if (_currentQuestionIndex > 0)
                            const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (_currentQuestionIndex <
                                    _totalQuestions - 1) {
                                  setState(() =>
                                      _currentQuestionIndex++);
                                } else {
                                  _submitQuiz();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF6366F1),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                              ),
                              child: Text(
                                _currentQuestionIndex <
                                        _totalQuestions - 1
                                    ? 'Next'
                                    : 'Submit Quiz',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: const Color(0xFF0F1419),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: const Color(0xFF0F1419),
        body: Center(
          child: Text(
            'Error: ${error.toString()}',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required String option,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final letters = ['A', 'B', 'C', 'D'];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6366F1)
              : Colors.grey[900],
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6366F1)
                : Colors.grey[800]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white
                    : Colors.grey[800],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  letters[index],
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF6366F1)
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[300],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView(dynamic quiz, dynamic submission) {
    final totalQuestions = _totalQuestions;
    final score = submission.score;
    final percentage = (score / totalQuestions * 100).toStringAsFixed(0);
    final isPassed = double.parse(percentage) >= 60;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          // Result Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: isPassed
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: isPassed ? Colors.green : Colors.red,
                width: 3,
              ),
            ),
            child: Icon(
              isPassed ? Icons.check_circle : Icons.cancel,
              size: 60,
              color: isPassed ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 24),

          // Message
          Text(
            isPassed ? 'Great Job! 🎉' : 'Try Again! 💪',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Score Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2329),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[800]!),
            ),
            child: Column(
              children: [
                Text(
                  'Your Score',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '$score/$totalQuestions',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: (isPassed ? Colors.green : Colors.red)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (isPassed ? Colors.green : Colors.red)
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '$percentage%',
                    style: TextStyle(
                      color: isPassed ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Back Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Back to Quizzes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

