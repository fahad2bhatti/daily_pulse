import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student_hub/assignment_model.dart';
import '../providers/student_hub_assignment_provider.dart';
import '../providers/student_hub_user_provider.dart';
import 'student_hub_assignment_detail_screen.dart';

class StudentHubAssignmentListScreen extends ConsumerWidget {
  final String groupId;

  const StudentHubAssignmentListScreen({
    super.key,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsyncValue = ref.watch(groupAssignmentsProvider(groupId));
    final currentUser = ref.watch(currentSHUserNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Assignments',
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
      body: assignmentsAsyncValue.when(
        data: (assignments) {
          if (assignments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No assignments yet',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentUser?.isTeacher ?? false
                        ? 'Create an assignment to get started'
                        : 'Waiting for assignments',
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
                      final assignment = assignments[index];
                      return _buildAssignmentCard(
                        context,
                        assignment,
                        groupId,
                        currentUser,
                      );
                    },
                    childCount: assignments.length,
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

  Widget _buildAssignmentCard(
    BuildContext context,
    AssignmentModel assignment,
    String groupId,
    dynamic currentUser,
  ) {
    final isOverdue = assignment.isOverdue;
    final daysLeft = assignment.dueDate.difference(DateTime.now()).inDays;

    String statusText;
    Color statusColor;

    if (isOverdue) {
      statusText = 'OVERDUE';
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
                isOverdue ? Colors.red[700]! : const Color(0xFF6366F1),
                isOverdue ? Colors.red[500]! : const Color(0xFF8B5CF6),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(
              Icons.assignment,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        title: Text(
          assignment.title,
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
            Text(
              assignment.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 12, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  '${assignment.dueDate.day}/${assignment.dueDate.month}/${assignment.dueDate.year}',
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
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
         onTap: () {
           Navigator.of(context).push(
             MaterialPageRoute(
               builder: (_) =>StudentHubAssignmentDetailScreen(
                 assignment.assignmentId,
                 assignment.groupId,
               )
             ),
           );
         },
      ),
    );
  }
}

