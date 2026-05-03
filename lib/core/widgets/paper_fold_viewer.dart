import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class PaperFoldStep {
  final String imagePath;
  final String description;
  final int stepNumber;

  const PaperFoldStep({
    required this.imagePath,
    required this.description,
    required this.stepNumber,
  });
}

class PaperFoldViewer extends StatefulWidget {
  final List<PaperFoldStep> steps;
  final double height;
  final Duration animationDuration;
  final Duration autoPlayInterval;

  const PaperFoldViewer({
    super.key,
    required this.steps,
    this.height = 300,
    this.animationDuration = const Duration(milliseconds: 500),
    this.autoPlayInterval = const Duration(seconds: 3),
  });

  @override
  State<PaperFoldViewer> createState() => _PaperFoldViewerState();
}

class _PaperFoldViewerState extends State<PaperFoldViewer>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  int _currentStep = 0;
  bool _isAutoPlaying = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    if (!_isAutoPlaying || widget.steps.isEmpty) return;
    
    Future.delayed(widget.autoPlayInterval, () {
      if (mounted && _isAutoPlaying) {
        _nextStep();
        _startAutoPlay();
      }
    });
  }

  void _nextStep() {
    if (widget.steps.isEmpty) return;
    
    setState(() {
      _currentStep = (_currentStep + 1) % widget.steps.length;
    });
    
    _pageController.animateToPage(
      _currentStep,
      duration: widget.animationDuration,
      curve: Curves.easeInOut,
    );
  }

  void _previousStep() {
    if (widget.steps.isEmpty) return;
    
    setState(() {
      _currentStep = _currentStep > 0 ? _currentStep - 1 : widget.steps.length - 1;
    });
    
    _pageController.animateToPage(
      _currentStep,
      duration: widget.animationDuration,
      curve: Curves.easeInOut,
    );
  }

  void _pauseAutoPlay() {
    setState(() {
      _isAutoPlaying = false;
    });
  }

  void _resumeAutoPlay() {
    setState(() {
      _isAutoPlaying = true;
    });
    _startAutoPlay();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.steps.isEmpty) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.2),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported_outlined,
                size: 48,
                color: Theme.of(context).disabledColor,
              ),
              const SizedBox(height: 16),
              Text(
                'No folding steps available',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).disabledColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header with step indicator and controls
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Step ${widget.steps[_currentStep].stepNumber}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _previousStep,
                              icon: const Icon(Icons.skip_previous),
                              iconSize: 20,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                            IconButton(
                              onPressed: _isAutoPlaying ? _pauseAutoPlay : _resumeAutoPlay,
                              icon: Icon(_isAutoPlaying ? Icons.pause : Icons.play_arrow),
                              iconSize: 20,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                            IconButton(
                              onPressed: _nextStep,
                              icon: const Icon(Icons.skip_next),
                              iconSize: 20,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Main content area with PageView
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentStep = index;
                        });
                      },
                      itemCount: widget.steps.length,
                      itemBuilder: (context, index) {
                        final step = widget.steps[index];
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // Image container
                              Expanded(
                                flex: 3,
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Theme.of(context).dividerColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: _buildStepImage(step.imagePath),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // Description
                              Expanded(
                                flex: 1,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      step.description,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Step indicators
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.steps.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: index == _currentStep ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: index == _currentStep
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).disabledColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepImage(String imagePath) {
    try {
      // Check if it's an asset image
      if (imagePath.startsWith('assets/')) {
        return Image.asset(
          imagePath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            developer.log('Failed to load asset image: $imagePath', error: error);
            return _buildPlaceholderImage();
          },
        );
      }
      
      // For network images or other sources
      return Image.network(
        imagePath,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          developer.log('Failed to load network image: $imagePath', error: error);
          return _buildPlaceholderImage();
        },
      );
    } catch (e) {
      developer.log('Error building step image: $imagePath', error: e);
      return _buildPlaceholderImage();
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'Diagram Image',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
