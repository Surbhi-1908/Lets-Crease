import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../theme/app_theme.dart';

class NotificationDialog extends StatelessWidget {
  final RemoteNotification notification;
  final Map<String, dynamic>? data;
  final VoidCallback? onTap;

  const NotificationDialog({
    super.key,
    required this.notification,
    this.data,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withValues(alpha: 0.1),
              AppTheme.secondaryColor.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_active,
                color: AppTheme.primaryColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            
            // Title
            if (notification.title != null)
              Text(
                notification.title!,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            
            if (notification.title != null && notification.body != null)
              const SizedBox(height: 8),
            
            // Body
            if (notification.body != null)
              Text(
                notification.body!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
            
            const SizedBox(height: 20),
            
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Dismiss',
                      style: TextStyle(color: AppTheme.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onTap?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('View'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static void show(
    BuildContext context,
    RemoteNotification notification, {
    Map<String, dynamic>? data,
    VoidCallback? onTap,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => NotificationDialog(
        notification: notification,
        data: data,
        onTap: onTap,
      ),
    );
  }
}
