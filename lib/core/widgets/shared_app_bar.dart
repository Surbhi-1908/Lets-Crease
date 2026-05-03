import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/audio_provider.dart';

class SharedAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final List<Widget>? actions;
  final bool showMusicToggle;

  const SharedAppBar({
    super.key,
    this.showBackButton = false,
    this.actions,
    this.showMusicToggle = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioProvider);
    
    List<Widget> appBarActions = [];
    
    // Add music toggle if enabled
    if (showMusicToggle) {
      appBarActions.add(
        IconButton(
          icon: Icon(
            audioState.isMusicEnabled ? Icons.music_note : Icons.music_off,
            color: audioState.isMusicEnabled ? AppTheme.primaryColor : Colors.grey,
          ),
          onPressed: () async {
            try {
              final newState = !audioState.isMusicEnabled;
              await ref.read(audioProvider.notifier).toggleGlobalMusic(newState);
              
              // Show feedback to user
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          newState ? Icons.music_note : Icons.music_off,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(newState ? 'Music turned ON' : 'Music turned OFF'),
                      ],
                    ),
                    duration: const Duration(seconds: 2),
                    backgroundColor: newState ? Colors.green : Colors.grey[600],
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }
            } catch (e) {
              // Show error feedback
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error toggling music: $e'),
                    backgroundColor: AppTheme.errorColor,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            }
          },
          tooltip: audioState.isMusicEnabled ? 'Turn off music' : 'Turn on music',
        ),
      );
    }
    
    // Add custom actions or default menu
    if (actions != null) {
      appBarActions.addAll(actions!);
    } else {
      appBarActions.add(
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ),
      );
    }
    
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      elevation: 0,
      centerTitle: true,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      title: Text(
        'Let\'s Crease!',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
      actions: appBarActions,
    );
  }
}

class SharedDrawer extends ConsumerWidget {
  const SharedDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'Let\'s Crease!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Origami Made Simple',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              context.push('/settings');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Close drawer
                try {
                  await ref.read(authNotifierProvider.notifier).signOut();
                  if (context.mounted) {
                    context.go('/login');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error signing out: $e'),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                  }
                }
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
