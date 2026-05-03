import 'dart:developer' as developer;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  developer.log('Handling a background message: ${message.messageId}');
  developer.log('Background message data: ${message.data}');
  if (message.notification != null) {
    developer.log('Background notification: ${message.notification!.title}');
  }
}

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static String? _fcmToken;

  // Initialize Firebase Messaging
  static Future<void> initialize() async {
    try {
      // Request permission for notifications
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      developer.log('FCM Permission Status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        developer.log('User granted permission for notifications');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        developer.log('User granted provisional permission');
      } else {
        developer.log('User declined or has not accepted permission');
      }

      // Get FCM token
      _fcmToken = await _firebaseMessaging.getToken();
      developer.log('FCM Token: $_fcmToken');

      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle notification tap when app is terminated
      RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        developer.log('FCM Token refreshed: $newToken');
        _fcmToken = newToken;
        // Here you can send the new token to your server
      });

      // Subscribe to topic for general notifications
      await _firebaseMessaging.subscribeToTopic('origami_updates');
      developer.log('Subscribed to origami_updates topic');

    } catch (e) {
      developer.log('Error initializing notifications: $e');
    }
  }

  // Handle foreground messages
  static void _handleForegroundMessage(RemoteMessage message) {
    developer.log('Got a message whilst in the foreground!');
    developer.log('Message data: ${message.data}');

    if (message.notification != null) {
      developer.log('Message also contained a notification: ${message.notification}');
      
      // Show in-app notification dialog
      _showInAppNotification(message);
    }
  }

  // Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    developer.log('Message clicked!');
    developer.log('Message data: ${message.data}');
    
    // Handle navigation based on notification data
    if (message.data.containsKey('screen')) {
      String screen = message.data['screen'];
      developer.log('Navigate to screen: $screen');
      // Add navigation logic here based on your app's routing
    }
  }

  // Show in-app notification dialog
  static void _showInAppNotification(RemoteMessage message) {
    // This will be called from the main app context
    // We'll need to access the current context through a global key or provider
    final notification = message.notification;
    if (notification != null) {
      // Store notification for display in UI
      _currentNotification = notification;
      _notificationData = message.data;
    }
  }

  // Static variables to hold current notification
  static RemoteNotification? _currentNotification;
  static Map<String, dynamic>? _notificationData;

  // Getters for current notification
  static RemoteNotification? get currentNotification => _currentNotification;
  static Map<String, dynamic>? get notificationData => _notificationData;

  // Clear current notification
  static void clearCurrentNotification() {
    _currentNotification = null;
    _notificationData = null;
  }

  // Get FCM token
  static String? get fcmToken => _fcmToken;

  // Simple method to get and print FCM token (as requested)
  static Future<void> printFCMToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      print("My FCM Token: $token");
      developer.log("My FCM Token: $token");
      _fcmToken = token; // Update the stored token
    } catch (e) {
      print("Error getting FCM token: $e");
      developer.log("Error getting FCM token: $e");
    }
  }

  // Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      developer.log('Subscribed to topic: $topic');
    } catch (e) {
      developer.log('Error subscribing to topic $topic: $e');
    }
  }

  // Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      developer.log('Unsubscribed from topic: $topic');
    } catch (e) {
      developer.log('Error unsubscribing from topic $topic: $e');
    }
  }

  // Delete FCM token (useful for logout)
  static Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
      developer.log('FCM token deleted');
    } catch (e) {
      developer.log('Error deleting FCM token: $e');
    }
  }
}

// Provider for notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Provider for current notification state
final currentNotificationProvider = StateProvider<RemoteNotification?>((ref) {
  return NotificationService.currentNotification;
});
