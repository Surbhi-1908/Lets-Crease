import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class PaperTypeInfo {
  final String name;
  final String description;
  final String whenToUse;
  final String bestSuitedCategory;
  final String recommendedSize;
  final IconData icon;
  final Color color;

  const PaperTypeInfo({
    required this.name,
    required this.description,
    required this.whenToUse,
    required this.bestSuitedCategory,
    required this.recommendedSize,
    required this.icon,
    required this.color,
  });
}

class PaperTypesScreen extends StatelessWidget {
  const PaperTypesScreen({super.key});

  static const List<PaperTypeInfo> paperTypes = [
    PaperTypeInfo(
      name: 'Kami',
      description: 'Standard origami paper with a white back and colored front. Perfect for beginners and everyday folding.',
      whenToUse: 'Ideal for practice, learning new models, and everyday origami projects.',
      bestSuitedCategory: 'Traditional Models, Animals, Basic Figures',
      recommendedSize: '15cm x 15cm (6" x 6")',
      icon: Icons.texture,
      color: Colors.orange,
    ),
    PaperTypeInfo(
      name: 'Duo Colored',
      description: 'Paper with different colors on each side, creating beautiful contrast in finished models.',
      whenToUse: 'Perfect for models that show both sides of the paper, like animals and decorative pieces.',
      bestSuitedCategory: 'Animals, Birds, Decorative Models',
      recommendedSize: '15cm x 15cm (6" x 6")',
      icon: Icons.gradient,
      color: Colors.purple,
    ),
    PaperTypeInfo(
      name: 'Gradient',
      description: 'Paper with smooth color transitions that add depth and elegance to your origami creations.',
      whenToUse: 'Excellent for artistic models, flowers, and pieces where color flow enhances the design.',
      bestSuitedCategory: 'Flowers, Artistic Models, Decorative Pieces',
      recommendedSize: '18cm x 18cm (7" x 7")',
      icon: Icons.auto_awesome,
      color: Colors.pink,
    ),
    PaperTypeInfo(
      name: 'Tissue Foil',
      description: 'Thin tissue paper backed with foil, combining strength with delicate folding capabilities.',
      whenToUse: 'Best for complex models requiring sharp creases and holding shape well.',
      bestSuitedCategory: 'Complex Models, Modular Origami, Tessellations',
      recommendedSize: '20cm x 20cm (8" x 8")',
      icon: Icons.star,
      color: Colors.amber,
    ),
    PaperTypeInfo(
      name: 'Foil',
      description: 'Metallic paper that holds creases exceptionally well and creates eye-catching finished pieces.',
      whenToUse: 'Great for display pieces, models that need to maintain shape, and decorative origami.',
      bestSuitedCategory: 'Display Models, Decorative Pieces, Stars',
      recommendedSize: '15cm x 15cm (6" x 6")',
      icon: Icons.brightness_7,
      color: Colors.grey,
    ),
    PaperTypeInfo(
      name: 'Traditional Washi',
      description: 'High-quality Japanese paper known for its strength, texture, and traditional aesthetic.',
      whenToUse: 'Perfect for traditional models, ceremonial pieces, and premium origami art.',
      bestSuitedCategory: 'Traditional Origami, Ceremonial Models, Premium Art',
      recommendedSize: '25cm x 25cm (10" x 10")',
      icon: Icons.nature,
      color: Colors.brown,
    ),
    PaperTypeInfo(
      name: 'Patterned Paper',
      description: 'Paper with printed patterns that add visual interest and personality to your models.',
      whenToUse: 'Ideal for fun, creative projects and models where patterns enhance the design.',
      bestSuitedCategory: 'Fun Models, Children\'s Projects, Creative Pieces',
      recommendedSize: '15cm x 15cm (6" x 6")',
      icon: Icons.pattern,
      color: Colors.teal,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paper Types Guide'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: paperTypes.length,
        itemBuilder: (context, index) {
          final paperType = paperTypes[index];
          return _PaperTypeCard(paperType: paperType);
        },
      ),
    );
  }
}

class _PaperTypeCard extends StatelessWidget {
  final PaperTypeInfo paperType;

  const _PaperTypeCard({required this.paperType});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: paperType.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            paperType.icon,
            color: paperType.color,
            size: 24,
          ),
        ),
        title: Text(
          paperType.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: paperType.color,
          ),
        ),
        subtitle: Text(
          paperType.description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection(
                  'When to Use',
                  paperType.whenToUse,
                  Icons.schedule,
                  Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildInfoSection(
                  'Best Suited For',
                  paperType.bestSuitedCategory,
                  Icons.category,
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _buildInfoSection(
                  'Recommended Size',
                  paperType.recommendedSize,
                  Icons.straighten,
                  Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildTipsSection(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipsSection(BuildContext context) {
    final tips = _getTipsForPaperType(paperType.name);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                size: 16,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                'Pro Tips',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    tip,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  List<String> _getTipsForPaperType(String paperName) {
    switch (paperName) {
      case 'Kami':
        return [
          'Start with kami paper when learning new models',
          'Crease firmly as it holds shapes well',
          'Available in many colors and affordable',
        ];
      case 'Duo Colored':
        return [
          'Plan your folds to show both colors effectively',
          'Great for models like animals where contrast matters',
          'Consider which color should be dominant',
        ];
      case 'Gradient':
        return [
          'Let the color flow guide your folding direction',
          'Perfect for flowers and natural forms',
          'Avoid complex models that hide the gradient',
        ];
      case 'Tissue Foil':
        return [
          'Handle gently as it can tear if stressed',
          'Excellent for wet folding techniques',
          'Creates sharp, lasting creases',
        ];
      case 'Foil':
        return [
          'Use bone folder for extra sharp creases',
          'Avoid finger marks as they show easily',
          'Perfect for display pieces that need to hold shape',
        ];
      case 'Traditional Washi':
        return [
          'Respect the paper\'s traditional qualities',
          'Best for experienced folders',
          'Often more expensive - use for special pieces',
        ];
      case 'Patterned Paper':
        return [
          'Choose patterns that complement the model',
          'Avoid busy patterns for complex models',
          'Great for children\'s origami projects',
        ];
      default:
        return ['Experiment and discover what works best!'];
    }
  }
}
