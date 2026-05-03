class AppConstants {
  static const String appName = 'Origami Master';
  static const String appVersion = '1.0.0';
  
  // Collections
  static const String usersCollection = 'users';
  static const String quizzesCollection = 'quizzes';
  static const String blogsCollection = 'blogs';
  static const String foldingHistoryCollection = 'folding_history';
  
  // Storage paths
  static const String profileImagesPath = 'profile_images';
  static const String foldingImagesPath = 'folding_images';
  
  // Skill levels
  static const List<String> skillLevels = ['Beginner', 'Moderate', 'Advanced'];
  
  // Categories
  static const List<String> origamiCategories = [
    'Animals',
    'Birds', 
    'Kusudamas',
    'Modular',
    'Stars',
    'Fictional'
  ];
  
  // Quiz categories
  static const List<String> quizCategories = [
    'Artists',
    'History',
    'Paper',
    'Folds'
  ];
}
