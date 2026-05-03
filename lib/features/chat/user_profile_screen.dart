import 'package:flutter/material.dart';
import '../../core/data/user_data.dart';
import '../../core/theme/app_theme.dart';
import 'conversation_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final User user;

  const UserProfileScreen({super.key, required this.user});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late User _currentUser;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _isFollowing = _currentUser.isFollowing;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentUser.username),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConversationScreen(user: _currentUser),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Profile Image
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                    backgroundImage: _currentUser.profileImageUrl.startsWith('https')
                        ? NetworkImage(_currentUser.profileImageUrl)
                        : null,
                    child: _currentUser.profileImageUrl.startsWith('https')
                        ? null
                        : Icon(
                            Icons.person,
                            size: 60,
                            color: AppTheme.primaryColor,
                          ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Username
                  Text(
                    _currentUser.username,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Bio
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _currentUser.bio,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('Followers', _currentUser.followersCount.toString()),
                      _buildStatItem('Following', _currentUser.followingCount.toString()),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Follow/Unfollow Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _toggleFollow,
                        icon: Icon(
                          _isFollowing ? Icons.person_remove : Icons.person_add,
                        ),
                        label: Text(
                          _isFollowing ? 'Unfollow' : 'Follow',
                          style: const TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFollowing ? Colors.grey : AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
            
            // Content Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('Username', '@${_currentUser.username}'),
                          const SizedBox(height: 12),
                          _buildInfoRow('Member Since', 'January 2024'),
                          const SizedBox(height: 12),
                          _buildInfoRow('Interests', 'Origami, Paper Crafts, Art'),
                          const SizedBox(height: 12),
                          _buildInfoRow('Favorite Models', 'Butterfly, Crane, Dragon'),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ConversationScreen(user: _currentUser),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.chat,
                                    size: 32,
                                    color: AppTheme.secondaryColor,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Send Message',
                                    style: Theme.of(context).textTheme.titleSmall,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Card(
                          child: InkWell(
                            onTap: _toggleFollow,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Icon(
                                    _isFollowing ? Icons.person_remove : Icons.person_add,
                                    size: 32,
                                    color: AppTheme.primaryColor,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _isFollowing ? 'Unfollow' : 'Follow',
                                    style: Theme.of(context).textTheme.titleSmall,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        const Text(': '),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  void _toggleFollow() {
    setState(() {
      _isFollowing = !_isFollowing;
      if (_isFollowing) {
        _currentUser = _currentUser.copyWith(
          isFollowing: true,
          followersCount: _currentUser.followersCount + 1,
        );
      } else {
        _currentUser = _currentUser.copyWith(
          isFollowing: false,
          followersCount: _currentUser.followersCount - 1,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFollowing ? 'Following ${_currentUser.username}' : 'Unfollowed ${_currentUser.username}'),
        backgroundColor: AppTheme.primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
