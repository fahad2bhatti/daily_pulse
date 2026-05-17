import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_hub/sh_user_model.dart';

class StudentHubAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Current logged-in user
  User? get currentUser => _auth.currentUser;

  /// Stream of user changes
  Stream<User?> get userChanges => _auth.userChanges();

  /// 🔒 Signup - New user create karte hain
  Future<SHUserModel?> signup({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    try {
      // Firebase Auth mein user create karte hain
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // Firestore mein profile save karte hain
      final shUser = SHUserModel(
        uid: uid,
        name: name,
        email: email,
        role: role,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(shUser.toJson());

      return shUser;
    } on FirebaseAuthException catch (e) {
      print('❌ Signup Error: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected Error: $e');
      rethrow;
    }
  }

  /// 🔓 Login - User login karte hain
  Future<SHUserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // Firestore mein lastLogin update karte hain
      await _firestore.collection('users').doc(uid).update({
        'lastLogin': Timestamp.now(),
      });

      // User data fetch karte hain
      return await getUserById(uid);
    } on FirebaseAuthException catch (e) {
      print('❌ Login Error: ${e.message}');
      rethrow;
    }
  }

  /// 📝 Profile Update - Profile update karte hain
  Future<void> updateProfile({
    required String uid,
    String? name,
    String? profileImage,
    UserRole? role,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (name != null) updates['name'] = name;
      if (profileImage != null) updates['profileImage'] = profileImage;
      if (role != null) updates['role'] = role.name;

      await _firestore.collection('users').doc(uid).update(updates);
    } catch (e) {
      print('❌ Profile Update Error: $e');
      rethrow;
    }
  }

  /// 🔑 Get User by ID
  Future<SHUserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        return SHUserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('❌ Get User Error: $e');
      return null;
    }
  }

  /// 👥 Get Users by IDs (group members fetch karte hain)
  Future<List<SHUserModel>> getUsersByIds(List<String> uids) async {
    try {
      if (uids.isEmpty) return [];

      final docs = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: uids)
          .get();

      return docs.docs
          .map((doc) => SHUserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Get Users Error: $e');
      return [];
    }
  }

  /// 🚪 Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('❌ Logout Error: $e');
      rethrow;
    }
  }

  /// 🔐 Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print('❌ Password Reset Error: ${e.message}');
      rethrow;
    }
  }

  /// ✅ Delete Account
  Future<void> deleteAccount(String uid) async {
    try {
      // User ko delete karte hain Firebase se
      await currentUser?.delete();

      // Firestore mein data mark as inactive karte hain (soft delete)
      await _firestore.collection('users').doc(uid).update({
        'isActive': false,
      });
    } on FirebaseAuthException catch (e) {
      print('❌ Delete Account Error: ${e.message}');
      rethrow;
    }
  }

  /// 🔄 Refresh User Data
  Future<SHUserModel?> refreshUserData() async {
    if (currentUser == null) return null;
    return await getUserById(currentUser!.uid);
  }

  /// 👥 Update User Groups
  Future<void> updateUserGroups(String uid, List<String> groups) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'enrolledGroups': groups,
      });
    } catch (e) {
      print('❌ Update User Groups Error: $e');
      rethrow;
    }
  }
}


