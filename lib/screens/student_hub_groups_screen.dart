import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'dart:math';
import '../models/student_hub/group_model.dart';
import '../providers/student_hub_group_provider.dart';
import '../providers/student_hub_user_provider.dart';
import 'student_hub_group_detail_screen.dart';

class StudentHubGroupsScreen extends ConsumerStatefulWidget {
  const StudentHubGroupsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StudentHubGroupsScreenState();
}

class _StudentHubGroupsScreenState extends ConsumerState<StudentHubGroupsScreen> {
  final _inviteCodeController = TextEditingController();
  final _groupNameController = TextEditingController();
  final _groupSubjectController = TextEditingController();

  @override
  void dispose() {
    _inviteCodeController.dispose();
    _groupNameController.dispose();
    _groupSubjectController.dispose();
    super.dispose();
  }




  void _showCreateGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2329),
        title: const Text(
          'Create New Group',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _groupNameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Group name',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.groups, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _groupSubjectController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Subject (e.g., Mathematics)',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.book, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _groupNameController.clear();
              _groupSubjectController.clear();
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => _handleCreateGroup(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
            child: const Text('Create Group',
                style: TextStyle(color: Colors.white, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  void _handleCreateGroup() async {
    if (_groupNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter group name')),
      );
      return;
    }

    if (_groupSubjectController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter subject')),
      );
      return;
    }

    try {
      final currentUser = ref.read(currentSHUserNotifierProvider);
      if (currentUser == null) throw Exception('User not found');

      await ref.read(studentHubGroupServiceProvider).createGroup(
            name: _groupNameController.text.trim(),
            subject: _groupSubjectController.text.trim(),
            adminUid: currentUser.uid,
          );

      if (mounted) {
        Navigator.pop(context);
        _groupNameController.clear();
        _groupSubjectController.clear();

        // Refresh groups
        ref.invalidate(userGroupsProvider(currentUser.uid));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Group created successfully!'),
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

  void _copyInviteCode(String inviteCode) {
    Clipboard.setData(ClipboardData(text: inviteCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invite code copied: $inviteCode'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showJoinGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2329),
        title: const Text(
          'Join Group',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: _inviteCodeController,
          style: const TextStyle(color: Colors.white),
          textCapitalization: TextCapitalization.characters,
          maxLength: 6,
          decoration: InputDecoration(
            hintText: 'Enter 6-digit code',
            hintStyle: TextStyle(color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => _handleJoinGroup(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
            ),
            child: const Text('Join',
                style: TextStyle(color: Colors.white, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  void _handleJoinGroup() async {
    if (_inviteCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter invite code')),
      );
      return;
    }

    try {
      final currentUser = ref.read(currentSHUserNotifierProvider);
      if (currentUser == null) throw Exception('User not found');

      final group = await ref
          .read(studentHubGroupServiceProvider)
          .joinGroupWithCode(
            inviteCode: _inviteCodeController.text.toUpperCase(),
            userUid: currentUser.uid,
          );

      if (!mounted) return;

      Navigator.pop(context);
      _inviteCodeController.clear();

      // Refresh groups
      ref.invalidate(userGroupsProvider(currentUser.uid));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Joined ${group?.name ?? 'group'}')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentSHUserNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Groups',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () {
              // Navigate to profile
            },
          ),
        ],
      ),
      body: currentUser == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : CustomScrollView(
              slivers: [
                // Header with action buttons
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Join Group Button
                        if (currentUser.isStudent)
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _showJoinGroupDialog,
                              icon: const Icon(Icons.add),
                              label: const Text('Join Group with Code'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),

                        // Create Group Button (for teachers)
                        if (currentUser.isTeacher) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _showCreateGroupDialog,
                              icon: const Icon(Icons.add),
                              label: const Text('Create New Group'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Groups List
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: ref.watch(userGroupsProvider(currentUser.uid)).when(
                    data: (groups) {
                      if (groups.isEmpty) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.folder_open_outlined,
                                  size: 64,
                                  color: Colors.grey[700],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No groups yet',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  currentUser.isStudent
                                      ? 'Join a group with an invite code'
                                      : 'Create a group to get started',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final group = groups[index];
                            return _buildGroupCard(context, group);
                          },
                          childCount: groups.length,
                        ),
                      );
                    },
                    loading: () => const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (error, stack) => SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'Error: ${error.toString()}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildGroupCard(BuildContext context, GroupModel group) {
    final currentUser = ref.watch(currentSHUserNotifierProvider);
    final isAdmin = currentUser?.uid == group.adminUid;

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
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              group.name.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
        ),
        title: Text(
          group.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${group.subject} • ${group.memberUids.length} members',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isAdmin)
              IconButton(
                icon: const Icon(Icons.share, size: 20, color: Colors.grey),
                onPressed: () => _copyInviteCode(group.inviteCode),
              )
            else
              const Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.grey),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => StudentHubGroupDetailScreen(
                groupId: group.groupId,
              ),
            ),
          );
        },
      ),
    );
  }
}


