import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer' as developer;
import '../models/user_model.dart';

class AuthService {
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;
  late final GoogleSignIn _googleSignIn;
  bool _isFirebaseInitialized = false;

  AuthService() {
    _initializeFirebaseServices();
  }

  void _initializeFirebaseServices() {
    try {
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      _isFirebaseInitialized = true;
      developer.log('Firebase services initialized successfully', name: 'AuthService');
    } catch (e) {
      _isFirebaseInitialized = false;
      developer.log('Failed to initialize Firebase services: $e', name: 'AuthService');
    }
  }

  User? get currentUser => _isFirebaseInitialized ? _auth.currentUser : null;
  Stream<User?> get authStateChanges => _isFirebaseInitialized 
      ? _auth.authStateChanges() 
      : Stream.value(null);

  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    developer.log('Attempting sign in for email: $email', name: 'AuthService');
    
    if (!_isFirebaseInitialized) {
      developer.log('Firebase not initialized', name: 'AuthService');
      throw FirebaseAuthException(
        code: 'unavailable',
        message: 'Authentication service is not available. Please try again.',
      );
    }
    
    try {
      developer.log('Calling Firebase signInWithEmailAndPassword', name: 'AuthService');
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      developer.log('Sign in successful for user: ${credential.user?.uid}', name: 'AuthService');
      return credential;
    } on FirebaseAuthException catch (e) {
      developer.log('Firebase auth error: ${e.code} - ${e.message}', name: 'AuthService');
      // Provide more specific error messages
      String errorMessage = _getDetailedErrorMessage(e.code);
      throw FirebaseAuthException(code: e.code, message: errorMessage);
    } catch (e) {
      developer.log('Unknown sign in error: $e', name: 'AuthService');
      throw FirebaseAuthException(
        code: 'unknown',
        message: 'Sign in failed. Please try again.',
      );
    }
  }

  Future<UserCredential?> createUserWithEmailAndPassword(
      String email, String password, String username) async {
    if (!_isFirebaseInitialized) {
      throw FirebaseAuthException(
        code: 'unavailable',
        message: 'Authentication service is not available. Please try again.',
      );
    }
    
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      await credential.user?.updateDisplayName(username);
      
      // Create user profile in Firestore
      await _createUserProfile(credential.user!, username);
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw FirebaseAuthException(
        code: 'unknown',
        message: 'Account creation failed. Please try again.',
      );
    }
  }

  Future<void> _createUserProfile(User user, String username) async {
    if (!_isFirebaseInitialized) {
      throw Exception('Firebase is not initialized');
    }
    
    final userModel = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      username: username,
      skillLevel: 'Beginner',
      foldingHistory: [],
      quizScores: {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toFirestore());
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  Future<UserModel?> getUserProfile(String uid) async {
    if (!_isFirebaseInitialized) {
      return null;
    }
    
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      // Failed to get user profile
      return null;
    }
  }

  Future<void> updateUserProfile(UserModel user) async {
    if (!_isFirebaseInitialized) {
      throw Exception('Firebase is not initialized');
    }
    
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(user.toFirestore());
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  Future<void> updatePassword(String newPassword) async {
    if (!_isFirebaseInitialized || currentUser == null) {
      throw FirebaseAuthException(
        code: 'unavailable',
        message: 'User not authenticated or service unavailable',
      );
    }
    
    try {
      await currentUser!.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    developer.log('Attempting Google sign in', name: 'AuthService');
    
    if (!_isFirebaseInitialized) {
      developer.log('Firebase not initialized', name: 'AuthService');
      throw FirebaseAuthException(
        code: 'unavailable',
        message: 'Authentication service is not available. Please try again.',
      );
    }

    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        developer.log('Google sign in cancelled by user', name: 'AuthService');
        throw FirebaseAuthException(
          code: 'aborted-by-user',
          message: 'Sign in was cancelled',
        );
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      final userCredential = await _auth.signInWithCredential(credential);
      
      developer.log('Google sign in successful for user: ${userCredential.user?.uid}', name: 'AuthService');
      
      // Create user profile if it doesn't exist
      if (userCredential.user != null) {
        await _createUserProfileIfNotExists(userCredential.user!);
      }
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      developer.log('Firebase auth error during Google sign in: ${e.code} - ${e.message}', name: 'AuthService');
      throw e;
    } catch (e) {
      developer.log('Unknown error during Google sign in: $e', name: 'AuthService');
      throw FirebaseAuthException(
        code: 'unknown',
        message: 'Google sign in failed. Please try again.',
      );
    }
  }

  Future<void> _createUserProfileIfNotExists(User user) async {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!doc.exists) {
        final userModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          username: user.displayName ?? 'User',
          skillLevel: 'Beginner',
          foldingHistory: [],
          quizScores: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toFirestore());
        
        developer.log('Created user profile for Google sign in user', name: 'AuthService');
      }
    } catch (e) {
      developer.log('Failed to create user profile: $e', name: 'AuthService');
    }
  }

  Future<void> signOut() async {
    if (_isFirebaseInitialized) {
      await _googleSignIn.signOut();
      await _auth.signOut();
    }
  }

  String _getDetailedErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No account found with this email. Please check your email or sign up.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Wrong password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'unavailable':
        return 'Authentication service is currently unavailable. Please try again.';
      default:
        return "Couldn't sign in. Please check your credentials and try again.";
    }
  }

  FirebaseAuthException _handleAuthException(FirebaseAuthException e) {
    String message = _getDetailedErrorMessage(e.code);
    return FirebaseAuthException(code: e.code, message: message);
  }

  // Demo mode for testing without real Firebase project
  Future<UserCredential?> signInDemo(String email, String password) async {
    // Demo mode: Simulating sign in
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Demo credentials for testing
    if (email == 'demo@apporigami.com' && password == 'demo123') {
      // Demo sign in successful
      // In demo mode, we can't actually sign in, so we'll just return null
      // The app should handle this gracefully
      return null;
    } else {
      throw FirebaseAuthException(
        code: 'invalid-credential',
        message: "Couldn't sign in. Wrong email or password, please try again.",
      );
    }
  }
}
