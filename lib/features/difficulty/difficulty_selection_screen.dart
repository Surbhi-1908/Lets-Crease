import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

enum DifficultyLevel { beginner, moderate, intermediate }

class DifficultySelectionScreen extends ConsumerStatefulWidget {
  const DifficultySelectionScreen({super.key});

  @override
  ConsumerState<DifficultySelectionScreen> createState() => _DifficultySelectionScreenState();
}

class _DifficultySelectionScreenState extends ConsumerState<DifficultySelectionScreen>
    with TickerProviderStateMixin {
  DifficultyLevel? _selectedLevel;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectLevel(DifficultyLevel level) {
    setState(() {
      _selectedLevel = level;
    });
  }

  void _proceedToHome() {
    if (_selectedLevel != null) {
      // Store the selected difficulty level (you can add this to user preferences later)
      context.go('/main');
    }
  }

  String _getLevelDescription(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner:
        return 'Perfect for newcomers to origami\nSimple folds and basic models';
      case DifficultyLevel.moderate:
        return 'For those with some experience\nIntermediate techniques and models';
      case DifficultyLevel.intermediate:
        return 'Advanced origami enthusiasts\nComplex folds and challenging projects';
    }
  }

  Color _getLevelColor(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner:
        return Colors.green;
      case DifficultyLevel.moderate:
        return AppTheme.secondaryColor;
      case DifficultyLevel.intermediate:
        return AppTheme.primaryColor;
    }
  }

  IconData _getLevelIcon(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner:
        return Icons.star_outline;
      case DifficultyLevel.moderate:
        return Icons.star_half;
      case DifficultyLevel.intermediate:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  
                  // Header
                  Text(
                    'Select Your Level',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose the difficulty that matches your origami experience',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  
                  // Difficulty Options
                  Expanded(
                    child: ListView(
                      children: DifficultyLevel.values.map((level) {
                        final isSelected = _selectedLevel == level;
                        final levelColor = _getLevelColor(level);
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: GestureDetector(
                            onTap: () => _selectLevel(level),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isSelected ? levelColor.withOpacity(0.1) : Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? levelColor : Theme.of(context).dividerColor,
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected 
                                        ? levelColor.withOpacity(0.3)
                                        : Colors.black.withOpacity(0.05),
                                    blurRadius: isSelected ? 8 : 4,
                                    spreadRadius: isSelected ? 2 : 0,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: levelColor.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _getLevelIcon(level),
                                      color: levelColor,
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          level.name.toUpperCase(),
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: isSelected ? levelColor : Theme.of(context).textTheme.titleLarge?.color,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _getLevelDescription(level),
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color: levelColor,
                                      size: 24,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  // Continue Button
                  const SizedBox(height: 20),
                  AnimatedOpacity(
                    opacity: _selectedLevel != null ? 1.0 : 0.5,
                    duration: const Duration(milliseconds: 300),
                    child: ElevatedButton(
                      onPressed: _selectedLevel != null ? _proceedToHome : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Continue to Home',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
