import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current Firebase user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user data from Firestore
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (currentUser == null) return null;

      final doc =
          await _firestore.collection('users').doc(currentUser!.uid).get();
      if (!doc.exists) return null;

      return UserModel.fromFirestore(doc);
    } catch (e) {
      print('Error getting current user data: $e');
      return null;
    }
  }

  // Login with email and password
  Future<({UserModel? user, String? error})> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        return (user: null, error: 'Login failed. Please try again.');
      }

      // Update last login
      await _firestore.collection('users').doc(credential.user!.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      // Get user data
      final userDoc =
          await _firestore.collection('users').doc(credential.user!.uid).get();
      if (!userDoc.exists) {
        return (user: null, error: 'User data not found.');
      }

      final userData = UserModel.fromFirestore(userDoc);

      // Check if user is active
      if (!userData.isActive) {
        await _auth.signOut();
        return (
          user: null,
          error: 'Your account has been deactivated. Please contact admin.'
        );
      }

      return (user: userData, error: null);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid email or password.';
          break;
        default:
          errorMessage = e.message ?? 'Login failed. Please try again.';
      }
      return (user: null, error: errorMessage);
    } catch (e) {
      return (user: null, error: 'An unexpected error occurred: $e');
    }
  }

  // Register with email and password
  Future<({UserModel? user, String? error})> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String role,
    String? gender,
    DateTime? birthDate,
    String? department,
    String? specialization,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        return (user: null, error: 'Registration failed. Please try again.');
      }

      // Create user document in Firestore
      final newUser = UserModel(
        id: credential.user!.uid,
        email: email.trim(),
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        phone: phone.trim(),
        role: role.toLowerCase(),
        gender: gender,
        birthDate: birthDate,
        department: department,
        specialization: specialization,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        isActive: true,
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(newUser.toFirestore());

      return (user: newUser, error: null);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage =
              'Password is too weak. Please use a stronger password.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        default:
          errorMessage = e.message ?? 'Registration failed. Please try again.';
      }
      return (user: null, error: errorMessage);
    } catch (e) {
      return (user: null, error: 'An unexpected error occurred: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Reset password
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Failed to send reset email.';
    } catch (e) {
      return 'An unexpected error occurred.';
    }
  }

  // Update user profile
  Future<String?> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
      return null;
    } catch (e) {
      return 'Failed to update profile: $e';
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Get user role for routing
  Future<String?> getCurrentUserRole() async {
    try {
      if (currentUser == null) return null;
      final doc =
          await _firestore.collection('users').doc(currentUser!.uid).get();
      if (!doc.exists) return null;
      return doc.data()?['role'] as String?;
    } catch (e) {
      return null;
    }
  }
}
