import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.read(authServiceProvider);
  return authService.authStateChanges;
});

final userProfileProvider = FutureProvider.family<UserModel?, String>((ref, uid) async {
  final authService = ref.read(authServiceProvider);
  return await authService.getUserProfile(uid);
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  AuthNotifier(this._authService) : super(const AsyncValue.loading()) {
    _authService.authStateChanges.listen((user) {
      state = AsyncValue.data(user);
    });
  }

  final AuthService _authService;

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _authService.signInWithEmailAndPassword(email, password);
      // State will be updated automatically by authStateChanges listener
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow; // Re-throw so UI can handle the error
    }
  }

  Future<void> signUp(String email, String password, String username) async {
    state = const AsyncValue.loading();
    try {
      await _authService.createUserWithEmailAndPassword(email, password, username);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      await _authService.signInWithGoogle();
      // State will be updated automatically by authStateChanges listener
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow; // Re-throw so UI can handle the error
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _authService.updatePassword(newPassword);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final authService = ref.read(authServiceProvider);
  return AuthNotifier(authService);
});
