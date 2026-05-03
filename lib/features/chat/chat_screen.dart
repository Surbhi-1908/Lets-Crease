import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/data/user_data.dart';
import '../../core/theme/app_theme.dart';
import 'user_profile_screen.dart';
import 'conversation_screen.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _users = [];
  List<User> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _users = UserData.getMockUsers();
    _filteredUsers = _users;
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterUsers);
    _searchController.dispose();
    super.dispose();
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((user) =>
        user.username.toLowerCase().contains(query) ||
        user.bio.toLowerCase().contains(query)
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect & Chat'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          
          // Users Grid
          Expanded(
            child: _filteredUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No users found',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return _UserCard(
                        user: user,
                        onChat: () => _startChat(user),
                        onProfile: () => _viewProfile(user),
                        onFollowToggle: () => _toggleFollow(user),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _startChat(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationScreen(user: user),
      ),
    );
  }

  void _viewProfile(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(user: user),
      ),
    );
  }

  void _toggleFollow(User user) {
    setState(() {
      final userIndex = _users.indexWhere((u) => u.id == user.id);
      if (userIndex != -1) {
        _users[userIndex] = _users[userIndex].copyWith(
          isFollowing: !_users[userIndex].isFollowing,
          followersCount: _users[userIndex].isFollowing
              ? _users[userIndex].followersCount - 1
              : _users[userIndex].followersCount + 1,
        );
        _filterUsers();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(user.isFollowing ? 'Unfollowed ${user.username}' : 'Following ${user.username}'),
        backgroundColor: AppTheme.primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final User user;
  final VoidCallback onChat;
  final VoidCallback onProfile;
  final VoidCallback onFollowToggle;

  const _UserCard({
    required this.user,
    required this.onChat,
    required this.onProfile,
    required this.onFollowToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onProfile,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  image: DecorationImage(
                    image: NetworkImage(user.profileImageUrl),
                    fit: BoxFit.cover,
                    onError: (error, stackTrace) {
                      // Fallback to avatar if image fails to load
                    },
                  ),
                ),
                child: user.profileImageUrl.startsWith('https')
                    ? null
                    : Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 48,
                          color: AppTheme.primaryColor,
                        ),
                      ),
              ),
            ),
            
            // User Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${user.followersCount} followers',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onChat,
                            icon: const Icon(Icons.chat, size: 16),
                            label: const Text('Chat'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.secondaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onFollowToggle,
                            icon: Icon(
                              user.isFollowing ? Icons.person_remove : Icons.person_add,
                              size: 16,
                            ),
                            label: Text(
                              user.isFollowing ? 'Unfollow' : 'Follow',
                              style: const TextStyle(fontSize: 12),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: user.isFollowing ? Colors.grey : AppTheme.primaryColor,
                              side: BorderSide(
                                color: user.isFollowing ? Colors.grey : AppTheme.primaryColor,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
