import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:lets_crease/features/home/butterfly_image_card.dart';
import '../../core/data/fictional_models_data.dart';
import '../../core/theme/app_theme.dart';
import '../pdf_viewer/pdf_viewer_screen.dart';
import '../pdf_viewer/image_viewer_screen.dart';
import '../quiz/quiz_screen.dart';
import '../simulator/folding_simulator_Home_page.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final VoidCallback? onNavigateToCategories;
  
  const HomeScreen({super.key, this.onNavigateToCategories});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  File? _selectedImage;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _showImageSourceDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Your Fold'),
        content: const Text('Choose how to add your origami creation:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImageFromCamera();
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt),
                SizedBox(width: 8),
                Text('Camera'),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImageFromGallery();
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.photo_library),
                SizedBox(width: 8),
                Text('Gallery'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedPreview() {
    if (_selectedImage == null) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 200,
        maxHeight: 400, // Allow more height for better visibility
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: GestureDetector(
        onTap: () => _showFullScreenImage(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            _selectedImage!,
            fit: BoxFit.contain, // Changed from cover to contain to show full image
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                color: Colors.grey.shade100,
                child: const Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      setState(() => _isUploading = true);
      
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 2400, // Increased for better quality
        maxHeight: 2400, // Increased for better quality
        imageQuality: 95, // Increased quality for clearer images
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo captured successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showFullScreenImage() {
    if (_selectedImage == null) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: const Text('Your Origami Creation'),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Share functionality coming soon!'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
              ),
            ],
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.file(
                _selectedImage!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 100,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      setState(() => _isUploading = true);
      
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2400, // Increased for better quality
        maxHeight: 2400, // Increased for better quality
        imageQuality: 95, // Increased quality for clearer images
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image selected successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Let\'s Crease!'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Fold of the Day Section with Butterfly
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Header
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Fold of the Day!',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  // Butterfly Card
                  ButterflyImageCard(
                    assetPath: 'assets/pdfs/Butterfly .pdf',
                    onStartFolding: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => PdfViewerScreen(
                            pdfPath: 'assets/pdfs/Butterfly .pdf',
                            modelName: 'Butterfly',
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
                    },
                  ),
                ],
              ),
            ),

            // Let's Fold Section
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.category,
                          color: AppTheme.secondaryColor,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Let\'s Fold!',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose a category and start your origami journey',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (widget.onNavigateToCategories != null) {
                            widget.onNavigateToCategories!();
                          } else {
                            _showCategoriesDialog();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Select Category',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Do You Know? Section
            Text(
              'Do You Know?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Test your origami knowledge',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            _buildQuizGrid(),
            const SizedBox(height: 24),
            
            // Action Cards Section
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 48,
                            color: AppTheme.secondaryColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Share Your Creation',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Upload photos of your origami folds',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _isUploading ? null : _showImageSourceDialog,
                            icon: _isUploading 
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.add_a_photo),
                            label: Text(_isUploading ? 'Uploading...' : 'Add Photo'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.view_in_ar,
                            size: 48,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Folding Simulator',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Practice folding with 3D simulator',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FoldingSimulatorScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Start Simulator'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (_selectedImage != null)
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Preview',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    _buildSelectedPreview(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedImage = null;
                              });
                            },
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Remove'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showImageSourceDialog,
                            icon: const Icon(Icons.image_search),
                            label: const Text('Reselect'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCategoriesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Origami Categories',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 5, // Fixed number of categories
            itemBuilder: (context, index) {
              final categories = ['Animals', 'Birds', 'Butterfly', 'Kusudamas', 'Fictional'];
              final category = categories[index];
              return ListTile(
                leading: Icon(
                  _getCategoryIcon(category),
                  color: AppTheme.secondaryColor,
                ),
                title: Text(
                  category,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showModelsDialog(category);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showModelsDialog(String category) {
    final models = _getModelsForCategory(category);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          '$category Models',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: models.length,
            itemBuilder: (context, index) {
              final model = models[index];
              return ListTile(
                leading: Icon(
                  Icons.description,
                  color: AppTheme.secondaryColor,
                ),
                title: Text(
                  model,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                subtitle: Text(
                  'Tap to view diagram',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  if (category == 'Fictional') {
                    final fictionalModel = FictionalModelsData.getFictionalModels()
                        .firstWhere((m) => m.name == model, orElse: () => FictionalModelsData.getFictionalModels().first);
                    
                    // Check if it's an image file (JPG) or PDF
                    if (fictionalModel.pdfPath.toLowerCase().endsWith('.jpg') || 
                        fictionalModel.pdfPath.toLowerCase().endsWith('.jpeg')) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ImageViewerScreen(
                            imagePath: fictionalModel.pdfPath,
                            modelName: fictionalModel.name,
                          ),
                        ),
                      );
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PdfViewerScreen(
                            pdfPath: fictionalModel.pdfPath,
                            modelName: fictionalModel.name,
                          ),
                        ),
                      );
                    }
                  } else if (category == 'Butterfly') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PdfViewerScreen(
                          pdfPath: 'assets/pdfs/Butterfly .pdf',
                          modelName: 'Butterfly',
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Opening $model diagram...')),
                    );
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Animals':
        return Icons.pets;
      case 'Birds':
        return Icons.flutter_dash;
      case 'Butterfly':
        return Icons.flutter_dash;
      case 'Kusudamas':
        return Icons.circle;
      case 'Modular':
        return Icons.view_module;
      case 'Stars':
        return Icons.star;
      case 'Fictional':
        return Icons.auto_stories;
      default:
        return Icons.folder;
    }
  }

  List<String> _getModelsForCategory(String category) {
    switch (category) {
      case 'Animals':
        return ['Spider', 'Brachiosaurus'];
      case 'Birds':
        return ['Butterfly'];
      case 'Butterfly':
        return ['Butterfly'];
      case 'Kusudamas':
        return ['Sonobe Ball', 'Flower Ball', 'Star Ball', 'Diamond Ball'];
      case 'Modular':
        return ['Sonobe Cube', 'Kusudama', 'Polyhedron', 'Geometric Forms'];
      case 'Stars':
        return ['4-Point Star', '8-Point Star', 'Lucky Star', 'Ninja Star'];
      case 'Fictional':
        return ['Buddhist Monk', 'Ganesha', 'Lao-Tseu', 'Magic Tower (Tour de Magie)'];
      default:
        return [];
    }
  }

  Widget _buildQuizGrid() {
    final quizCategories = [
      {'name': 'Artists', 'icon': Icons.palette, 'color': Colors.purple, 'description': 'Famous origami masters'},
      {'name': 'Papers', 'icon': Icons.description, 'color': AppTheme.secondaryColor, 'description': 'Paper types & properties'},
      {'name': 'Folding Techniques', 'icon': Icons.gesture, 'color': Colors.green, 'description': 'Basic to advanced folds'},
      {'name': 'Traditional Origami', 'icon': Icons.auto_awesome, 'color': Colors.orange, 'description': 'Classic models & history'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: quizCategories.length,
      itemBuilder: (context, index) {
        final quiz = quizCategories[index];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizScreen(
                    category: quiz['name'] as String,
                    skillLevel: 'Beginner', // Default to Beginner from Home
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (quiz['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      quiz['icon'] as IconData,
                      color: quiz['color'] as Color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    quiz['name'] as String,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quiz['description'] as String,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
