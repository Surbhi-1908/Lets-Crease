import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:developer' as developer;
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/providers/settings_provider.dart';
import 'core/providers/audio_provider.dart';
import 'core/services/notification_service.dart';
import 'core/widgets/notification_listener.dart' as custom;

/*
 * FIREBASE SETUP INSTRUCTIONS:
 * 
 * 1. ANDROID SETUP:
 *    - Place your 'google-services.json' file in: android/app/
 *    - Ensure android/app/build.gradle has:
 *      apply plugin: 'com.google.gms.google-services'
 *    - Ensure android/build.gradle has:
 *      classpath 'com.google.gms:google-services:4.3.15'
 * 
 * 2. iOS SETUP:
 *    - Place your 'GoogleService-Info.plist' file in: ios/Runner/
 *    - Open ios/Runner.xcworkspace in Xcode
 *    - Right-click Runner folder → Add Files to "Runner"
 *    - Select GoogleService-Info.plist and ensure it's added to Runner target
 * 
 * 3. WEB SETUP (Optional):
 *    - Update web/index.html with Firebase SDK scripts
 *    - Add Firebase config in firebase_options.dart
 * 
 * 4. DEPENDENCIES:
 *    - Run 'flutter pub get' after adding Firebase dependencies
 *    - Run 'flutterfire configure' to auto-generate firebase_options.dart
 * 
 * Note: Firebase is initialized before the app starts to ensure
 * all Firebase services are available throughout the app lifecycle.
 */

void main() async {
  // Ensure Flutter binding is initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    developer.log('Firebase initialized successfully');
    
    // Initialize Firebase Cloud Messaging
    await NotificationService.initialize();
    developer.log('FCM service initialized');
    
    // Print FCM token for testing
    await NotificationService.printFCMToken();
    developer.log('FCM token request completed');
  } catch (e) {
    developer.log('Firebase initialization error: $e');
    // Continue with app initialization even if Firebase fails
  }
  
  // Add a small delay to ensure Firebase is fully initialized
  await Future.delayed(const Duration(milliseconds: 100));
  
  // Start the app with Riverpod state management
  runApp(const ProviderScope(child: OrigamiApp()));
}

class OrigamiApp extends ConsumerWidget {
  const OrigamiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsProvider);
    
    // Initialize audio provider to start global music system
    ref.watch(audioProvider);
    
    return custom.NotificationListener(
      child: MaterialApp.router(
        title: 'Let\'s Crease!',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
