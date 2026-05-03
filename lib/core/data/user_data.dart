class User {
  final String id;
  final String username;
  final String profileImageUrl;
  final String bio;
  final int followersCount;
  final int followingCount;
  final bool isFollowing;

  const User({
    required this.id,
    required this.username,
    required this.profileImageUrl,
    required this.bio,
    required this.followersCount,
    required this.followingCount,
    this.isFollowing = false,
  });

  User copyWith({
    String? id,
    String? username,
    String? profileImageUrl,
    String? bio,
    int? followersCount,
    int? followingCount,
    bool? isFollowing,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}

class UserData {
  static List<User> getMockUsers() {
    return [
      User(
        id: '1',
        username: 'Riteeka',
        profileImageUrl: 'https://picsum.photos/seed/riteeka/200/200.jpg',
        bio: 'Passionate origami artist',
        followersCount: 1250,
        followingCount: 89,
      ),
      User(
        id: '2',
        username: 'Anurag',
        profileImageUrl: 'https://picsum.photos/seed/anurag/200/200.jpg',
        bio: 'Love creating complex modular origami pieces',
        followersCount: 890,
        followingCount: 156,
      ),
      User(
        id: '3',
        username: 'MagicHands',
        profileImageUrl: 'https://picsum.photos/seed/magichands/200/200.jpg',
        bio: 'Specializing in traditional Japanese origami',
        followersCount: 2100,
        followingCount: 45,
      ),
      User(
        id: '4',
        username: 'Surbhi',
        profileImageUrl: 'https://picsum.photos/seed/surbhi/200/200.jpg',
        bio: 'Butterfly origami enthusiast 🦋',
        followersCount: 567,
        followingCount: 234,
      ),
      User(
        id: '5',
        username: 'Thakur',
        profileImageUrl: 'https://picsum.photos/seed/thakur/200/200.jpg',
        bio: 'Teaching origami to beginners worldwide',
        followersCount: 3200,
        followingCount: 12,
      ),
    ];
  }
}
