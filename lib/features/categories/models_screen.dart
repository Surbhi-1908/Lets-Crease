import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/data/fictional_models_data.dart';
import '../../core/data/animals_models_data.dart';
import '../pdf_viewer/pdf_viewer_screen.dart';
import '../pdf_viewer/image_viewer_screen.dart';
import '../simulator/origami_simulator_bottom_bar.dart';
import '../youtube_player/youtube_player_screen.dart';

class ModelsScreen extends ConsumerStatefulWidget {
  final String categoryName;
  
  const ModelsScreen({
    super.key,
    required this.categoryName,
  });

  @override
  ConsumerState<ModelsScreen> createState() => _ModelsScreenState();
}

class _ModelsScreenState extends ConsumerState<ModelsScreen> {
  
  List<ModelItem> _getModelsForCategory(String category) {
    switch (category) {
      case 'Animals':
        return AnimalsModelsData.getAnimalsModels().map((model) => 
          ModelItem(
            name: model.name,
            difficulty: model.difficulty,
            steps: model.estimatedTime,
            description: model.description,
            pdfPath: model.pdfPath,
          )
        ).toList();
      case 'Birds':
        return [
          ModelItem(name: 'Butterfly', difficulty: 'Beginner', steps: 12, description: 'Beautiful butterfly model', pdfPath: 'assets/pdfs/Butterfly .pdf', youtubeUrl: 'https://youtu.be/MyIdJxLbC4g?si=6_Syqi0UQD00zjeL'),
        ];
      case 'Butterfly':
        return [
          ModelItem(name: 'Butterfly', difficulty: 'Beginner', steps: 12, description: 'Beautiful butterfly model', pdfPath: 'assets/pdfs/Butterfly .pdf'),
        ];
      case 'Flowers':
        return [
          ModelItem(name: 'Rose', difficulty: 'Advanced', steps: 22, description: 'Beautiful blooming rose'),
          ModelItem(name: 'Lily', difficulty: 'Intermediate', steps: 16, description: 'Elegant lily flower'),
          ModelItem(name: 'Tulip', difficulty: 'Beginner', steps: 10, description: 'Simple tulip bloom'),
          ModelItem(name: 'Lotus', difficulty: 'Advanced', steps: 26, description: 'Sacred lotus flower'),
        ];
      case 'Geometric':
        return [
          ModelItem(name: 'Cube', difficulty: 'Intermediate', steps: 18, description: 'Perfect geometric cube'),
          ModelItem(name: 'Pyramid', difficulty: 'Beginner', steps: 12, description: 'Four-sided pyramid'),
          ModelItem(name: 'Dodecahedron', difficulty: 'Expert', steps: 35, description: 'Complex 12-faced polyhedron'),
          ModelItem(name: 'Octahedron', difficulty: 'Advanced', steps: 24, description: 'Eight-faced geometric shape'),
        ];
      case 'Traditional':
        return [
          ModelItem(name: 'Paper Boat', difficulty: 'Easy', steps: 6, description: 'Classic floating boat'),
          ModelItem(name: 'Paper Hat', difficulty: 'Easy', steps: 5, description: 'Simple paper hat'),
          ModelItem(name: 'Fortune Teller', difficulty: 'Beginner', steps: 8, description: 'Interactive fortune teller'),
          ModelItem(name: 'Samurai Helmet', difficulty: 'Intermediate', steps: 15, description: 'Traditional warrior helmet'),
          ModelItem(name: 'Kimono', difficulty: 'Advanced', steps: 20, description: 'Traditional Japanese garment'),
        ];
      case 'Modular':
        return [
          ModelItem(name: 'Sonobe Cube', difficulty: 'Advanced', steps: 30, description: 'Interlocking cube modules'),
          ModelItem(name: 'Kusudama Ball', difficulty: 'Expert', steps: 40, description: 'Decorative flower ball'),
          ModelItem(name: 'Star Ball', difficulty: 'Advanced', steps: 35, description: 'Spiky star sphere'),
          ModelItem(name: 'Polyhedron', difficulty: 'Expert', steps: 45, description: 'Complex geometric form'),
        ];
      case 'Fictional':
        return FictionalModelsData.getFictionalModels().map((model) => 
          ModelItem(
            name: model.name,
            difficulty: model.difficulty,
            steps: model.estimatedTime, // Use estimatedTime as steps approximation
            description: model.description,
            pdfPath: model.pdfPath,
          )
        ).toList();
      default:
        return [];
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'beginner':
        return Colors.lightGreen;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      case 'expert':
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Icons.star;
      case 'beginner':
        return Icons.star_half;
      case 'intermediate':
        return Icons.stars;
      case 'advanced':
        return Icons.auto_awesome;
      case 'expert':
        return Icons.diamond;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final models = _getModelsForCategory(widget.categoryName);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.categoryName} Models'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: models.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 64,
                    color: Theme.of(context).disabledColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No models available yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back soon for new ${widget.categoryName.toLowerCase()} models!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).disabledColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: models.length,
              itemBuilder: (context, index) {
                final model = models[index];
                return _buildModelCard(model);
              },
            ),
    );
  }

  Widget _buildModelCard(ModelItem model) {
    final difficultyColor = _getDifficultyColor(model.difficulty);
    final isButterfly = model.name == 'Butterfly';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: isButterfly ? null : () => _openModel(model),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isButterfly ? Icons.flutter_dash : Icons.auto_awesome,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          model.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: difficultyColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: difficultyColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getDifficultyIcon(model.difficulty),
                          size: 16,
                          color: difficultyColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          model.difficulty,
                          style: TextStyle(
                            color: difficultyColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.list_alt,
                          size: 16,
                          color: AppTheme.secondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${model.steps} steps',
                          style: TextStyle(
                            color: AppTheme.secondaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isButterfly) ...[
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context).iconTheme.color?.withOpacity(0.4),
                    ),
                  ],
                ],
              ),
              if (isButterfly) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: '📄',
                        label: 'View PDF',
                        color: Colors.blue.shade100,
                        textColor: Colors.blue.shade700,
                        onTap: () => _openPdf(model),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        icon: '▶️',
                        label: 'Watch Tutorial',
                        color: Colors.red.shade100,
                        textColor: Colors.red.shade700,
                        onTap: () => _openYouTubeVideo(model),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String icon,
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: textColor.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  icon,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openPdf(ModelItem model) {
    if (model.pdfPath != null) {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => PdfViewerScreen(
            pdfPath: model.pdfPath!,
            modelName: model.name,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    }
  }

  void _openYouTubeVideo(ModelItem model) {
    if (model.youtubeUrl != null) {
      final videoId = YoutubePlayer.convertUrlToId(model.youtubeUrl!);
      if (videoId != null) {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => YouTubePlayerScreen(
              videoId: videoId,
              modelName: model.name,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;

              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        );
      }
    }
  }

  void _openModel(ModelItem model) {
    if (model.pdfPath != null) {
      // Handle models with PDF/image files
      if (model.pdfPath!.toLowerCase().endsWith('.jpg') || 
          model.pdfPath!.toLowerCase().endsWith('.jpeg')) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ImageViewerScreen(
              imagePath: model.pdfPath!,
              modelName: model.name,
            ),
          ),
        ).then((_) {
          // This ensures we stay on the models screen when returning from image viewer
          if (mounted) {
            setState(() {
              // Refresh the screen state if needed
            });
          }
        });
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PdfViewerScreen(
              pdfPath: model.pdfPath!,
              modelName: model.name,
            ),
          ),
        ).then((_) {
          // This ensures we stay on the models screen when returning from PDF viewer
          if (mounted) {
            setState(() {
              // Refresh the screen state if needed
            });
          }
        });
      }
    } else {
      // Navigate to simulator for other models
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const OrigamiSimulatorScreen(),
        ),
      ).then((_) {
        // This ensures we stay on the models screen when returning from simulator
        if (mounted) {
          setState(() {
            // Refresh the screen state if needed
          });
        }
      });
    }
  }
}

class ModelItem {
  final String name;
  final String difficulty;
  final int steps;
  final String description;
  final String? pdfPath;
  final String? youtubeUrl;

  ModelItem({
    required this.name,
    required this.difficulty,
    required this.steps,
    required this.description,
    this.pdfPath,
    this.youtubeUrl,
  });
}
