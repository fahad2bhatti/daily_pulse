import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student_hub/quiz_model.dart';
import '../providers/student_hub_quiz_provider.dart';
import '../providers/student_hub_user_provider.dart';
import 'student_hub_quiz_attempt_screen.dart';

class StudentHubQuizListScreen extends ConsumerWidget {
  final String groupId;

  const StudentHubQuizListScreen({
    super.key,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizzesAsyncValue = ref.watch(groupQuizzesProvider(groupId));
    final currentUser = ref.watch(currentSHUserNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Quizzes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: quizzesAsyncValue.when(
        data: (quizzes) {
          if (quizzes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.quiz_outlined,
                    size: 64,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No quizzes yet',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentUser?.isTeacher ?? false
                        ? 'Create a quiz to get started'
                        : 'Waiting for quizzes',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final quiz = quizzes[index];
                      return _buildQuizCard(
                        context,
                        quiz,
                        groupId,
                        currentUser,
                        ref,
                      );
                    },
                    childCount: quizzes.length,
                  ),
                ),
              ),
            ],
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

  Widget _buildQuizCard(
    BuildContext context,
    QuizModel quiz,
    String groupId,
    dynamic currentUser,
    WidgetRef ref,
  ) {
    final isOverdue = quiz.isOverdue;
    final daysLeft = quiz.dueDate.difference(DateTime.now()).inDays;

    String statusText;
    Color statusColor;

    if (isOverdue) {
      statusText = 'EXPIRED';
      statusColor = Colors.red;
    } else if (daysLeft == 0) {
      statusText = 'DUE TODAY';
      statusColor = Colors.orange;
    } else {
      statusText = '$daysLeft days left';
      statusColor = Colors.green;
    }

    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[800]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isOverdue ? Colors.orange[700]! : const Color(0xFF10B981),
                isOverdue ? Colors.orange[500]! : const Color(0xFF059669),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(
              Icons.quiz,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        title: Text(
          quiz.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.help_outline, size: 12, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  '${quiz.questions.length} questions',
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
                const SizedBox(width: 12),
                Icon(Icons.schedule, size: 12, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  '${quiz.timeLimitMin} mins',
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 12, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  '${quiz.dueDate.day}/${quiz.dueDate.month}/${quiz.dueDate.year}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const SizedBox(width: 12),
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                   decoration: BoxDecoration(
                     color: statusColor.withValues(alpha: 0.2),
                     borderRadius: BorderRadius.circular(4),
                     border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                   ),
                   child: Text(
                     statusText,
                     style: TextStyle(
                       color: statusColor,
                       fontSize: 11,
                       fontWeight: FontWeight.w600,
                     ),
                   ),
                 ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          isOverdue ? Icons.lock : Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
         onTap: () {
           if (!isOverdue && (currentUser?.isStudent ?? false)) {
             Navigator.of(context).push(
               MaterialPageRoute(
                 builder: (_) => StudentHubQuizAttemptScreen(
                   quizId: quiz.quizId,
                   groupId: groupId,
                 )
               ),
             );
           }
         },
      ),
    );
  }
}

