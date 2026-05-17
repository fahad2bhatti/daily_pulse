import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../providers/student_hub_assignment_provider.dart';
import '../providers/student_hub_user_provider.dart';

class StudentHubAssignmentDetailScreen extends ConsumerStatefulWidget {
  final String assignmentId;
  final String groupId;

  const StudentHubAssignmentDetailScreen(
    this.assignmentId,
    this.groupId, {
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StudentHubAssignmentDetailScreenState();
}

class _StudentHubAssignmentDetailScreenState
    extends ConsumerState<StudentHubAssignmentDetailScreen> {
  final _noteController = TextEditingController();
  File? _selectedFile;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy hh:mm a').format(date);
  }

  bool _isOverdue(DateTime dueDate) {
    return dueDate.isBefore(DateTime.now());
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open file')),
        );
      }
    }
  }

   Future<void> _submitAssignment() async {
     try {
       final currentUser = ref.read(currentSHUserNotifierProvider);
       if (currentUser == null) throw Exception('User not found');

       setState(() => _isSubmitting = true);

       String? fileUrl;

       // Upload file if selected
       if (_selectedFile != null) {
         final storageRef = FirebaseStorage.instance.ref();
         final fileName = _selectedFile!.path.split('/').last;
         final submissionRef = storageRef.child(
           'submissions/${widget.assignmentId}/${currentUser.uid}/$fileName',
         );

         final uploadTask = await submissionRef.putFile(_selectedFile!);
         fileUrl = await uploadTask.ref.getDownloadURL();
       }

       // Submit assignment
       await ref.read(studentHubAssignmentServiceProvider).submitAssignment(
             groupId: widget.groupId,
             assignmentId: widget.assignmentId,
             userId: currentUser.uid,
             fileUrl: fileUrl,
           );

       if (mounted) {
         Navigator.pop(context);
         ref.invalidate(mySubmissionProvider((widget.groupId, widget.assignmentId)));
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
             content: Text('Assignment submitted successfully!'),
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
     } finally {
       if (mounted) {
         setState(() => _isSubmitting = false);
       }
     }
   }

   @override
   Widget build(BuildContext context) {
     final assignmentAsyncValue =
         ref.watch(assignmentDetailProvider((widget.groupId, widget.assignmentId)));
     final submissionAsyncValue =
         ref.watch(mySubmissionProvider((widget.groupId, widget.assignmentId)));
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
        title: const Text(
          'Assignment',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: assignmentAsyncValue.when(
        data: (assignment) {
          if (assignment == null) {
            return const Center(
              child: Text(
                'Assignment not found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final isOverdue = _isOverdue(assignment.dueDate);

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Title
                    Text(
                      assignment.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subject/Group
                    Text(
                      assignment.groupId,
                      style:
                          TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                    const SizedBox(height: 16),

                    // Due Date
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Due: ${_formatDate(assignment.dueDate)}',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Overdue Banner
                    if (isOverdue)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'This assignment is overdue',
                              style: TextStyle(
                                color: Colors.red[300],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Description Label
                    Text(
                      'Description',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Description
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[800]!),
                      ),
                      child: Text(
                        assignment.description,
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Attachment
                    if (assignment.fileUrl != null) ...[
                      Text(
                        'Attachment',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _launchUrl(assignment.fileUrl!),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF6366F1),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.description,
                                  color: Color(0xFF6366F1)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'View Attachment',
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Icon(Icons.open_in_new,
                                  size: 16, color: Color(0xFF6366F1)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Submission Section
                    if (currentUser?.isStudent ?? false) ...[
                      Text(
                        'Your Submission',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      submissionAsyncValue.when(
                        data: (submission) {
                          // Already submitted
                          if (submission != null) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.green
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.check_circle,
                                          color: Colors.green, size: 24),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Assignment Submitted',
                                        style: TextStyle(
                                          color: Colors.green[300],
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Submitted: ${_formatDate(submission.submittedAt)}',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: submission.isGraded
                                          ? Colors.blue
                                              .withValues(alpha: 0.1)
                                          : Colors.orange
                                              .withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      submission.isGraded
                                          ? 'Graded: ${submission.score}/100'
                                          : 'Pending Review',
                                      style: TextStyle(
                                        color: submission.isGraded
                                            ? Colors.blue[300]
                                            : Colors.orange[300],
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          // Not submitted yet
                          if (isOverdue) {
                            // Overdue
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color:
                                      Colors.red.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.lock,
                                          color: Colors.red, size: 24),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Submission Closed',
                                        style: TextStyle(
                                          color: Colors.red[300],
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'The deadline has passed. You can no longer submit this assignment.',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          // Show submission form
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  Border.all(color: Colors.grey[800]!),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: _noteController,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Add a note or comment (optional)',
                                    hintStyle:
                                        TextStyle(color: Colors.grey[600]),
                                    filled: true,
                                    fillColor: Colors.grey[950],
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton.icon(
                                    onPressed: _pickFile,
                                    icon: const Icon(Icons.attach_file),
                                    label:
                                        const Text('Attach File'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[800],
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (_selectedFile != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16,
                                      top: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _selectedFile!.path
                                                .split('/')
                                                .last,
                                            style: TextStyle(
                                              color: Colors.grey[300],
                                              fontSize: 12,
                                            ),
                                            overflow:
                                                TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: _isSubmitting
                                        ? null
                                        : _submitAssignment,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFF6366F1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: _isSubmitting
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child:
                                                CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                Colors.white,
                                              ),
                                            ),
                                          )
                                        : const Text(
                                            'Submit Assignment',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight:
                                                  FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        loading: () => const Center(
                          child:
                              CircularProgressIndicator(),
                        ),
                        error: (error, stack) => Center(
                          child: Text(
                            'Error: ${error.toString()}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                  ]),
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
}

