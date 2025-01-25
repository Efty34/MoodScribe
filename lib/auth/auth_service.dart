import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign up with email and password
  Future<String?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // Create user
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(username);

      return null; // Return null if successful
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email address';
      }
      return 'An error occurred. Please try again later';
    }
  }

  // Sign in with email and password
  Future<String?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verify if user exists
      if (userCredential.user == null) {
        return 'Login failed. Please try again.';
      }

      return null; // Return null if successful
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code}'); // Add this for debugging
      if (e.code == 'user-not-found') {
        return 'No user found for that email';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email address';
      } else if (e.code == 'user-disabled') {
        return 'This account has been disabled';
      }
      return 'An error occurred. Please try again later';
    } catch (e) {
      print('General Error: $e'); // Add this for debugging
      return 'An error occurred. Please try again later';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Stream to check auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
