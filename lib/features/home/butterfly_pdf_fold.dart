import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../core/services/ai_pdf_service.dart';

class PdfButterflyFoldSteps extends StatefulWidget {
  final String assetPath;
  final double height;
  final Duration animationDuration;
  final Duration autoPlayInterval;

  const PdfButterflyFoldSteps({
    super.key,
    required this.assetPath,
    this.height = 350,
    this.animationDuration = const Duration(milliseconds: 800),
    this.autoPlayInterval = const Duration(seconds: 4),
  });

  @override
  State<PdfButterflyFoldSteps> createState() => _PdfButterflyFoldStepsState();
}

class _PdfButterflyFoldStepsState extends State<PdfButterflyFoldSteps>
    with TickerProviderStateMixin {
  late AnimationController _foldAnimationController;
  late Animation<double> _foldAnimation;
  late PageController _pageController;
  late AudioPlayer _audioPlayer;
  late FlutterTts _tts;
  
  int _currentPage = 1;
  bool _isAutoPlaying = true;
  bool _isAudioPlaying = false;
  bool _isAIEnabled = false;
  List<String> _pdfTextContent = [];
  bool _isFirstTime = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _audioPlayer = AudioPlayer();
    _tts = FlutterTts();
    
    // Initialize AI services
    _initializeAIServices();
    
    _foldAnimationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _foldAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _foldAnimationController,
      curve: Curves.easeInOut,
    ));

    _startFoldAnimation();
  }

  @override
  void dispose() {
    _foldAnimationController.dispose();
    _pageController.dispose();
    _audioPlayer.dispose();
    AIPdfService.disposeTTS();
    super.dispose();
  }

  void _startFoldAnimation() {
    if (!_isAutoPlaying) return;
    
    _foldAnimationController.forward().then((_) {
      if (mounted && _isAutoPlaying) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && _isAutoPlaying) {
            _foldAnimationController.reverse().then((_) {
              if (mounted && _isAutoPlaying) {
                Future.delayed(widget.autoPlayInterval, () {
                  if (mounted && _isAutoPlaying) {
                    _nextStep();
                  }
                });
              }
            });
          }
        });
      }
    });
  }

  void _toggleAudioInstructions() async {
    if (_isAudioPlaying) {
      await _audioPlayer.stop();
      setState(() {
        _isAudioPlaying = false;
      });
    } else {
      setState(() {
        _isAudioPlaying = true;
      });
      await _playAudioInstruction();
    }
  }

  Future<void> _playAudioInstruction() async {
    // Generic step-by-step instructions for butterfly origami
    final instructions = [
      "Step ${_currentPage}: Start with a square piece of paper, colored side up.",
      "Step ${_currentPage}: Fold the paper in half diagonally to create a triangle.",
      "Step ${_currentPage}: Fold the top corners down to meet at the center point.",
      "Step ${_currentPage}: Fold the bottom point up to create the butterfly body.",
      "Step ${_currentPage}: Fold the wings by creating diagonal creases.",
      "Step ${_currentPage}: Open the wings to form the butterfly shape.",
    ];
    
    final currentInstruction = _currentPage <= instructions.length 
        ? instructions[_currentPage - 1] 
        : "You've completed all the basic folds. Now shape your butterfly.";
    
    // Show instruction as text notification (since we don't have actual audio files)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(currentInstruction),
        duration: const Duration(seconds: 4),
        backgroundColor: Theme.of(context).primaryColor,
        action: SnackBarAction(
          label: 'Got it',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _nextStep() async {
    setState(() {
      _currentPage = _currentPage < 6 ? _currentPage + 1 : 1;
    });
    
    _pageController.animateToPage(
      _currentPage - 1,
      duration: widget.animationDuration,
      curve: Curves.easeInOut,
    );
    
    _pauseAutoPlay();
    
    // Speak AI instruction for new step
    if (_isAIEnabled) {
      await _speakAIInstruction();
    }
    
    _startFoldAnimation();
  }

  void _previousStep() async {
    setState(() {
      _currentPage = _currentPage > 1 ? _currentPage - 1 : 6;
    });
    
    _pageController.animateToPage(
      _currentPage - 1,
      duration: widget.animationDuration,
      curve: Curves.easeInOut,
    );
    
    _pauseAutoPlay();
    
    // Speak AI instruction for new step
    if (_isAIEnabled) {
      await _speakAIInstruction();
    }
    
    _startFoldAnimation();
  }

  void _pauseAutoPlay() {
    setState(() {
      _isAutoPlaying = false;
    });
    _foldAnimationController.stop();
  }

  void _resumeAutoPlay() {
    setState(() {
      _isAutoPlaying = true;
    });
    _startFoldAnimation();
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
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
      child: Column(
        children: [
          // Header with step indicator and controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Step $_currentPage of 6',
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
                    const SizedBox(width: 8),
                    // AI Audio Button
                    if (_isAIEnabled)
                      IconButton(
                        onPressed: _toggleAIAudio,
                        icon: Icon(_isAudioPlaying ? Icons.smart_toy : Icons.smart_toy_outlined),
                        iconSize: 20,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        tooltip: 'AI Instructions',
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          // Main PDF viewer with fold animation
          Expanded(
            child: AnimatedBuilder(
              animation: _foldAnimation,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(_foldAnimation.value * 0.1),
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2 * _foldAnimation.value),
                          blurRadius: 10 * _foldAnimation.value,
                          spreadRadius: 2 * _foldAnimation.value,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index + 1;
                          });
                          _pauseAutoPlay();
                        },
                        itemCount: 6, // Default to 6 steps
                        itemBuilder: (context, index) {
                          return Container(
                            color: Colors.white,
                            child: SfPdfViewer.asset(
                              widget.assetPath,
                              initialPageNumber: index + 1,
                              enableDoubleTapZooming: true,
                              enableTextSelection: false,
                              canShowScrollHead: false,
                              canShowScrollStatus: false,
                              canShowPaginationDialog: false,
                              onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                                // Handle PDF load failure
                              },
                            ),
                          );
                        },
                      ),
                    ),
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
                6, // Default to 6 steps
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: index + 1 == _currentPage ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: index + 1 == _currentPage
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
    );
  }
}
