import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/shared_app_bar.dart';
import '../fcm/screens/fcm_token_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isEditingUsername = false;
  bool _isEditingPassword = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updateUsername() async {
    if (_usernameController.text.trim().isEmpty) return;

    try {
      await ref.read(userNotifierProvider.notifier).updateUsername(_usernameController.text.trim());
      setState(() => _isEditingUsername = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update username: $e')),
        );
      }
    }
  }

  Future<void> _updatePassword() async {
    if (_passwordController.text.length < 6) return;

    try {
      await ref.read(authNotifierProvider.notifier).updatePassword(_passwordController.text);
      setState(() => _isEditingPassword = false);
      _passwordController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update password: $e')),
        );
      }
    }
  }

  Future<void> _signOut() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final goRouter = GoRouter.of(context);
              navigator.pop();
              await ref.read(authNotifierProvider.notifier).signOut();
              if (mounted) goRouter.go('/login');
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final userState = ref.watch(userNotifierProvider);

    return Scaffold(
      appBar: SharedAppBar(
        showBackButton: true,
        showMusicToggle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: authState.when(
        data: (user) {
          if (user == null) return const Center(child: Text('Not logged in'));
          
          // Load user profile
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(userNotifierProvider.notifier).loadUserProfile(user.uid);
          });

          return userState.when(
            data: (userProfile) {
              if (userProfile == null) {
                return const Center(child: Text('User profile not found'));
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Header
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: AppTheme.primaryColor,
                              child: Text(
                                userProfile.username.isNotEmpty 
                                    ? userProfile.username[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _isEditingUsername
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _usernameController,
                                          decoration: const InputDecoration(
                                            labelText: 'Username',
                                            isDense: true,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.check),
                                        onPressed: _updateUsername,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () => setState(() => _isEditingUsername = false),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        userProfile.username,
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 20),
                                        onPressed: () {
                                          _usernameController.text = userProfile.username;
                                          setState(() => _isEditingUsername = true);
                                        },
                                      ),
                                    ],
                                  ),
                            Text(
                              userProfile.email,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Chip(
                              label: Text(userProfile.skillLevel),
                              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                              labelStyle: TextStyle(color: AppTheme.primaryColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quiz Scores
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.quiz, color: AppTheme.primaryColor),
                                const SizedBox(width: 8),
                                Text(
                                  'Quiz Scores',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (userProfile.quizScores.isEmpty)
                              Text(
                                'No quizzes completed yet',
                                style: TextStyle(color: Colors.grey[600]),
                              )
                            else
                              ...userProfile.quizScores.entries.map((entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(entry.key),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${entry.value}',
                                        style: TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Folding History
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.photo_library, color: AppTheme.primaryColor),
                                const SizedBox(width: 8),
                                Text(
                                  'Folding History',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (userProfile.foldingHistory.isEmpty)
                              Text(
                                'No folds uploaded yet',
                                style: TextStyle(color: Colors.grey[600]),
                              )
                            else
                              SizedBox(
                                height: 120,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: userProfile.foldingHistory.length,
                                  itemBuilder: (context, index) {
                                    final imageUrl = userProfile.foldingHistory[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          width: 120,
                                          height: 120,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.image, size: 40),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Settings
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.settings, color: AppTheme.primaryColor),
                                const SizedBox(width: 8),
                                Text(
                                  'Settings',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_isEditingPassword)
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _passwordController,
                                      decoration: const InputDecoration(
                                        labelText: 'New Password',
                                        isDense: true,
                                      ),
                                      obscureText: true,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.check),
                                    onPressed: _updatePassword,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => setState(() => _isEditingPassword = false),
                                  ),
                                ],
                              )
                            else
                              ListTile(
                                leading: const Icon(Icons.lock),
                                title: const Text('Change Password'),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () => setState(() => _isEditingPassword = true),
                              ),
                              
                              // FCM Token Viewer
                              ListTile(
                                leading: const Icon(Icons.notifications, color: Color(0xFF2196F3)),
                                title: const Text('FCM Token Viewer'),
                                subtitle: const Text('View and copy Firebase messaging token'),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const FCMTokenScreen(),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error loading profile: $error'),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Authentication error: $error'),
        ),
      ),
    );
  }
}
