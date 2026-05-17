import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../providers/student_hub_user_provider.dart';
import 'package:go_router/go_router.dart';

class StudentHubProfileSetupScreen extends ConsumerStatefulWidget {
  const StudentHubProfileSetupScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StudentHubProfileSetupScreenState();
}

class _StudentHubProfileSetupScreenState
    extends ConsumerState<StudentHubProfileSetupScreen> {
  File? _selectedImage;
  bool _isUploading = false;
  String? _errorMessage;

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error picking image: ${e.toString()}');
    }
  }

  Future<void> _uploadAndSaveProfile() async {
    try {
      final user = ref.read(currentSHUserNotifierProvider);
      
      if (user == null) {
        setState(() => _errorMessage = 'User not found');
        return;
      }

      setState(() => _isUploading = true);

      String? profileImageUrl;

      // Upload image if selected
      if (_selectedImage != null) {
        final storageRef = FirebaseStorage.instance.ref();
        final profileImageRef = storageRef.child('profile_images/${user.uid}.jpg');

        final uploadTask = await profileImageRef.putFile(_selectedImage!);
        profileImageUrl = await uploadTask.ref.getDownloadURL();
      }

      // Update profile with download URL if image was uploaded
      if (profileImageUrl != null) {
        await ref
            .read(currentSHUserNotifierProvider.notifier)
            .updateProfile(profileImage: profileImageUrl);
      }

      // Navigate to home
      if (mounted) {
        context.go('/student-hub-home');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error uploading profile: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _skipProfileSetup() {
    context.go('/student-hub-home');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentSHUserNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Complete Your Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // User Info Display
              if (user != null) ...[
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user.email,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Profile Image Picker with Camera Overlay
              GestureDetector(
                onTap: _isUploading ? null : _pickImageFromGallery,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    // Profile Picture Circle
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF6366F1),
                          width: 3,
                        ),
                      ),
                      child: _selectedImage != null
                          ? ClipOval(
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : (user?.profileImage != null &&
                                  user!.profileImage!.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    user.profileImage!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.person_outline,
                                        size: 70,
                                        color: Color(0xFF6366F1),
                                      );
                                    },
                                  ),
                                )
                              : const Icon(
                                  Icons.person_outline,
                                  size: 70,
                                  color: Color(0xFF6366F1),
                                )),
                    ),

                    // Camera Icon Overlay
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF0F1419),
                          width: 3,
                        ),
                      ),
                      child: _isUploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 24,
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _selectedImage != null ? 'Image selected' : 'Tap to add profile picture',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 40),

              // Error Message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_errorMessage != null) const SizedBox(height: 24),

              // Save & Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _uploadAndSaveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    disabledBackgroundColor: Colors.grey[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save & Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Skip for now Button
              TextButton(
                onPressed: _isUploading ? null : _skipProfileSetup,
                child: Text(
                  'Skip for now',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



