import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student_hub/sh_user_model.dart';
import '../services/student_hub_auth_service.dart';

// ✨ Service Provider
final studentHubAuthServiceProvider =
    Provider((ref) => StudentHubAuthService());

// 👤 Current SH User Provider (Future)
final currentSHUserProvider = FutureProvider<SHUserModel?>((ref) async {
  final authService = ref.watch(studentHubAuthServiceProvider);
  final currentUser = authService.currentUser;

  if (currentUser == null) {
    return null;
  }

  return await authService.getUserById(currentUser.uid);
});

// 🔄 Current SH User Provider (StateNotifier - for real-time updates)
final currentSHUserNotifierProvider =
    StateNotifierProvider<SHUserNotifier, SHUserModel?>((ref) {
  final authService = ref.watch(studentHubAuthServiceProvider);
  return SHUserNotifier(authService);
});

class SHUserNotifier extends StateNotifier<SHUserModel?> {
  final StudentHubAuthService _authService;

  SHUserNotifier(this._authService) : super(null) {
    _init();
  }

  Future<void> _init() async {
    final user = _authService.currentUser;
    if (user != null) {
      final userData = await _authService.getUserById(user.uid);
      state = userData;
    }
  }

  // 📝 Update Profile
  Future<void> updateProfile({
    String? name,
    String? profileImage,
    UserRole? role,
  }) async {
    if (state == null) return;

    try {
      await _authService.updateProfile(
        uid: state!.uid,
        name: name,
        profileImage: profileImage,
        role: role,
      );

      state = state!.copyWith(
        name: name,
        profileImage: profileImage,
        role: role,
      );
    } catch (e) {
      debugPrint('❌ Update Profile Error: $e');
      rethrow;
    }
  }

  // 🔗 Add Group
  Future<void> addGroup(String groupId) async {
    if (state == null) return;

    try {
      state = state!.addGroup(groupId);

      // Firestore mein update karte hain
      await _authService.updateUserGroups(state!.uid, state!.enrolledGroups);
    } catch (e) {
      debugPrint('❌ Add Group Error: $e');
      rethrow;
    }
  }

  // 🗑️ Remove Group
  Future<void> removeGroup(String groupId) async {
    if (state == null) return;

    try {
      state = state!.removeGroup(groupId);

      // Firestore mein update karte hain
      await _authService.updateUserGroups(state!.uid, state!.enrolledGroups);
    } catch (e) {
      debugPrint('❌ Remove Group Error: $e');
      rethrow;
    }
  }

  // 🚪 Logout
  Future<void> logout() async {
    try {
      await _authService.logout();
      state = null;
    } catch (e) {
      debugPrint('❌ Logout Error: $e');
      rethrow;
    }
  }

  // 🔄 Refresh User Data
  Future<void> refresh() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final userData = await _authService.getUserById(user.uid);
        state = userData;
      }
    } catch (e) {
      debugPrint('❌ Refresh Error: $e');
      rethrow;
    }
  }

  // 🔧 Set User (for external state updates)
  void setUser(SHUserModel? user) {
    state = user;
  }
}

// 🔓 Login Provider
final loginProvider = FutureProvider.family<SHUserModel?, LoginParams>((ref, params) async {
  final authService = ref.watch(studentHubAuthServiceProvider);

  try {
    final user = await authService.login(
      email: params.email,
      password: params.password,
    );

    if (user != null) {
      // Update state
      ref.read(currentSHUserNotifierProvider.notifier).setUser(user);
    }

    return user;
  } catch (e) {
    debugPrint('❌ Login Provider Error: $e');
    rethrow;
  }
});

// 📝 Signup Provider
final signupProvider = FutureProvider.family<SHUserModel?, SignupParams>((ref, params) async {
  final authService = ref.watch(studentHubAuthServiceProvider);

  try {
    final user = await authService.signup(
      email: params.email,
      password: params.password,
      name: params.name,
      role: params.role,
    );

    if (user != null) {
      // Update state
      ref.read(currentSHUserNotifierProvider.notifier).setUser(user);
    }

    return user;
  } catch (e) {
    debugPrint('❌ Signup Provider Error: $e');
    rethrow;
  }
});

// 🚪 Logout Provider
final logoutProvider = FutureProvider((ref) async {
  await ref.read(studentHubAuthServiceProvider).logout();
  ref.read(currentSHUserNotifierProvider.notifier).setUser(null);
});

// DTOs
class LoginParams {
  final String email;
  final String password;

  LoginParams({required this.email, required this.password});
}

class SignupParams {
  final String email;
  final String password;
  final String name;
  final UserRole role;

  SignupParams({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
  });
}


