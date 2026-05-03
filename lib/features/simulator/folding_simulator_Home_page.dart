import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../core/theme/app_theme.dart';

enum FoldMode { selectCorner, selectTarget, none }

class FoldData {
  final Offset corner;
  final Offset target;
  final DateTime timestamp;
  
  FoldData({
    required this.corner,
    required this.target,
    required this.timestamp,
  });
}

class FoldingSimulatorScreen extends ConsumerStatefulWidget {
  const FoldingSimulatorScreen({super.key});

  @override
  ConsumerState<FoldingSimulatorScreen> createState() => _FoldingSimulatorScreenState();
}

class _FoldingSimulatorScreenState extends ConsumerState<FoldingSimulatorScreen>
    with TickerProviderStateMixin {
  
  // Animation controllers
  late AnimationController _foldController;
  late AnimationController _rotationController;
  
  // Paper state
  Offset? _selectedCorner;
  Offset? _targetPoint;
  bool _isAnimating = false;
  double _rotationAngle = 0.0;
  bool _isFlipped = false;
  int _currentLayer = 1;
  int _maxLayers = 1;
  
  // Paper dimensions and position
  double _paperSize = 250.0; // Optimized size for mobile
  late Offset _paperCenter;
  double _zoomLevel = 1.0;
  final double _minZoom = 0.5;
  final double _maxZoom = 3.0;
  
  // Fold history
  final List<FoldData> _folds = [];
  
  // UI state
  FoldMode _foldMode = FoldMode.none;

  @override
  void initState() {
    super.initState();
    _foldController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      _paperCenter = Offset(size.width * 0.4, size.height / 2);
    });
  }

  @override
  void dispose() {
    _foldController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Folding Simulator'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: true, // Keep back button for this screen since it's accessed from home
      ),
      body: Container(
        color: Theme.of(context).brightness == Brightness.dark 
            ? AppTheme.darkBackgroundColor 
            : const Color(0xFFE8E8E8), // Light gray background
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth > 800;
            
            if (isTablet) {
              return Row(
                children: [
                  // Main canvas area (left side)
                  Expanded(
                    flex: 3,
                    child: _buildPaperCanvas(),
                  ),
                  // Control panels (right side)
                  SizedBox(
                    width: 300,
                    child: Column(
                      children: [
                        _buildViewControls(),
                        _buildFoldControls(),
                        Expanded(child: _buildBottomArea()),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  // Control panels (top on mobile)
                  Flexible(
                    flex: 2,
                    child: SingleChildScrollView(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildViewControls()),
                          Expanded(child: _buildFoldControls()),
                        ],
                      ),
                    ),
                  ),
                  // Main canvas area (bottom on mobile)
                  Expanded(
                    flex: 3,
                    child: _buildPaperCanvas(),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildViewControls() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? AppTheme.darkPrimaryColor.withOpacity(0.3)
            : AppTheme.primaryColor.withOpacity(0.2),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'View Controls',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isDarkMode ? AppTheme.darkTextColor : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          _buildControlButton(
            'Show +1 layer',
            _currentLayer < _maxLayers,
            () => _showNextLayer(),
          ),
          const SizedBox(height: 4),
          _buildControlButton(
            'Show -1 layer',
            _currentLayer > 1,
            () => _showPreviousLayer(),
          ),
          const SizedBox(height: 4),
          _buildControlButton(
            'Flip over',
            true,
            () => _flipPaper(),
          ),
          const SizedBox(height: 4),
          _buildControlButton(
            'Rotate',
            true,
            () => _rotatePaper(),
          ),
          const SizedBox(height: 4),
          _buildControlButton(
            'Zoom In',
            _zoomLevel < _maxZoom,
            () => _zoomIn(),
          ),
          const SizedBox(height: 4),
          _buildControlButton(
            'Zoom Out',
            _zoomLevel > _minZoom,
            () => _zoomOut(),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Text('Mode: ', style: TextStyle(
                fontSize: 10,
                color: isDarkMode ? AppTheme.darkTextColor.withOpacity(0.8) : Colors.black,
              )),
              Flexible(
                child: Text(
                  _getModeText(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 10,
                    color: isDarkMode ? AppTheme.darkTextColor : Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Text('Zoom: ', style: TextStyle(
                fontSize: 10,
                color: isDarkMode ? AppTheme.darkTextColor.withOpacity(0.8) : Colors.black,
              )),
              Text(
                '${(_zoomLevel * 100).toInt()}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 10,
                  color: isDarkMode ? AppTheme.darkTextColor : Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFoldControls() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? AppTheme.darkSecondaryColor.withOpacity(0.3)
            : AppTheme.secondaryColor.withOpacity(0.2),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Fold Controls',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isDarkMode ? AppTheme.darkTextColor : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          _buildControlButton(
            'Select corner to fold',
            _foldMode != FoldMode.selectCorner,
            () => _setFoldMode(FoldMode.selectCorner),
          ),
          const SizedBox(height: 4),
          _buildControlButton(
            'Select point to fold corner to',
            _foldMode != FoldMode.selectTarget && _selectedCorner != null,
            () => _setFoldMode(FoldMode.selectTarget),
          ),
          const SizedBox(height: 4),
          _buildControlButton(
            'Fold!',
            _selectedCorner != null && _targetPoint != null,
            () => _performFold(),
          ),
          const SizedBox(height: 4),
          _buildControlButton(
            'Unselect all',
            _selectedCorner != null || _targetPoint != null,
            () => _unselectAll(),
          ),
          const SizedBox(height: 4),
          _buildControlButton(
            'Reset Zoom',
            _zoomLevel != 1.0,
            () => _resetZoom(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomArea() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFADD8E6), // Light blue
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          'Additional Controls Area',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildPaperCanvas() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: isDarkMode ? AppTheme.darkSurfaceColor : Colors.white,
      child: InteractiveViewer(
        minScale: _minZoom,
        maxScale: _maxZoom,
        constrained: false,
        child: Center(
          child: Transform.scale(
            scale: _zoomLevel,
            child: GestureDetector(
              onTapDown: (details) => _onPaperTap(details.localPosition),
              child: CustomPaint(
                painter: OrigamiPaperPainter(
                  selectedCorner: _selectedCorner,
                  targetPoint: _targetPoint,
                  folds: _folds,
                  rotationAngle: _rotationAngle,
                  isFlipped: _isFlipped,
                  foldMode: _foldMode,
                  paperSize: _paperSize,
                  isDarkMode: isDarkMode,
                ),
                size: Size(_paperSize * 2, _paperSize * 2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton(String text, bool enabled, VoidCallback onPressed) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled 
              ? (isDarkMode ? AppTheme.darkSurfaceColor : Colors.white)
              : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300),
          foregroundColor: isDarkMode ? AppTheme.darkTextColor : Colors.black,
          elevation: enabled ? 1 : 0,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          minimumSize: const Size(0, 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 9,
            fontWeight: enabled ? FontWeight.w500 : FontWeight.w300,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Action methods
  void _showNextLayer() {
    if (_currentLayer < _maxLayers) {
      setState(() {
        _currentLayer++;
      });
    }
  }

  void _showPreviousLayer() {
    if (_currentLayer > 1) {
      setState(() {
        _currentLayer--;
      });
    }
  }

  void _flipPaper() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
    _rotationController.forward().then((_) {
      _rotationController.reset();
    });
  }

  void _rotatePaper() {
    setState(() {
      _rotationAngle += math.pi / 2; // Rotate 90 degrees
      if (_rotationAngle >= 2 * math.pi) {
        _rotationAngle = 0;
      }
    });
  }

  void _zoomIn() {
    setState(() {
      _zoomLevel = math.min(_zoomLevel + 0.2, _maxZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel = math.max(_zoomLevel - 0.2, _minZoom);
    });
  }

  void _resetZoom() {
    setState(() {
      _zoomLevel = 1.0;
    });
  }

  void _setFoldMode(FoldMode mode) {
    setState(() {
      _foldMode = mode;
      if (mode == FoldMode.selectCorner) {
        _selectedCorner = null;
        _targetPoint = null;
      }
    });
  }

  void _unselectAll() {
    setState(() {
      _selectedCorner = null;
      _targetPoint = null;
      _foldMode = FoldMode.none;
    });
  }

  String _getModeText() {
    switch (_foldMode) {
      case FoldMode.selectCorner:
        return 'Select Corner';
      case FoldMode.selectTarget:
        return 'Select Target';
      case FoldMode.none:
        return 'None';
    }
  }

  void _onPaperTap(Offset localPosition) {
    if (_isAnimating) return;
    
    if (_foldMode == FoldMode.selectCorner) {
      final nearestCorner = _findNearestCorner(localPosition);
      final distance = (nearestCorner - localPosition).distance;
      
      if (distance <= 50) {
        setState(() {
          _selectedCorner = nearestCorner;
          _foldMode = FoldMode.selectTarget;
        });
      }
    } else if (_foldMode == FoldMode.selectTarget && _selectedCorner != null) {
      setState(() {
        _targetPoint = localPosition;
      });
    }
  }

  Offset _findNearestCorner(Offset position) {
    final center = Offset(_paperSize, _paperSize);
    final effectiveSize = _paperSize * _zoomLevel;
    
    final halfSize = effectiveSize / 2;
    final corners = [
      Offset(center.dx - halfSize, center.dy - halfSize), // Top-left
      Offset(center.dx + halfSize, center.dy - halfSize), // Top-right
      Offset(center.dx + halfSize, center.dy + halfSize), // Bottom-right
      Offset(center.dx - halfSize, center.dy + halfSize), // Bottom-left
    ];
    
    Offset nearest = corners[0];
    double minDistance = double.infinity;
    
    for (final corner in corners) {
      final distance = (corner - position).distance;
      if (distance < minDistance) {
        minDistance = distance;
        nearest = corner;
      }
    }
    
    return nearest;
  }

  void _performFold() {
    if (_selectedCorner == null || _targetPoint == null || _isAnimating) return;
    
    setState(() {
      _isAnimating = true;
    });
    
    final fold = FoldData(
      corner: _selectedCorner!,
      target: _targetPoint!,
      timestamp: DateTime.now(),
    );
    
    _folds.add(fold);
    _maxLayers = math.max(_maxLayers, _folds.length + 1);
    
    _foldController.forward().then((_) {
      setState(() {
        _isAnimating = false;
        _selectedCorner = null;
        _targetPoint = null;
        _foldMode = FoldMode.none;
      });
      _foldController.reset();
    });
  }
}

class OrigamiPaperPainter extends CustomPainter {
  final Offset? selectedCorner;
  final Offset? targetPoint;
  final List<FoldData> folds;
  final double rotationAngle;
  final bool isFlipped;
  final FoldMode foldMode;
  final double paperSize;
  final bool isDarkMode;

  OrigamiPaperPainter({
    this.selectedCorner,
    this.targetPoint,
    required this.folds,
    required this.rotationAngle,
    required this.isFlipped,
    required this.foldMode,
    required this.paperSize,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final paint = Paint()
      ..color = isDarkMode 
          ? const Color(0xFF6A1B9A) // Darker purple for dark mode
          : const Color(0xFF8A2BE2) // Purple color for light mode
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = isDarkMode ? Colors.white70 : Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final rect = Rect.fromCenter(
      center: center,
      width: paperSize,
      height: paperSize,
    );

    // Draw the paper
    canvas.drawRect(rect, paint);
    canvas.drawRect(rect, borderPaint);

    // Draw fold lines
    final foldPaint = Paint()
      ..color = isDarkMode 
          ? Colors.cyan.withOpacity(0.8)
          : Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (final fold in folds) {
      canvas.drawLine(fold.corner, fold.target, foldPaint);
    }

    // Draw selected corner
    if (selectedCorner != null) {
      final cornerPaint = Paint()
        ..color = isDarkMode ? Colors.amber : Colors.yellow
        ..style = PaintingStyle.fill;
      canvas.drawCircle(selectedCorner!, 8, cornerPaint);
      
      // Draw border
      final cornerBorderPaint = Paint()
        ..color = isDarkMode ? Colors.white : Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(selectedCorner!, 8, cornerBorderPaint);
    }

    // Draw target point
    if (targetPoint != null) {
      final targetPaint = Paint()
        ..color = isDarkMode ? Colors.redAccent : Colors.red
        ..style = PaintingStyle.fill;
      canvas.drawCircle(targetPoint!, 6, targetPaint);
      
      // Draw border
      final targetBorderPaint = Paint()
        ..color = isDarkMode ? Colors.white : Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(targetPoint!, 6, targetBorderPaint);
    }

    // Draw corners as small circles for easier selection
    final cornerIndicatorPaint = Paint()
      ..color = isDarkMode 
          ? Colors.white.withOpacity(0.7)
          : Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final corners = [
      Offset(rect.left, rect.top),
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.bottom),
      Offset(rect.left, rect.bottom),
    ];

    for (final corner in corners) {
      canvas.drawCircle(corner, 4, cornerIndicatorPaint);
    }
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
