// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream to track the user's sign-in status
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  // 1. Sign in with Email and Password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      // For simplicity, re-throw the exception to be handled by the UI
      rethrow;
    }
  }

  // 2. Register with Email and Password
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // NOTE: Here you would also write initial user data to the Realtime Database
      // e.g., DatabaseService(uid: result.user!.uid).updateUserData('name', 'location', ...);
      return result.user;
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
  }

  // 3. Sign Out
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

// NOTE: Google Sign-In and Phone Auth will be implemented later,
// as they require more setup (e.g., SHA-1 key setup in Firebase).
}