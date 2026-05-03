import 'package:flutter/material.dart';
import 'package:lets_crease/features/home/butterfly_pdf_fold.dart';

class OrigamiModelsSection extends StatelessWidget {
  const OrigamiModelsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Origami Models',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Learn origami with interactive step-by-step instructions',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 20),
        
        // Butterfly Model
        _buildModelCard(
          context,
          title: 'Butterfly',
          description: 'A beautiful butterfly with elegant wings',
          assetPath: 'assets/pdfs/Butterfly .pdf',
          icon: Icons.flutter_dash,
          color: Colors.pink,
        ),
        const SizedBox(height: 16),
        
        // Buddhist Monk Model
        _buildModelCard(
          context,
          title: 'Buddhist Monk',
          description: 'Traditional figure representing peace and wisdom',
          assetPath: 'assets/pdfs/Buddhist Monk Diagrams PDF.pdf',
          icon: Icons.self_improvement,
          color: Colors.orange,
        ),
        const SizedBox(height: 16),
        
        // Ganesha Model
        _buildModelCard(
          context,
          title: 'Ganesha',
          description: 'The elephant-headed deity of wisdom and prosperity',
          assetPath: 'assets/pdfs/Ganesha \$ - Diagrams.pdf',
          icon: Icons.temple_hindu,
          color: Colors.purple,
        ),
        const SizedBox(height: 16),
        
        // Lao-Tseu Model
        _buildModelCard(
          context,
          title: 'Lao-Tseu',
          description: 'Ancient Chinese philosopher and founder of Taoism',
          assetPath: 'assets/pdfs/Lao-Tseu - Diagrammes PDF.pdf',
          icon: Icons.psychology,
          color: Colors.teal,
        ),
        const SizedBox(height: 16),
        
        
        // Tour de Magie (Magic Tower) Model
        _buildModelCard(
          context,
          title: 'Tour de Magie',
          description: 'A magical tower with mysterious powers',
          assetPath: 'assets/pdfs/Tour de Magie - Diagrammes PDF.pdf',
          icon: Icons.castle,
          color: Colors.indigo,
        ),
      ],
    );
  }

  Widget _buildModelCard(
    BuildContext context, {
    required String title,
    required String description,
    required String assetPath,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // PDF Viewer
          PdfButterflyFoldSteps(
            assetPath: assetPath,
            height: 350,
            animationDuration: const Duration(milliseconds: 800),
            autoPlayInterval: const Duration(seconds: 4),
          ),
        ],
      ),
    );
  }
}
