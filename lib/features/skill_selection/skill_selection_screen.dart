import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/user_provider.dart';
import '../../core/theme/app_theme.dart';

class SkillSelectionScreen extends ConsumerStatefulWidget {
  const SkillSelectionScreen({super.key});

  @override
  ConsumerState<SkillSelectionScreen> createState() => _SkillSelectionScreenState();
}

class _SkillSelectionScreenState extends ConsumerState<SkillSelectionScreen> {
  String? _selectedSkillLevel;
  bool _isLoading = false;

  Future<void> _saveSkillLevel() async {
    if (_selectedSkillLevel == null) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(userNotifierProvider.notifier).updateSkillLevel(_selectedSkillLevel!);
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save skill level: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Icon(
                Icons.school_outlined,
                size: 80,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                'Choose Your Skill Level',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'This helps us recommend the right content for you',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Expanded(
                child: ListView.builder(
                  itemCount: AppConstants.skillLevels.length,
                  itemBuilder: (context, index) {
                    final skillLevel = AppConstants.skillLevels[index];
                    final isSelected = _selectedSkillLevel == skillLevel;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Card(
                        elevation: isSelected ? 8 : 2,
                        child: InkWell(
                          onTap: () => setState(() => _selectedSkillLevel = skillLevel),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: isSelected
                                  ? Border.all(color: AppTheme.primaryColor, width: 2)
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? AppTheme.primaryColor 
                                        : AppTheme.primaryColor.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getSkillIcon(skillLevel),
                                    color: isSelected ? Colors.white : AppTheme.primaryColor,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        skillLevel,
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? AppTheme.primaryColor : null,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _getSkillDescription(skillLevel),
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: AppTheme.primaryColor,
                                    size: 24,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _selectedSkillLevel == null || _isLoading ? null : _saveSkillLevel,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSkillIcon(String skillLevel) {
    switch (skillLevel) {
      case 'Beginner':
        return Icons.star_outline;
      case 'Moderate':
        return Icons.star_half;
      case 'Advanced':
        return Icons.star;
      default:
        return Icons.star_outline;
    }
  }

  String _getSkillDescription(String skillLevel) {
    switch (skillLevel) {
      case 'Beginner':
        return 'New to origami, learning basic folds';
      case 'Moderate':
        return 'Familiar with basic models, ready for intermediate';
      case 'Advanced':
        return 'Experienced folder, ready for complex models';
      default:
        return '';
    }
  }
}
