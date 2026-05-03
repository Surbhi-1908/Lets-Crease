import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/blog_model.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/audio_provider.dart';

class BlogScreen extends ConsumerStatefulWidget {
  const BlogScreen({super.key});

  @override
  ConsumerState<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends ConsumerState<BlogScreen> {
  
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

  @override
  Widget build(BuildContext context) {
    final blogs = _getSampleBlogs();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Origami Artists'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: blogs.length,
        itemBuilder: (context, index) {
          final blog = blogs[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Card(
              child: InkWell(
                onTap: () => _showBlogDetail(context, blog),
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        child: blog.imageUrl.isNotEmpty
                            ? Container(
                                width: double.infinity,
                                height: double.infinity,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              )
                            : Icon(
                                Icons.person,
                                size: 80,
                                color: AppTheme.primaryColor,
                              ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            blog.artistName,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            blog.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            blog.content,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: blog.tags.map((tag) => Chip(
                              label: Text(tag),
                              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                              labelStyle: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 12,
                              ),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showBlogDetail(BuildContext context, BlogModel blog) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  height: 200,
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: blog.imageUrl.isNotEmpty
                      ? Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 80,
                          color: AppTheme.primaryColor,
                        ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          blog.artistName,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          blog.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          blog.content,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<BlogModel> _getSampleBlogs() {
    return [
      BlogModel(
        id: '1',
        title: 'The Master of Wet-Folding',
        content: 'Akira Yoshizawa (1911-2005) revolutionized origami with his wet-folding technique, which allows for more organic, curved forms. He is credited with elevating origami from a craft to an art form. His innovative approach involved dampening the paper slightly during folding, enabling the creation of more lifelike and expressive models. Yoshizawa created over 50,000 models during his lifetime and is considered the father of modern origami.',
        artistName: 'Akira Yoshizawa',
        imageUrl: '',
        publishedAt: DateTime.now().subtract(const Duration(days: 7)),
        tags: ['Master', 'Wet-folding', 'Innovation'],
      ),
      BlogModel(
        id: '2',
        title: 'Mathematics Meets Art',
        content: 'Robert J. Lang is a physicist and mathematician who has applied scientific principles to origami design. His work combines complex mathematical algorithms with artistic vision, creating incredibly detailed and realistic models. Lang has developed computer programs that can design crease patterns for almost any shape, pushing the boundaries of what\'s possible in paper folding. His models often feature hundreds of steps and require precise execution.',
        artistName: 'Robert J. Lang',
        imageUrl: '',
        publishedAt: DateTime.now().subtract(const Duration(days: 14)),
        tags: ['Mathematics', 'Computer Design', 'Complex Models'],
      ),
      BlogModel(
        id: '3',
        title: 'The Modular Origami Pioneer',
        content: 'Tomoko Fuse is renowned for her work in modular origami, creating beautiful geometric forms by assembling multiple identical units. Her designs range from simple cubes to complex polyhedra, all created without cuts or glue. Fuse has authored numerous books on modular origami and has inspired countless folders to explore the mathematical beauty of geometric paper folding. Her work demonstrates how simple units can combine to create stunning complexity.',
        artistName: 'Tomoko Fuse',
        imageUrl: '',
        publishedAt: DateTime.now().subtract(const Duration(days: 21)),
        tags: ['Modular', 'Geometric', 'Unit Folding'],
      ),
      BlogModel(
        id: '4',
        title: 'Super Complex Origami',
        content: 'Satoshi Kamiya is famous for creating some of the most complex origami models ever designed. His works, such as the Ancient Dragon and Bahamut, can take days or even weeks to complete and require hundreds of precise folds. Kamiya\'s designs push the limits of what can be achieved with a single sheet of paper, creating incredibly detailed figures with intricate features like scales, claws, and facial expressions.',
        artistName: 'Satoshi Kamiya',
        imageUrl: '',
        publishedAt: DateTime.now().subtract(const Duration(days: 28)),
        tags: ['Complex', 'Dragons', 'Super Detail'],
      ),
    ];
  }
}
