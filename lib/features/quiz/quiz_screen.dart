import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/quiz_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String category;
  final String skillLevel;
  
  const QuizScreen({super.key, required this.category, required this.skillLevel});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int? _selectedAnswer;
  bool _showExplanation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeQuiz();
    });
  }

  void _initializeQuiz() {
    final questions = ref.read(quizQuestionsByCategoryProvider({
      'category': widget.category,
      'skillLevel': widget.skillLevel,
    }));
    ref.read(quizStateProvider.notifier).startQuiz(questions, '${widget.category} - ${widget.skillLevel}');
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      _selectedAnswer = answerIndex;
      _showExplanation = false;
    });
  }

  void _submitAnswer() {
    if (_selectedAnswer == null) return;

    ref.read(quizStateProvider.notifier).answerQuestion(_selectedAnswer!);
    setState(() => _showExplanation = true);
  }

  void _nextQuestion() {
    ref.read(quizStateProvider.notifier).nextQuestion();
    setState(() {
      _selectedAnswer = null;
      _showExplanation = false;
    });
  }

  Future<void> _finishQuiz() async {
    final quizState = ref.read(quizStateProvider);
    final user = ref.read(authStateProvider).value;
    
    if (user != null) {
      await ref.read(userNotifierProvider.notifier).updateQuizScore(
        '${widget.category}_${widget.skillLevel}',
        quizState.score,
      );
    }
    
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Quiz Complete!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.celebration,
                size: 64,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Your Score: ${quizState.score}/${quizState.questions.length}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getScoreMessage(quizState.score, quizState.questions.length),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/home');
              },
              child: const Text('Home'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Go back to main screen with quizzes tab
              },
              child: const Text('More Quizzes'),
            ),
          ],
        ),
      );
    }
  }

  String _getScoreMessage(int score, int total) {
    final percentage = (score / total * 100).round();
    if (percentage >= 80) return 'Excellent! You\'re an origami expert!';
    if (percentage >= 60) return 'Good job! Keep learning!';
    if (percentage >= 40) return 'Not bad! Practice makes perfect!';
    return 'Keep studying and try again!';
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizStateProvider);
    
    if (quizState.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('${widget.category} Quiz')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (quizState.isCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _finishQuiz());
    }

    final currentQuestion = quizState.questions[quizState.currentQuestionIndex];
    final progress = (quizState.currentQuestionIndex + 1) / quizState.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} - ${widget.skillLevel}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${quizState.currentQuestionIndex + 1}/${quizState.questions.length}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Score: ${quizState.score}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  currentQuestion.question,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: currentQuestion.options.length,
                itemBuilder: (context, index) {
                  final option = currentQuestion.options[index];
                  final isSelected = _selectedAnswer == index;
                  final isCorrect = index == currentQuestion.correctAnswerIndex;
                  final showResult = _showExplanation;
                  
                  Color? cardColor;
                  if (showResult) {
                    if (isCorrect) {
                      cardColor = Colors.green.withValues(alpha: 0.1);
                    } else if (isSelected && !isCorrect) {
                      cardColor = Colors.red.withValues(alpha: 0.1);
                    }
                  } else if (isSelected) {
                    cardColor = AppTheme.primaryColor.withValues(alpha: 0.1);
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      color: cardColor,
                      child: InkWell(
                        onTap: showResult ? null : () => _selectAnswer(index),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: isSelected
                                ? Border.all(color: AppTheme.primaryColor, width: 2)
                                : showResult && isCorrect
                                    ? Border.all(color: Colors.green, width: 2)
                                    : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected 
                                      ? AppTheme.primaryColor 
                                      : Colors.grey[300],
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + index), // A, B, C, D
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.grey[600],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  option,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              if (showResult && isCorrect)
                                const Icon(Icons.check_circle, color: Colors.green),
                              if (showResult && isSelected && !isCorrect)
                                const Icon(Icons.cancel, color: Colors.red),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_showExplanation) ...[
              Card(
                color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: AppTheme.secondaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Explanation',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentQuestion.explanation,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton(
              onPressed: _selectedAnswer == null
                  ? null
                  : _showExplanation
                      ? _nextQuestion
                      : _submitAnswer,
              child: Text(_showExplanation ? 'Next Question' : 'Submit Answer'),
            ),
          ],
        ),
      ),
    );
  }
}
