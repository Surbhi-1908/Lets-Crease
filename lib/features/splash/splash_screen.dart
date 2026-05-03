import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/demo_auth_provider.dart';
import '../../core/providers/audio_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _origamiController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _origamiAnimation;

  @override
  void initState() {
    super.initState();
    
    // Main logo animation controller - Extended duration for smoother experience
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    // Origami shapes animation controller - Synchronized with main animation
    _origamiController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    // Logo fade and scale animations - Smoother and longer
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeInOutCubic),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
    ));

    // Text fade animation (starts after logo, smoother transition)
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeInOutCubic),
    ));

    // Origami shapes animation
    _origamiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _origamiController,
      curve: Curves.easeInOut,
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    // Global music system will handle background music automatically
    
    // Start origami shapes animation immediately for synchronized effect
    _origamiController.repeat();
    
    // Start main logo and text animation with extended timing
    await _animationController.forward();
    await Future.delayed(const Duration(milliseconds: 1200));
    
    // Music continues globally, no need to stop here
    
    _checkAuthState();
  }

  void _checkAuthState() {
    final authState = ref.read(authStateProvider);
    final demoAuthState = ref.read(demoAuthProvider);
    
    // Check demo auth first
    if (demoAuthState) {
      if (mounted) context.go('/main');
      return;
    }
    
    // Check Firebase auth
    authState.when(
      data: (user) {
        if (user != null) {
          if (mounted) context.go('/main');
        } else if (mounted) {
          context.go('/login');
        }
      },
      loading: () {},
      error: (error, stack) {
        if (mounted) context.go('/login');
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _origamiController.dispose();
    super.dispose();
  }

  // Origami shape widget
  Widget _buildOrigamiShape({
    required double size,
    required Color color,
    required double left,
    required double top,
    required double rotationAngle,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: rotationAngle,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.6),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Stack(
        children: [
          // Animated origami shapes in background
          AnimatedBuilder(
            animation: _origamiAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  // Enhanced floating origami shapes with Pink and Blue theme colors
                  _buildOrigamiShape(
                    size: 35,
                    color: AppTheme.primaryColor, // Pink
                    left: screenSize.width * 0.08 + (sin(_origamiAnimation.value * 0.8 * pi) * 30),
                    top: screenSize.height * 0.18 + (cos(_origamiAnimation.value * 0.6 * pi) * 40),
                    rotationAngle: _origamiAnimation.value * 1.5 * pi,
                  ),
                  _buildOrigamiShape(
                    size: 28,
                    color: AppTheme.secondaryColor, // Blue
                    left: screenSize.width * 0.82 + (cos(_origamiAnimation.value * 1.2 * pi) * 25),
                    top: screenSize.height * 0.25 + (sin(_origamiAnimation.value * 0.9 * pi) * 35),
                    rotationAngle: -_origamiAnimation.value * 1.8 * pi,
                  ),
                  _buildOrigamiShape(
                    size: 40,
                    color: AppTheme.primaryLight, // Light Pink
                    left: screenSize.width * 0.12 + (cos(_origamiAnimation.value * 0.7 * pi) * 45),
                    top: screenSize.height * 0.72 + (sin(_origamiAnimation.value * 1.1 * pi) * 30),
                    rotationAngle: _origamiAnimation.value * 1.3 * pi,
                  ),
                  _buildOrigamiShape(
                    size: 32,
                    color: AppTheme.secondaryLight, // Light Blue
                    left: screenSize.width * 0.78 + (sin(_origamiAnimation.value * 1.4 * pi) * 35),
                    top: screenSize.height * 0.68 + (cos(_origamiAnimation.value * 0.8 * pi) * 25),
                    rotationAngle: -_origamiAnimation.value * 2.1 * pi,
                  ),
                  _buildOrigamiShape(
                    size: 26,
                    color: AppTheme.primaryDark, // Dark Pink
                    left: screenSize.width * 0.03 + (cos(_origamiAnimation.value * 1.6 * pi) * 20),
                    top: screenSize.height * 0.42 + (sin(_origamiAnimation.value * 1.3 * pi) * 40),
                    rotationAngle: _origamiAnimation.value * 1.7 * pi,
                  ),
                  _buildOrigamiShape(
                    size: 38,
                    color: AppTheme.secondaryDark, // Dark Blue
                    left: screenSize.width * 0.88 + (sin(_origamiAnimation.value * 0.5 * pi) * 30),
                    top: screenSize.height * 0.12 + (cos(_origamiAnimation.value * 0.7 * pi) * 25),
                    rotationAngle: -_origamiAnimation.value * 1.2 * pi,
                  ),
                  _buildOrigamiShape(
                    size: 30,
                    color: AppTheme.primaryColor.withValues(alpha: 0.7), // Semi-transparent Pink
                    left: screenSize.width * 0.45 + (sin(_origamiAnimation.value * 2.0 * pi) * 15),
                    top: screenSize.height * 0.08 + (cos(_origamiAnimation.value * 1.5 * pi) * 20),
                    rotationAngle: _origamiAnimation.value * 2.5 * pi,
                  ),
                  _buildOrigamiShape(
                    size: 24,
                    color: AppTheme.secondaryColor.withValues(alpha: 0.7), // Semi-transparent Blue
                    left: screenSize.width * 0.55 + (cos(_origamiAnimation.value * 1.8 * pi) * 18),
                    top: screenSize.height * 0.85 + (sin(_origamiAnimation.value * 1.2 * pi) * 22),
                    rotationAngle: -_origamiAnimation.value * 1.9 * pi,
                  ),
                ],
              );
            },
          ),
          
          // Main content
          Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo with fade and scale animation
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 25,
                                spreadRadius: 4,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipOval(
                              child: Transform.scale(
                                scale: 1.3, // Zoom the image for bold appearance
                                child: Image.asset(
                                  'assets/images/app_logo.png',
                                  width: 154,
                                  height: 154,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Fallback to icon if image fails to load
                                    return Container(
                                      width: 154,
                                      height: 154,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.auto_awesome,
                                        size: 80,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Text with fade animation
                    FadeTransition(
                      opacity: _textFadeAnimation,
                      child: Column(
                        children: [
                          // Line 1: "Let's Crease!" - Bold, modern font in Pink
                          Text(
                            "Let's Crease!",
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: AppTheme.primaryColor, // Pink #F941A6
                              fontWeight: FontWeight.bold,
                              fontSize: 34,
                              letterSpacing: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Line 2: "The Art Of Folding Paper" - Smaller, italic in Blue
                          Text(
                            "The Art Of Folding Paper",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.secondaryColor, // Blue #4885FF
                              fontStyle: FontStyle.italic,
                              fontSize: 18,
                              letterSpacing: 0.8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
