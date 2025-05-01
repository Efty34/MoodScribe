import 'package:diary/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

      // Store user data in Firestore
      await UserService().updateUserProfile(
        username: username,
        email: email,
      );

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
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Return null if successful
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No account found with this email. Please register first.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'invalid-email':
          return 'Invalid email format. Please check your email.';
        case 'user-disabled':
          return 'This account has been disabled. Please contact support.';
        case 'too-many-requests':
          return 'Too many failed attempts. Please try again later.';
        default:
          print('Firebase Auth Error: ${e.code}'); // For debugging
          return 'Authentication failed. Please try again.';
      }
    } catch (e) {
      print('General Error: $e'); // For debugging
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // Google sign in
  Future<UserCredential?> signInWithGoogle(
      {bool forceAccountSelection = true}) async {
    try {
      // Sign out first if we want to force account selection
      if (forceAccountSelection) {
        await GoogleSignIn().signOut();
      }

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return null; // User canceled the sign-in
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      final userCredential = await _auth.signInWithCredential(credential);

      // Store user data in Firestore - similar to email signup flow
      await UserService().updateUserProfile(
        username: userCredential.user?.displayName ??
            googleUser.displayName ??
            'Google User',
        email: userCredential.user?.email ?? googleUser.email,
      );

      return userCredential;
    } catch (e) {
      print('Google Sign-In Error: $e'); // For debugging
      rethrow; // Rethrow to handle in UI
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Stream to check auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
