import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/audio_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/widgets/shared_app_bar.dart';
import 'paper_types_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _usernameController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isUpdatingProfile = false;
  bool _isChangingPassword = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _showLogoutDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Logout',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'No',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await ref.read(authNotifierProvider.notifier).signOut();
                  if (context.mounted) {
                    context.go('/login');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to sign out: $e'),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateUsername() async {
    if (_usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a username'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isUpdatingProfile = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(_usernameController.text.trim());
        await user.reload();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Username updated successfully'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
          _usernameController.clear();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update username: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingProfile = false);
    }
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isChangingPassword = true);

    try {
      await ref.read(authNotifierProvider.notifier).updatePassword(_newPasswordController.text);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Password updated successfully'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update password: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isChangingPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    
    return Scaffold(
      appBar: const SharedAppBar(showBackButton: true, showMusicToggle: false),
      body: ref.watch(authStateProvider).when(
        data: (user) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Section
              _buildSection(
                'User Profile',
                Icons.person,
                Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                          child: user?.photoURL != null
                              ? ClipOval(
                                  child: Image.network(
                                    user!.photoURL!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.person,
                                        size: 30,
                                        color: AppTheme.primaryColor,
                                      );
                                    },
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  size: 30,
                                  color: AppTheme.primaryColor,
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.displayName ?? user?.email?.split('@')[0] ?? 'User',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                user?.email ?? '',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        hintText: 'Enter new username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isUpdatingProfile ? null : _updateUsername,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isUpdatingProfile
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Update Username'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isChangingPassword ? null : _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isChangingPassword
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Change Password'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Skill Level Section
              _buildSection(
                'Skill Level',
                Icons.star,
                Column(
                  children: [
                    _buildSkillLevelSelector(settings.skillLevel),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Theme Mode Section
              _buildSection(
                'Theme Mode',
                Icons.palette,
                Column(
                  children: [
                    _buildToggleRow(
                      'Dark Mode',
                      settings.isDarkMode,
                      (value) => ref.read(settingsProvider.notifier).toggleDarkMode(),
                      Icons.dark_mode,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Background Music Section
              _buildSection(
                'Background Music',
                Icons.music_note,
                Column(
                  children: [
                    Consumer(
                      builder: (context, ref, child) {
                        final audioState = ref.watch(audioProvider);
                        return _buildToggleRow(
                          'Music',
                          audioState.isMusicEnabled,
                          (value) async {
                            await ref.read(audioProvider.notifier).toggleGlobalMusic(value);
                          },
                          Icons.music_note,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Notifications Section
              _buildSection(
                'Notifications',
                Icons.notifications,
                Column(
                  children: [
                    _buildToggleRow(
                      'Daily Fold Reminder',
                      settings.dailyReminderEnabled,
                      (value) => ref.read(settingsProvider.notifier).toggleDailyReminder(),
                      Icons.today,
                    ),
                    _buildToggleRow(
                      'New Quiz Alerts',
                      settings.quizAlertsEnabled,
                      (value) => ref.read(settingsProvider.notifier).toggleQuizAlerts(),
                      Icons.quiz,
                    ),
                    _buildToggleRow(
                      'Artist Blog Updates',
                      settings.blogUpdatesEnabled,
                      (value) => ref.read(settingsProvider.notifier).toggleBlogUpdates(),
                      Icons.brush,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Paper Selector Section
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaperTypesScreen(),
                    ),
                  );
                },
                child: _buildSection(
                  'Paper Types',
                  Icons.texture,
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Learn about different paper types',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildPaperGrid(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Logout Section
              _buildSection(
                'Account Actions',
                Icons.logout,
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _showLogoutDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout),
                            SizedBox(width: 8),
                            Text('Logout'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildToggleRow(String title, bool value, Function(bool) onChanged, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.secondaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppTheme.primaryColor,
            activeThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildSkillLevelSelector(String currentLevel) {
    final levels = ['Beginner', 'Moderate', 'Intermediate'];
    
    return Column(
      children: levels.map((level) {
        final isSelected = currentLevel == level;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: GestureDetector(
            onTap: () => ref.read(settingsProvider.notifier).setSkillLevel(level),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected 
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.1) 
                  : Theme.of(context).cardColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected 
                    ? Theme.of(context).primaryColor 
                    : Theme.of(context).dividerColor,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    level,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaperGrid() {
    final paperTypes = [
      {'name': 'Kami', 'icon': Icons.texture, 'color': Colors.orange},
      {'name': 'Duo Colored', 'icon': Icons.gradient, 'color': Colors.purple},
      {'name': 'Gradient', 'icon': Icons.auto_awesome, 'color': Colors.pink},
      {'name': 'Tissue Foil', 'icon': Icons.star, 'color': Colors.amber},
      {'name': 'Foil', 'icon': Icons.brightness_7, 'color': Colors.grey},
      {'name': 'Traditional Washi', 'icon': Icons.nature, 'color': Colors.brown},
      {'name': 'Patterned Paper', 'icon': Icons.pattern, 'color': Colors.teal},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: paperTypes.length,
      itemBuilder: (context, index) {
        final paper = paperTypes[index];
        return Container(
          decoration: BoxDecoration(
            color: (paper['color'] as Color).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: paper['color'] as Color),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                paper['icon'] as IconData,
                color: paper['color'] as Color,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                paper['name'] as String,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: paper['color'] as Color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
