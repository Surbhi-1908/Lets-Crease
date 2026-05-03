import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class QuizNotifications {
  static final List<String> _motivationalMessages = [
    "Quiz Complete! You nailed it! 🎉",
    "Sharp folds and sharp answers! ✨",
    "That's a wrap on that quiz! 📝",
    "Origami master in the making! 🏆",
    "Perfect score, perfect folds! ⭐",
    "Knowledge folded to perfection! 📚",
    "Quiz conquered like a crane! 🕊️",
    "Brilliant answers, brilliant mind! 💡",
    "You're on a roll... or should we say fold! 🎯",
    "Quiz mastery achieved! 🎊",
  ];

  static void showQuizCompletionNotification(
    BuildContext context, {
    int? score,
    int? totalQuestions,
  }) {
    final message = _getRandomMessage();
    final scoreText = score != null && totalQuestions != null 
        ? '\nScore: $score/$totalQuestions'
        : '';

    // Show animated snackbar with custom styling
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AnimatedQuizNotification(
          message: message,
          scoreText: scoreText,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static String _getRandomMessage() {
    final random = DateTime.now().millisecondsSinceEpoch % _motivationalMessages.length;
    return _motivationalMessages[random];
  }
}

class AnimatedQuizNotification extends StatefulWidget {
  final String message;
  final String scoreText;

  const AnimatedQuizNotification({
    super.key,
    required this.message,
    this.scoreText = '',
  });

  @override
  State<AnimatedQuizNotification> createState() => _AnimatedQuizNotificationState();
}

class _AnimatedQuizNotificationState extends State<AnimatedQuizNotification>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.bounceOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    // Start animations in sequence
    _startAnimations();
  }

  void _startAnimations() async {
    await _fadeController.forward();
    await _slideController.forward();
    await _scaleController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.secondaryColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.celebration,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.scoreText.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.scoreText,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
