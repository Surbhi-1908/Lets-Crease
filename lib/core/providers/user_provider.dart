import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class UserNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  UserNotifier(this._authService) : super(const AsyncValue.loading());

  final AuthService _authService;

  Future<void> loadUserProfile(String uid) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.getUserProfile(uid);
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _authService.updateUserProfile(user);
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateSkillLevel(String skillLevel) async {
    final currentUser = state.value;
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(skillLevel: skillLevel);
      await updateUserProfile(updatedUser);
    }
  }

  Future<void> addFoldingHistory(String imageUrl) async {
    final currentUser = state.value;
    if (currentUser != null) {
      final updatedHistory = [...currentUser.foldingHistory, imageUrl];
      final updatedUser = currentUser.copyWith(foldingHistory: updatedHistory);
      await updateUserProfile(updatedUser);
    }
  }

  Future<void> updateQuizScore(String category, int score) async {
    final currentUser = state.value;
    if (currentUser != null) {
      final updatedScores = {...currentUser.quizScores, category: score};
      final updatedUser = currentUser.copyWith(quizScores: updatedScores);
      await updateUserProfile(updatedUser);
    }
  }

  Future<void> updateUsername(String newUsername) async {
    final currentUser = state.value;
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(username: newUsername);
      await updateUserProfile(updatedUser);
    }
  }
}

final userNotifierProvider = StateNotifierProvider<UserNotifier, AsyncValue<UserModel?>>((ref) {
  final authService = ref.read(authServiceProvider);
  return UserNotifier(authService);
});

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
