import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_dialog.dart';

class NotificationListener extends ConsumerStatefulWidget {
  final Widget child;

  const NotificationListener({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<NotificationListener> createState() => _NotificationListenerState();
}

class _NotificationListenerState extends ConsumerState<NotificationListener> {
  @override
  void initState() {
    super.initState();
    _setupForegroundNotificationListener();
  }

  void _setupForegroundNotificationListener() {
    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null && mounted) {
        // Show in-app notification dialog
        NotificationDialog.show(
          context,
          message.notification!,
          data: message.data,
          onTap: () => _handleNotificationTap(message),
        );
      }
    });

    // Listen for notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message);
    });
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Handle navigation based on notification data
    if (message.data.containsKey('screen')) {
      String screen = message.data['screen'];
      
      switch (screen) {
        case 'home':
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          break;
        case 'categories':
          Navigator.of(context).pushNamed('/categories');
          break;
        case 'simulator':
          Navigator.of(context).pushNamed('/simulator');
          break;
        case 'profile':
          Navigator.of(context).pushNamed('/profile');
          break;
        default:
          // Navigate to home by default
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
