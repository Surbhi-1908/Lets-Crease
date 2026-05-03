import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/audio_provider.dart';
import 'fictional_models_screen.dart';
import 'models_screen.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  
  @override
  void initState() {
    super.initState();
    // Music is now handled globally, no need to start/stop per screen
  }

  @override
  void dispose() {
    // Music continues globally, no need to stop here
    super.dispose();
  }
  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Animals',
      'icon': Icons.pets,
      'color': Colors.green,
      'description': 'Cute animal origami models',
      'modelCount': 15,
    },
    {
      'name': 'Birds',
      'icon': Icons.flutter_dash,
      'color': Colors.blue,
      'description': 'Flying creatures and birds',
      'modelCount': 8,
    },
    {
      'name': 'Kusudamas',
      'icon': Icons.circle,
      'color': Colors.orange,
      'description': 'Modular ball origami',
      'modelCount': 6,
    },
    {
      'name': 'Tessellations',
      'icon': Icons.grid_on,
      'color': Colors.purple,
      'description': 'Geometric pattern folding',
      'modelCount': 4,
    },
    {
      'name': 'Modular',
      'icon': Icons.view_module,
      'color': Colors.teal,
      'description': 'Multi-piece constructions',
      'modelCount': 12,
    },
    {
      'name': 'Stars',
      'icon': Icons.star,
      'color': Colors.amber,
      'description': 'Star and celestial models',
      'modelCount': 7,
    },
    {
      'name': 'Fictional',
      'icon': Icons.auto_stories,
      'color': Colors.deepPurple,
      'description': 'Characters and fantasy models',
      'modelCount': 4,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Folding Categories',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a category to explore origami models',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _buildCategoryCard(category);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ModelsScreen(categoryName: category['name']),
          ),
        );
      },
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: (category['color'] as Color).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Icon(
                  category['icon'] as IconData,
                  size: 40,
                  color: category['color'] as Color,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category['name'],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category['description'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${category['modelCount']} models',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: category['color'] as Color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Theme.of(context).iconTheme.color?.withOpacity(0.4),
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

class CategoryItem {
  final String name;
  final IconData icon;
  final Color color;
  final String description;
  final int modelCount;

  CategoryItem({
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
    required this.modelCount,
  });
}
