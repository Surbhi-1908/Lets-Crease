import 'package:flutter_riverpod/flutter_riverpod.dart';

// Demo authentication state provider
class DemoAuthNotifier extends StateNotifier<bool> {
  DemoAuthNotifier() : super(false);

  void signInDemo() {
    // Demo user signed in
    state = true;
  }

  void signOut() {
    // Demo user signed out
    state = false;
  }
}

final demoAuthProvider = StateNotifierProvider<DemoAuthNotifier, bool>((ref) {
  return DemoAuthNotifier();
});

// Demo user data
class DemoUser {
  static const String uid = 'demo-user-123';
  static const String email = 'demo@apporigami.com';
  static const String username = 'Demo User';
  static const String skillLevel = 'Beginner';
}
