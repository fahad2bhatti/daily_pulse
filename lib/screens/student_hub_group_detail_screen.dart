import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/student_hub/assignment_model.dart';
import '../providers/student_hub_group_provider.dart';
import '../providers/student_hub_user_provider.dart';
import '../providers/student_hub_assignment_provider.dart';
import '../providers/student_hub_quiz_provider.dart';
import '../providers/student_hub_notification_provider.dart';
import 'student_hub_assignment_detail_screen.dart';
import 'student_hub_quiz_attempt_screen.dart';

class StudentHubGroupDetailScreen extends ConsumerStatefulWidget {
  final String groupId;

  const StudentHubGroupDetailScreen({
    super.key,
    required this.groupId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StudentHubGroupDetailScreenState();
}

class _StudentHubGroupDetailScreenState
    extends ConsumerState<StudentHubGroupDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _assignmentTitleController = TextEditingController();
  final _assignmentDescController = TextEditingController();
  final _quizTitleController = TextEditingController();
  final _quizTimeLimitController = TextEditingController();
  DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _assignmentTitleController.dispose();
    _assignmentDescController.dispose();
    _quizTitleController.dispose();
    _quizTimeLimitController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  bool _isOverdue(DateTime dueDate) {
    return dueDate.isBefore(DateTime.now());
  }

  void _showAssignmentDialog() {
    _selectedDueDate = null;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2329),
        title: const Text('Create Assignment',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _assignmentTitleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Assignment Title',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _assignmentDescController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Description',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate:
                        DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _selectedDueDate = date);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        _selectedDueDate != null
                            ? _formatDate(_selectedDueDate!)
                            : 'Select due date',
                        style: TextStyle(
                          color: _selectedDueDate != null
                              ? Colors.white
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _assignmentTitleController.clear();
              _assignmentDescController.clear();
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => _handleCreateAssignment(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
            ),
            child: const Text('Create',
                style: TextStyle(color: Colors.white, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  void _handleCreateAssignment() async {
    if (_assignmentTitleController.text.isEmpty || _selectedDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      final currentUser = ref.read(currentSHUserNotifierProvider);
      if (currentUser == null) throw Exception('User not found');

      final assignment = AssignmentModel(
        assignmentId: '',
        title: _assignmentTitleController.text.trim(),
        description: _assignmentDescController.text.trim(),
        groupId: widget.groupId,
        dueDate: _selectedDueDate!,
        fileUrl: null,
        createdAt: DateTime.now(),
      );

       await ref.read(studentHubAssignmentServiceProvider).createAssignment(
             title: assignment.title,
             description: assignment.description,
             groupId: assignment.groupId,
             dueDate: assignment.dueDate,
           );

      // Schedule notifications
      await ref
          .read(studentHubNotificationServiceProvider)
          .scheduleAssignmentNotifications(assignment, currentUser.uid);

      // Send group notification
      await ref
          .read(studentHubNotificationServiceProvider)
          .sendGroupNotification(
            widget.groupId,
            'New Assignment',
            assignment.title,
          );

       if (mounted) {
         Navigator.pop(context);
         _assignmentTitleController.clear();
         _assignmentDescController.clear();
         ref.invalidate(groupAssignmentsProvider(widget.groupId));
       }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _showQuizDialog() {
    _selectedDueDate = null;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2329),
        title: const Text('Create Quiz',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _quizTitleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Quiz Title',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _quizTimeLimitController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Time limit (minutes)',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate:
                        DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _selectedDueDate = date);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        _selectedDueDate != null
                            ? _formatDate(_selectedDueDate!)
                            : 'Select due date',
                        style: TextStyle(
                          color: _selectedDueDate != null
                              ? Colors.white
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _quizTitleController.clear();
              _quizTimeLimitController.clear();
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => _handleCreateQuiz(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
            ),
            child: const Text('Create',
                style: TextStyle(color: Colors.white, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  void _handleCreateQuiz() async {
    if (_quizTitleController.text.isEmpty ||
        _quizTimeLimitController.text.isEmpty ||
        _selectedDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      final currentUser = ref.read(currentSHUserNotifierProvider);
      if (currentUser == null) throw Exception('User not found');

       await ref.read(studentHubQuizServiceProvider).createQuiz(
        groupId: widget.groupId,
        title: _quizTitleController.text.trim(),
        questions: [],
        timeLimitMin:
            int.tryParse(_quizTimeLimitController.text.trim()) ?? 30,
        dueDate: _selectedDueDate!,
      );

      // Send group notification
      await ref
          .read(studentHubNotificationServiceProvider)
          .sendGroupNotification(
            widget.groupId,
            'New Quiz',
            _quizTitleController.text.trim(),
          );

       if (mounted) {
         Navigator.pop(context);
         _quizTitleController.clear();
         _quizTimeLimitController.clear();
         ref.invalidate(groupQuizzesProvider(widget.groupId));

         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
             content: Text('Quiz created! Students will be notified.'),
             backgroundColor: Colors.green,
           ),
         );
       }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _showInviteCodeDialog(String inviteCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2329),
        title: const Text('Group Invite Code',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                inviteCode,
                style: const TextStyle(
                  color: Color(0xFF6366F1),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Share this code with students to add them to the group',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
            ),
            child: const Text('Close',
                style: TextStyle(color: Colors.white, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupAsyncValue = ref.watch(groupProvider(widget.groupId));
    final currentUser = ref.watch(currentSHUserNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: groupAsyncValue.when(
          data: (group) => Text(
            group?.name ?? 'Group',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        actions: [
          groupAsyncValue.when(
            data: (group) {
              final isAdmin = currentUser?.uid == group?.adminUid;
              if (isAdmin && group != null) {
                return IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.white),
                  onPressed: () =>
                      _showInviteCodeDialog(group.inviteCode),
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: groupAsyncValue.when(
        data: (group) {
          if (group == null) {
            return const Center(
              child: Text(
                'Group not found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final isAdmin = currentUser?.uid == group.adminUid;

          return Column(
            children: [
              // TabBar
              Container(
                color: Colors.grey[900],
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Assignments'),
                    Tab(text: 'Quizzes'),
                    Tab(text: 'Members'),
                  ],
                  labelColor: const Color(0xFF6366F1),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xFF6366F1),
                ),
              ),
              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Assignments Tab
                    _buildAssignmentsTab(group, isAdmin),
                    // Quizzes Tab
                    _buildQuizzesTab(group, isAdmin),
                    // Members Tab
                    _buildMembersTab(group, isAdmin),
                  ],
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
      floatingActionButton: _tabController.index == 0
          ? (currentUser?.isTeacher ?? false
              ? FloatingActionButton(
                  onPressed: _showAssignmentDialog,
                  backgroundColor: const Color(0xFF6366F1),
                  child: const Icon(Icons.add),
                )
              : null)
          : _tabController.index == 1
              ? (currentUser?.isTeacher ?? false
                  ? FloatingActionButton(
                      onPressed: _showQuizDialog,
                      backgroundColor: const Color(0xFF6366F1),
                      child: const Icon(Icons.add),
                    )
                  : null)
              : null,
    );
  }

   Widget _buildAssignmentsTab(dynamic group, bool isAdmin) {
     return ref.watch(groupAssignmentsProvider(widget.groupId)).when(
      data: (assignments) {
        if (assignments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_outlined,
                    size: 64, color: Colors.grey[700]),
                const SizedBox(height: 16),
                Text(
                  'No assignments yet',
                  style: TextStyle(color: Colors.grey[400], fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: assignments.length,
          itemBuilder: (context, index) {
            final assignment = assignments[index];
            final isOverdue = _isOverdue(assignment.dueDate);

            return Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  assignment.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Due: ${_formatDate(assignment.dueDate)}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOverdue
                              ? Colors.red.withValues(alpha: 0.1)
                              : Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isOverdue ? 'Overdue' : 'On Time',
                          style: TextStyle(
                            color: isOverdue ? Colors.red : Colors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          StudentHubAssignmentDetailScreen(
                            assignment.assignmentId,
                            widget.groupId,
                          )
                    ),
                  );
                },
              ),
            );
          },
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
  }

   Widget _buildQuizzesTab(dynamic group, bool isAdmin) {
     return ref.watch(groupQuizzesProvider(widget.groupId)).when(
      data: (quizzes) {
        if (quizzes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.quiz_outlined, size: 64, color: Colors.grey[700]),
                const SizedBox(height: 16),
                Text(
                  'No quizzes yet',
                  style: TextStyle(color: Colors.grey[400], fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            final isOverdue = _isOverdue(quiz.dueDate);

            return Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  quiz.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.timer_outlined,
                              size: 14, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text(
                            '${quiz.timeLimitMin} mins',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Due: ${_formatDate(quiz.dueDate)}',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOverdue
                              ? Colors.red.withValues(alpha: 0.1)
                              : Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isOverdue ? 'Overdue' : 'On Time',
                          style: TextStyle(
                            color: isOverdue ? Colors.red : Colors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          StudentHubQuizAttemptScreen(
                            quizId: quiz.quizId,
                            groupId: widget.groupId,
                          )
                    ),
                  );
                },
              ),
            );
          },
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
  }

  Widget _buildMembersTab(dynamic group, bool isAdmin) {
    final currentUser = ref.watch(currentSHUserNotifierProvider);
    return ref.watch(groupMembersProvider(widget.groupId)).when(
      data: (members) {
        if (members.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey[700]),
                const SizedBox(height: 16),
                Text(
                  'No members yet',
                  style: TextStyle(color: Colors.grey[400], fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            final canRemove = isAdmin && member.adminUid != group.adminUid;

            return Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF6366F1),
                  child: Text(
                    member.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  member.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  group.isAdmin(currentUser?.uid ?? '') ? 'Admin' : 'Member',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                trailing: canRemove
                    ? IconButton(
                        icon: const Icon(Icons.remove_circle_outline,
                            color: Colors.red),
                        onPressed: () {
                          // TODO: Implement remove member
                        },
                      )
                    : null,
              ),
            );
          },
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
  }
}
