import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/audio_provider.dart';
import '../quiz/quiz_screen.dart';

class QuizzesScreen extends ConsumerStatefulWidget {
  const QuizzesScreen({super.key});

  @override
  ConsumerState<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends ConsumerState<QuizzesScreen> with TickerProviderStateMixin {
  late TabController _skillLevelController;
  late TabController _categoryController;
  
  String _selectedSkillLevel = 'Beginner';
  final List<String> _skillLevels = ['Beginner', 'Moderate', 'Intermediate'];
  final List<String> _categories = ['Artists', 'Papers', 'Folding Techniques', 'Traditional Origami'];
  
  @override
  void initState() {
    super.initState();
    _skillLevelController = TabController(length: _skillLevels.length, vsync: this);
    _categoryController = TabController(length: _categories.length, vsync: this);
    
    // Music is now handled globally, no need to start/stop per screen
  }

  @override
  void dispose() {
    _skillLevelController.dispose();
    _categoryController.dispose();
    // Music continues globally, no need to stop here
    super.dispose();
  }

  void _startQuiz(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          category: category,
          skillLevel: _selectedSkillLevel,
        ),
      ),
    );
  }

  Map<String, List<QuizItem>> _getQuizzesForSkillLevel(String skillLevel) {
    final quizzes = {
      'Artists': [
        QuizItem(
          title: 'Famous Origami Masters',
          description: 'Learn about renowned origami artists',
          difficulty: skillLevel,
          questions: skillLevel == 'Beginner' ? 8 : skillLevel == 'Moderate' ? 12 : 15,
          timeLimit: skillLevel == 'Beginner' ? 4 : skillLevel == 'Moderate' ? 6 : 8,
          points: skillLevel == 'Beginner' ? 80 : skillLevel == 'Moderate' ? 120 : 150,
          color: Colors.purple,
        ),
      ],
      'Papers': [
        QuizItem(
          title: 'Paper Types & Properties',
          description: 'Different papers used in origami',
          difficulty: skillLevel,
          questions: skillLevel == 'Beginner' ? 6 : skillLevel == 'Moderate' ? 10 : 12,
          timeLimit: skillLevel == 'Beginner' ? 3 : skillLevel == 'Moderate' ? 5 : 6,
          points: skillLevel == 'Beginner' ? 60 : skillLevel == 'Moderate' ? 100 : 120,
          color: AppTheme.secondaryColor,
        ),
      ],
      'Folding Techniques': [
        QuizItem(
          title: 'Basic to Advanced Folds',
          description: 'Master various folding techniques',
          difficulty: skillLevel,
          questions: skillLevel == 'Beginner' ? 10 : skillLevel == 'Moderate' ? 15 : 20,
          timeLimit: skillLevel == 'Beginner' ? 5 : skillLevel == 'Moderate' ? 8 : 12,
          points: skillLevel == 'Beginner' ? 100 : skillLevel == 'Moderate' ? 150 : 200,
          color: Colors.green,
        ),
      ],
      'Traditional Origami': [
        QuizItem(
          title: 'Classic Models & History',
          description: 'Traditional origami knowledge',
          difficulty: skillLevel,
          questions: skillLevel == 'Beginner' ? 8 : skillLevel == 'Moderate' ? 12 : 16,
          timeLimit: skillLevel == 'Beginner' ? 4 : skillLevel == 'Moderate' ? 6 : 8,
          points: skillLevel == 'Beginner' ? 80 : skillLevel == 'Moderate' ? 120 : 160,
          color: Colors.orange,
        ),
      ],
    };
    return quizzes;
  }

  @override
  Widget build(BuildContext context) {
    final currentQuizzes = _getQuizzesForSkillLevel(_selectedSkillLevel);
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Do You Know?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Test your origami knowledge and earn points',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              
              // Stats Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Total Score', '450', Icons.star),
                    _buildStatItem('Completed', '3', Icons.check_circle),
                    _buildStatItem('Rank', '#12', Icons.leaderboard),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Skill Level Selector
              Text(
                'Skill Level',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _skillLevelController,
                  indicator: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  dividerColor: Colors.transparent,
                  onTap: (index) {
                    setState(() {
                      _selectedSkillLevel = _skillLevels[index];
                    });
                  },
                  tabs: _skillLevels.map((level) => Tab(text: level)).toList(),
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                'Quiz Categories',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final quiz = currentQuizzes[category]?.first;
                    return _buildCategoryCard(category, quiz);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String category, QuizItem? quiz) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: InkWell(
        onTap: quiz != null ? () => _startQuiz(category) : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (quiz?.color ?? Colors.grey).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(category),
                  color: quiz?.color ?? Colors.grey,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                category,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              if (quiz != null) ...[
                Text(
                  quiz.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.help_outline, size: 14, color: Theme.of(context).iconTheme.color?.withOpacity(0.6)),
                    const SizedBox(width: 4),
                    Text(
                      '${quiz.questions}',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.star_outline, size: 14, color: Theme.of(context).iconTheme.color?.withOpacity(0.6)),
                    const SizedBox(width: 4),
                    Text(
                      '${quiz.points}',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(_selectedSkillLevel).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _selectedSkillLevel,
                  style: TextStyle(
                    color: _getDifficultyColor(_selectedSkillLevel),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Artists':
        return Icons.palette;
      case 'Papers':
        return Icons.description;
      case 'Folding Techniques':
        return Icons.gesture;
      case 'Traditional Origami':
        return Icons.auto_awesome;
      default:
        return Icons.quiz;
    }
  }


  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'moderate':
        return AppTheme.secondaryColor;
      case 'intermediate':
        return AppTheme.primaryColor;
      default:
        return Colors.grey;
    }
  }
}

class QuizItem {
  final String title;
  final String description;
  final String difficulty;
  final int questions;
  final int timeLimit;
  final int points;
  final Color color;

  QuizItem({
    required this.title,
    required this.description,
    required this.difficulty,
    required this.questions,
    required this.timeLimit,
    required this.points,
    required this.color,
  });
}
