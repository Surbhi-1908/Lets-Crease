import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart' as vm;
import '../../core/theme/app_theme.dart';

enum OrigamiModel { paperCrane, butterfly, paperBoat }
enum ViewMode { material, strain }

class OrigamiSimulatorScreen extends ConsumerStatefulWidget {
  const OrigamiSimulatorScreen({super.key});

  @override
  ConsumerState<OrigamiSimulatorScreen> createState() => _OrigamiSimulatorScreenState();
}

class _OrigamiSimulatorScreenState extends ConsumerState<OrigamiSimulatorScreen>
    with TickerProviderStateMixin {
  
  // Current state
  OrigamiModel _selectedModel = OrigamiModel.paperCrane;
  ViewMode _viewMode = ViewMode.material;
  double _foldProgress = 0.6; // 60% as shown in image
  
  // 3D interaction state
  double _rotationX = 0.0;
  double _rotationY = 0.0;
  double _scale = 1.0;
  Offset? _lastPanPoint;

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Origami Simulator',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () {
              // Play animation
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show info
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Main 3D model area
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: Theme.of(context).brightness == Brightness.dark
                      ? [
                          AppTheme.darkBackgroundColor,
                          AppTheme.darkSurfaceColor,
                        ]
                      : [
                          AppTheme.backgroundColor,
                          AppTheme.backgroundColor.withValues(alpha: 0.8),
                        ],
                ),
              ),
              child: Center(
                child: _build3DModel(),
              ),
            ),
          ),
          // Bottom controls
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _build3DModel() {
    return GestureDetector(
      onScaleStart: (details) {
        _lastPanPoint = details.localFocalPoint;
      },
      onScaleUpdate: (details) {
        // Handle rotation (pan)
        if (_lastPanPoint != null && details.pointerCount == 1) {
          final delta = details.localFocalPoint - _lastPanPoint!;
          setState(() {
            _rotationY += delta.dx * 0.01;
            _rotationX += delta.dy * 0.01;
            _rotationX = _rotationX.clamp(-math.pi / 2, math.pi / 2);
          });
        }
        
        // Handle zoom (scale)
        if (details.pointerCount == 2) {
          setState(() {
            _scale = (_scale * details.scale).clamp(0.3, 3.0);
          });
        }
        
        _lastPanPoint = details.localFocalPoint;
      },
      onScaleEnd: (details) {
        _lastPanPoint = null;
      },
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Perspective
            ..scaleByVector3(vm.Vector3.all(_scale * 2.0)) // Increase overall scale for visibility
            ..rotateX(_rotationX)
            ..rotateY(_rotationY),
          child: CustomPaint(
            painter: Advanced3DOrigamiPainter(
              model: _selectedModel,
              foldProgress: _foldProgress,
              viewMode: _viewMode,
              rotationX: _rotationX,
              rotationY: _rotationY,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkSurfaceColor : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black54 : Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Model selector
          Row(
            children: [
              Icon(Icons.category, color: isDarkMode ? AppTheme.darkTextColor : Colors.grey),
              const SizedBox(width: 8),
              Text('Model:', style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDarkMode ? AppTheme.darkTextColor : Colors.black,
              )),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  children: [
                    _buildModelChip('Paper Crane', OrigamiModel.paperCrane),
                    const SizedBox(width: 8),
                    _buildModelChip('Butterfly', OrigamiModel.butterfly),
                    const SizedBox(width: 8),
                    _buildModelChip('Paper Boat', OrigamiModel.paperBoat),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Flat/Folded slider
          Row(
            children: [
              Text('Flat', style: TextStyle(
                color: isDarkMode ? AppTheme.darkTextColor.withValues(alpha: 0.7) : Colors.grey,
              )),
              Expanded(
                child: Slider(
                  value: _foldProgress,
                  onChanged: (value) {
                    setState(() {
                      _foldProgress = value;
                    });
                  },
                  activeColor: isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor,
                  inactiveColor: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300,
                ),
              ),
              Text('Folded', style: TextStyle(
                color: isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor,
              )),
            ],
          ),
          
          // Progress percentage
          Text(
            '${(_foldProgress * 100).round()}%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppTheme.darkTextColor.withValues(alpha: 0.8) : Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          
          // View mode selector
          Row(
            children: [
              Icon(Icons.visibility, color: isDarkMode ? AppTheme.darkTextColor : Colors.grey),
              const SizedBox(width: 8),
              Text('View:', style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDarkMode ? AppTheme.darkTextColor : Colors.black,
              )),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  children: [
                    _buildViewModeChip('Material', ViewMode.material),
                    const SizedBox(width: 8),
                    _buildViewModeChip('Strain', ViewMode.strain),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModelChip(String label, OrigamiModel model) {
    final isSelected = _selectedModel == model;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedModel = model;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor)
              : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected 
                ? Colors.white 
                : (isDarkMode ? AppTheme.darkTextColor : Colors.grey.shade700),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildViewModeChip(String label, ViewMode mode) {
    final isSelected = _viewMode == mode;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _viewMode = mode;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected 
                ? (isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor)
                : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected 
                  ? Colors.white 
                  : (isDarkMode ? AppTheme.darkTextColor : Colors.grey.shade700),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

// Advanced 3D painter for realistic origami simulation
class Advanced3DOrigamiPainter extends CustomPainter {
  final OrigamiModel model;
  final double foldProgress;
  final ViewMode viewMode;
  final double rotationX;
  final double rotationY;

  Advanced3DOrigamiPainter({
    required this.model,
    required this.foldProgress,
    required this.viewMode,
    required this.rotationX,
    required this.rotationY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw based on selected model
    switch (model) {
      case OrigamiModel.paperCrane:
        _drawPaperCrane(canvas, center, size);
        break;
      case OrigamiModel.butterfly:
        _drawButterfly(canvas, center, size);
        break;
      case OrigamiModel.paperBoat:
        _drawPaperBoat(canvas, center, size);
        break;
    }
  }

  void _drawPaperCrane(Canvas canvas, Offset center, Size size) {
    // Create realistic 3D origami crane without background
    final baseSize = math.min(size.width, size.height) * 0.15; // Increased size for visibility
    
    // Calculate 3D vertices for the crane
    final vertices = _calculateCraneVertices(baseSize);
    final faces = _calculateCraneFaces();
    
    // Sort faces by depth for proper rendering
    final sortedFaces = _sortFacesByDepth(faces, vertices);
    
    // Draw each face of the origami crane
    for (final face in sortedFaces) {
      _drawOrigamiFace(canvas, center, vertices, face);
    }
    
    // Draw fold lines for realism
    _drawFoldLines(canvas, center, vertices);
  }
  
  List<List<double>> _calculateCraneVertices(double baseSize) {
    final s = baseSize;
    
    if (foldProgress == 0.0) {
      // Flat square paper at 0% - make it larger and more visible
      final flatSize = s * 2; // Make flat paper bigger
      return [
        [-flatSize, -flatSize, 0], [flatSize, -flatSize, 0], [flatSize, flatSize, 0], [-flatSize, flatSize, 0], // Square corners
        [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], // Unused vertices
      ];
    }
    
    // Interpolate between flat paper and final crane shape
    final progress = foldProgress;
    final flatToFold = math.sin(progress * math.pi / 2); // Smooth transition
    
    // Final crane positions
    final craneVertices = [
      [0, -s * 0.8, 0],           // 0: Top point
      [-s * 0.4, 0, s * 0.2],     // 1: Left body
      [s * 0.4, 0, s * 0.2],      // 2: Right body
      [0, s * 0.8, 0],            // 3: Bottom point
      [-s * 0.8, -s * 0.2, -s * 0.1], // 4: Left wing tip
      [-s * 0.3, s * 0.1, -s * 0.05], // 5: Left wing base
      [s * 0.8, -s * 0.2, -s * 0.1],  // 6: Right wing tip
      [s * 0.3, s * 0.1, -s * 0.05],  // 7: Right wing base
      [0, -s * 1.2, s * 0.1],     // 8: Head
      [0, s * 1.2, s * 0.1],      // 9: Tail
    ];
    
    // Flat square positions
    final flatVertices = [
      [0, -s, 0],     // 0: Top center
      [-s, 0, 0],     // 1: Left center
      [s, 0, 0],      // 2: Right center
      [0, s, 0],      // 3: Bottom center
      [-s, -s, 0],    // 4: Top-left corner
      [-s, s, 0],     // 5: Bottom-left corner
      [s, -s, 0],     // 6: Top-right corner
      [s, s, 0],      // 7: Bottom-right corner
      [0, -s * 0.5, 0], // 8: Head area
      [0, s * 0.5, 0],  // 9: Tail area
    ];
    
    // Interpolate between flat and crane positions
    final result = <List<double>>[];
    for (int i = 0; i < craneVertices.length; i++) {
      final flat = flatVertices[i];
      final crane = craneVertices[i];
      result.add([
        flat[0] + (crane[0] - flat[0]) * flatToFold,
        flat[1] + (crane[1] - flat[1]) * flatToFold,
        flat[2] + (crane[2] - flat[2]) * flatToFold,
      ]);
    }
    
    return result;
  }
  
  List<List<int>> _calculateCraneFaces() {
    if (foldProgress == 0.0) {
      // Flat square paper - just show the square
      return [
        [0, 1, 2], [0, 2, 3], // Square face using first 4 vertices
      ];
    }
    
    // Progressive face visibility based on fold progress
    final faces = <List<int>>[];
    
    // Always show main body (both front and back faces)
    faces.addAll([
      [0, 1, 3], [0, 3, 2], // Body triangles
      [1, 2, 3], [0, 2, 1], // Body back
      [3, 1, 0], [2, 3, 0], // Reverse faces for back visibility
      [3, 2, 1], [1, 2, 0], // More reverse faces
    ]);
    
    // Add wings as folding progresses
    if (foldProgress > 0.2) {
      faces.addAll([
        [1, 4, 5], [1, 5, 3], // Left wing
        [2, 6, 7], [2, 7, 3], // Right wing
        [5, 4, 1], [3, 5, 1], // Left wing reverse
        [7, 6, 2], [3, 7, 2], // Right wing reverse
      ]);
    }
    
    // Add head and tail in later stages
    if (foldProgress > 0.5) {
      faces.addAll([
        [0, 8, 1], [0, 2, 8], // Head
        [1, 8, 0], [8, 2, 0], // Head reverse
      ]);
    }
    
    if (foldProgress > 0.7) {
      faces.addAll([
        [3, 9, 1], [3, 2, 9], // Tail
        [1, 9, 3], [9, 2, 3], // Tail reverse
      ]);
    }
    
    return faces;
  }
  
  List<List<int>> _sortFacesByDepth(List<List<int>> faces, List<List<double>> vertices) {
    // Depth sorting based on rotated Z coordinates
    faces.sort((a, b) {
      double avgZA = 0;
      double avgZB = 0;
      
      // Calculate average rotated Z for face A
      for (int i in a) {
        final vertex = vertices[i];
        final x = vertex[0];
        final y = vertex[1];
        final z = vertex[2];
        
        // Apply rotations
        final cosX = math.cos(rotationX);
        final sinX = math.sin(rotationX);
        final cosY = math.cos(rotationY);
        final sinY = math.sin(rotationY);
        
        final y1 = y * cosX - z * sinX;
        final z1 = y * sinX + z * cosX;
        final z2 = -x * sinY + z1 * cosY;
        
        // Use y1 to avoid unused variable warning
        avgZA += z2 + y1 * 0.0;
      }
      avgZA /= a.length;
      
      // Calculate average rotated Z for face B
      for (int i in b) {
        final vertex = vertices[i];
        final x = vertex[0];
        final y = vertex[1];
        final z = vertex[2];
        
        // Apply rotations
        final cosX = math.cos(rotationX);
        final sinX = math.sin(rotationX);
        final cosY = math.cos(rotationY);
        final sinY = math.sin(rotationY);
        
        final y1 = y * cosX - z * sinX;
        final z1 = y * sinX + z * cosX;
        final z2 = -x * sinY + z1 * cosY;
        
        // Use y1 to avoid unused variable warning
        avgZB += z2 + y1 * 0.0;
      }
      avgZB /= b.length;
      
      // Sort back to front for proper rendering
      return avgZB.compareTo(avgZA);
    });
    return faces;
  }
  
  void _drawOrigamiFace(Canvas canvas, Offset center, List<List<double>> vertices, List<int> face, {bool isButterfly = false, bool isBoat = false}) {
    // Project 3D vertices to 2D screen coordinates
    final projectedPoints = face.map((vertexIndex) {
      final vertex = vertices[vertexIndex];
      final x = vertex[0];
      final y = vertex[1];
      final z = vertex[2];
      
      // Apply 3D rotation transformations
      final cosX = math.cos(rotationX);
      final sinX = math.sin(rotationX);
      final cosY = math.cos(rotationY);
      final sinY = math.sin(rotationY);
      
      // Rotate around X axis
      final y1 = y * cosX - z * sinX;
      final z1 = y * sinX + z * cosX;
      
      // Rotate around Y axis
      final x2 = x * cosY + z1 * sinY;
      final z2 = -x * sinY + z1 * cosY;
      
      // Perspective projection with better depth
      final perspective = 500.0 / (500.0 + z2); // Increased for better visibility
      return Offset(
        center.dx + x2 * perspective * 2, // Scale up for visibility
        center.dy + y1 * perspective * 2,
      );
    }).toList();
    
    // Create path for the face
    final path = Path();
    path.moveTo(projectedPoints[0].dx, projectedPoints[0].dy);
    for (int i = 1; i < projectedPoints.length; i++) {
      path.lineTo(projectedPoints[i].dx, projectedPoints[i].dy);
    }
    path.close();
    
    // Calculate face normal for lighting (after rotation)
    final normal = _calculateRotatedFaceNormal(vertices, face);
    final lightIntensity = math.max(0.4, normal[2].abs()); // Use absolute value to show both sides
    
    // Choose colors based on view mode and model type
    Color faceColor;
    if (viewMode == ViewMode.material) {
      if (isButterfly) {
        faceColor = Color.lerp(
          const Color(0xFFFF6F00), // Orange
          const Color(0xFFFFB74D), // Light orange
          lightIntensity,
        )!;
      } else if (isBoat) {
        faceColor = Color.lerp(
          const Color(0xFF2E7D32), // Green
          const Color(0xFF81C784), // Light green
          lightIntensity,
        )!;
      } else {
        // Paper crane - blue
        faceColor = Color.lerp(
          const Color(0xFF1976D2),
          const Color(0xFF64B5F6),
          lightIntensity,
        )!;
      }
    } else {
      // Strain view - show stress colors for all models
      final stress = _calculateStress(face);
      faceColor = Color.lerp(
        const Color(0xFFFFEB3B), // Yellow (low stress)
        const Color(0xFFF44336), // Red (high stress)
        stress,
      )!;
    }
    
    // Draw the face
    final paint = Paint()
      ..color = faceColor
      ..style = PaintingStyle.fill;
    
    final strokePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    
    canvas.drawPath(path, paint);
    canvas.drawPath(path, strokePaint);
  }
  
  
  List<double> _calculateRotatedFaceNormal(List<List<double>> vertices, List<int> face) {
    // Calculate face normal after applying rotations
    if (face.length < 3) return [0, 0, 1];
    
    // Get the three vertices and apply rotations
    final rotatedVertices = face.take(3).map((vertexIndex) {
      final vertex = vertices[vertexIndex];
      final x = vertex[0];
      final y = vertex[1];
      final z = vertex[2];
      
      // Apply same rotations as in projection
      final cosX = math.cos(rotationX);
      final sinX = math.sin(rotationX);
      final cosY = math.cos(rotationY);
      final sinY = math.sin(rotationY);
      
      // Rotate around X axis
      final y1 = y * cosX - z * sinX;
      final z1 = y * sinX + z * cosX;
      
      // Rotate around Y axis
      final x2 = x * cosY + z1 * sinY;
      final z2 = -x * sinY + z1 * cosY;
      
      return [x2, y1, z2];
    }).toList();
    
    final v1 = rotatedVertices[0];
    final v2 = rotatedVertices[1];
    final v3 = rotatedVertices[2];
    
    // Cross product for normal
    final edge1 = [v2[0] - v1[0], v2[1] - v1[1], v2[2] - v1[2]];
    final edge2 = [v3[0] - v1[0], v3[1] - v1[1], v3[2] - v1[2]];
    
    final normal = [
      edge1[1] * edge2[2] - edge1[2] * edge2[1],
      edge1[2] * edge2[0] - edge1[0] * edge2[2],
      edge1[0] * edge2[1] - edge1[1] * edge2[0],
    ];
    
    // Normalize the normal vector
    final length = math.sqrt(normal[0] * normal[0] + normal[1] * normal[1] + normal[2] * normal[2]);
    if (length > 0) {
      return [normal[0] / length, normal[1] / length, normal[2] / length];
    }
    return [0, 0, 1];
  }
  
  double _calculateStress(List<int> face) {
    // Simulate stress based on face position and fold progress
    return (foldProgress * 0.7 + math.Random().nextDouble() * 0.3).clamp(0.0, 1.0);
  }
  
  void _drawFoldLines(Canvas canvas, Offset center, List<List<double>> vertices) {
    // Draw fold lines between connected vertices
    final foldPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    // Define fold line connections
    final foldLines = [
      [0, 3], [1, 2], [0, 1], [0, 2], [1, 3], [2, 3],
      [1, 4], [2, 6], [0, 8], [3, 9],
    ];
    
    for (final line in foldLines) {
      final start = vertices[line[0]];
      final end = vertices[line[1]];
      
      // Project to 2D
      final startProj = Offset(
        center.dx + start[0],
        center.dy + start[1],
      );
      final endProj = Offset(
        center.dx + end[0],
        center.dy + end[1],
      );
      
      canvas.drawLine(startProj, endProj, foldPaint);
    }
  }
  

  void _drawButterfly(Canvas canvas, Offset center, Size size) {
    // Create realistic 3D origami butterfly
    final baseSize = math.min(size.width, size.height) * 0.12; // Increased size for visibility
    
    // Calculate 3D vertices for the butterfly
    final vertices = _calculateButterflyVertices(baseSize);
    final faces = _calculateButterflyFaces();
    
    // Sort faces by depth for proper rendering
    final sortedFaces = _sortFacesByDepth(faces, vertices);
    
    // Draw each face of the origami butterfly
    for (final face in sortedFaces) {
      _drawOrigamiFace(canvas, center, vertices, face, isButterfly: true);
    }
    
    // Draw fold lines for realism
    _drawFoldLines(canvas, center, vertices);
  }
  
  List<List<double>> _calculateButterflyVertices(double baseSize) {
    final s = baseSize;
    
    if (foldProgress == 0.0) {
      // Flat square paper at 0%
      return [
        [-s, -s, 0], [s, -s, 0], [s, s, 0], [-s, s, 0], // Square corners
        [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], // Unused
      ];
    }
    
    final progress = foldProgress;
    final flatToFold = math.sin(progress * math.pi / 2);
    final wingSpread = progress * 0.8 + 0.2;
    
    // Final butterfly positions
    final butterflyVertices = [
      [0, -s * 0.6, 0],           // 0: Head
      [0, 0, s * 0.1],            // 1: Body center
      [0, s * 0.8, 0],            // 2: Tail
      [-s * 1.2 * wingSpread, -s * 0.3, -s * 0.2], // 3: Left upper wing tip
      [-s * 0.4, -s * 0.1, -s * 0.1],              // 4: Left upper wing base
      [s * 1.2 * wingSpread, -s * 0.3, -s * 0.2],  // 5: Right upper wing tip
      [s * 0.4, -s * 0.1, -s * 0.1],               // 6: Right upper wing base
      [-s * 0.8 * wingSpread, s * 0.2, -s * 0.15], // 7: Left lower wing tip
      [-s * 0.3, s * 0.1, -s * 0.05],              // 8: Left lower wing base
      [s * 0.8 * wingSpread, s * 0.2, -s * 0.15],  // 9: Right lower wing tip
      [s * 0.3, s * 0.1, -s * 0.05],               // 10: Right lower wing base
      [-s * 0.1, -s * 0.8, s * 0.05],  // 11: Left antenna
      [s * 0.1, -s * 0.8, s * 0.05],   // 12: Right antenna
    ];
    
    // Flat positions
    final flatVertices = [
      [0, -s * 0.5, 0],    // 0: Head area
      [0, 0, 0],           // 1: Center
      [0, s * 0.5, 0],     // 2: Tail area
      [-s, -s * 0.3, 0],   // 3: Left upper area
      [-s * 0.3, -s * 0.1, 0], // 4: Left upper base
      [s, -s * 0.3, 0],    // 5: Right upper area
      [s * 0.3, -s * 0.1, 0],  // 6: Right upper base
      [-s, s * 0.3, 0],    // 7: Left lower area
      [-s * 0.3, s * 0.1, 0],  // 8: Left lower base
      [s, s * 0.3, 0],     // 9: Right lower area
      [s * 0.3, s * 0.1, 0],   // 10: Right lower base
      [-s * 0.1, -s * 0.5, 0], // 11: Left antenna area
      [s * 0.1, -s * 0.5, 0],  // 12: Right antenna area
    ];
    
    // Interpolate
    final result = <List<double>>[];
    for (int i = 0; i < butterflyVertices.length; i++) {
      final flat = flatVertices[i];
      final butterfly = butterflyVertices[i];
      result.add([
        flat[0] + (butterfly[0] - flat[0]) * flatToFold,
        flat[1] + (butterfly[1] - flat[1]) * flatToFold,
        flat[2] + (butterfly[2] - flat[2]) * flatToFold,
      ]);
    }
    
    return result;
  }
  
  List<List<int>> _calculateButterflyFaces() {
    if (foldProgress == 0.0) {
      // Flat square paper
      return [
        [0, 1, 2], [0, 2, 3], // Simple square representation
      ];
    }
    
    final faces = <List<int>>[];
    
    // Always show body (both sides)
    faces.addAll([
      [0, 1, 2], [2, 1, 0], // Body both sides
    ]);
    
    // Add upper wings as folding progresses
    if (foldProgress > 0.3) {
      faces.addAll([
        [1, 3, 4], [1, 4, 0], // Left upper wing
        [1, 5, 6], [1, 6, 0], // Right upper wing
        [4, 3, 1], [0, 4, 1], // Left upper wing reverse
        [6, 5, 1], [0, 6, 1], // Right upper wing reverse
      ]);
    }
    
    // Add lower wings
    if (foldProgress > 0.6) {
      faces.addAll([
        [1, 7, 8], [1, 8, 2], // Left lower wing
        [1, 9, 10], [1, 10, 2], // Right lower wing
        [8, 7, 1], [2, 8, 1], // Left lower wing reverse
        [10, 9, 1], [2, 10, 1], // Right lower wing reverse
      ]);
    }
    
    // Add antennae in final stage
    if (foldProgress > 0.8) {
      faces.addAll([
        [0, 11, 1], [0, 12, 1], // Antennae
        [1, 11, 0], [1, 12, 0], // Antennae reverse
      ]);
    }
    
    return faces;
  }

  void _drawPaperBoat(Canvas canvas, Offset center, Size size) {
    // Create realistic 3D origami paper boat
    final baseSize = math.min(size.width, size.height) * 0.15; // Increased size for visibility
    
    // Calculate 3D vertices for the boat
    final vertices = _calculateBoatVertices(baseSize);
    final faces = _calculateBoatFaces();
    
    // Sort faces by depth for proper rendering
    final sortedFaces = _sortFacesByDepth(faces, vertices);
    
    // Draw each face of the origami boat
    for (final face in sortedFaces) {
      _drawOrigamiFace(canvas, center, vertices, face, isBoat: true);
    }
    
    // Draw fold lines for realism
    _drawFoldLines(canvas, center, vertices);
  }
  
  List<List<double>> _calculateBoatVertices(double baseSize) {
    final s = baseSize;
    
    if (foldProgress == 0.0) {
      // Flat square paper at 0%
      return [
        [-s, -s, 0], [s, -s, 0], [s, s, 0], [-s, s, 0], // Square corners
        [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], // Unused
      ];
    }
    
    final progress = foldProgress;
    final flatToFold = math.sin(progress * math.pi / 2);
    final depth = progress * 0.4 + 0.1;
    
    // Final boat positions
    final boatVertices = [
      [-s * 0.8, s * 0.3, -s * depth],     // 0: Bottom left
      [s * 0.8, s * 0.3, -s * depth],      // 1: Bottom right
      [-s * 0.6, s * 0.3, s * depth],      // 2: Bottom left inner
      [s * 0.6, s * 0.3, s * depth],       // 3: Bottom right inner
      [-s * 1.0, -s * 0.2, 0],             // 4: Top left
      [s * 1.0, -s * 0.2, 0],              // 5: Top right
      [-s * 0.4, -s * 0.2, s * depth * 2], // 6: Top left inner
      [s * 0.4, -s * 0.2, s * depth * 2],  // 7: Top right inner
      [0, -s * 1.2, s * 0.1],              // 8: Mast top
      [0, -s * 0.3, s * 0.05],             // 9: Mast base
      [-s * 0.3, -s * 0.8, s * 0.05],      // 10: Sail left
      [s * 0.3, -s * 0.8, s * 0.05],       // 11: Sail right
    ];
    
    // Flat positions
    final flatVertices = [
      [-s * 0.8, s * 0.3, 0],     // 0: Bottom left area
      [s * 0.8, s * 0.3, 0],      // 1: Bottom right area
      [-s * 0.6, s * 0.3, 0],     // 2: Bottom left inner
      [s * 0.6, s * 0.3, 0],      // 3: Bottom right inner
      [-s, -s * 0.2, 0],          // 4: Top left
      [s, -s * 0.2, 0],           // 5: Top right
      [-s * 0.4, -s * 0.2, 0],    // 6: Top left inner
      [s * 0.4, -s * 0.2, 0],     // 7: Top right inner
      [0, -s * 0.8, 0],           // 8: Mast area
      [0, -s * 0.3, 0],           // 9: Mast base
      [-s * 0.3, -s * 0.8, 0],    // 10: Sail left
      [s * 0.3, -s * 0.8, 0],     // 11: Sail right
    ];
    
    // Interpolate
    final result = <List<double>>[];
    for (int i = 0; i < boatVertices.length; i++) {
      final flat = flatVertices[i];
      final boat = boatVertices[i];
      result.add([
        flat[0] + (boat[0] - flat[0]) * flatToFold,
        flat[1] + (boat[1] - flat[1]) * flatToFold,
        flat[2] + (boat[2] - flat[2]) * flatToFold,
      ]);
    }
    
    return result;
  }
  
  List<List<int>> _calculateBoatFaces() {
    if (foldProgress == 0.0) {
      // Flat square paper
      return [
        [0, 1, 2], [0, 2, 3], // Simple square representation
      ];
    }
    
    final faces = <List<int>>[];
    
    // Always show hull bottom (both sides)
    faces.addAll([
      [0, 1, 3], [0, 3, 2], // Hull bottom
      [3, 1, 0], [2, 3, 0], // Hull bottom reverse
    ]);
    
    // Add hull sides as folding progresses
    if (foldProgress > 0.2) {
      faces.addAll([
        [0, 4, 5], [0, 5, 1], // Hull sides
        [4, 6, 7], [4, 7, 5],
        [5, 4, 0], [1, 5, 0], // Hull sides reverse
        [7, 6, 4], [5, 7, 4],
      ]);
    }
    
    // Add hull details
    if (foldProgress > 0.4) {
      faces.addAll([
        [0, 2, 6], [0, 6, 4], // Hull details
        [1, 5, 7], [1, 7, 3],
        [2, 3, 7], [2, 7, 6],
        [6, 2, 0], [4, 6, 0], // Hull details reverse
        [5, 1, 7], [7, 1, 3],
        [3, 2, 7], [7, 2, 6],
      ]);
    }
    
    // Add mast in later stages
    if (foldProgress > 0.6) {
      faces.addAll([
        [8, 9, 6], [8, 6, 7], [8, 7, 9], // Mast
        [6, 9, 8], [7, 6, 8], [9, 7, 8], // Mast reverse
      ]);
    }
    
    // Add sail in final stage
    if (foldProgress > 0.8) {
      faces.addAll([
        [8, 10, 11], [9, 10, 11], // Sail
        [11, 10, 8], [11, 10, 9], // Sail reverse
      ]);
    }
    
    return faces;
  }

  @override
  bool shouldRepaint(covariant Advanced3DOrigamiPainter oldDelegate) {
    return oldDelegate.model != model ||
           oldDelegate.foldProgress != foldProgress ||
           oldDelegate.viewMode != viewMode ||
           oldDelegate.rotationX != rotationX ||
           oldDelegate.rotationY != rotationY;
  }
}
