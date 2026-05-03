import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer' as developer;

class FCMTokenScreen extends StatefulWidget {
  const FCMTokenScreen({super.key});

  @override
  State<FCMTokenScreen> createState() => _FCMTokenScreenState();
}

class _FCMTokenScreenState extends State<FCMTokenScreen> {
  String _token = "Fetching FCM token...";
  bool _isLoading = true;
  String _permissionStatus = "Checking permissions...";

  @override
  void initState() {
    super.initState();
    _initializeFCM();
  }

  Future<void> _initializeFCM() async {
    try {
      // Request notification permission
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      setState(() {
        _permissionStatus = "Permission: ${settings.authorizationStatus.name}";
      });

      developer.log("🔔 Permission status: ${settings.authorizationStatus}");

      // Get FCM token
      String? token = await FirebaseMessaging.instance.getToken();
      
      setState(() {
        _token = token ?? "Failed to get FCM token";
        _isLoading = false;
      });

      developer.log("🔥 FCM Token: $token");

    } catch (e) {
      setState(() {
        _token = "Error: $e";
        _isLoading = false;
        _permissionStatus = "Error getting permissions";
      });
      developer.log("❌ FCM Error: $e");
    }
  }

  Future<void> _copyToClipboard() async {
    if (_token != "Fetching FCM token..." && !_token.startsWith("Error:")) {
      await Clipboard.setData(ClipboardData(text: _token));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("FCM Token copied to clipboard!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _refreshToken() async {
    setState(() {
      _isLoading = true;
      _token = "Refreshing FCM token...";
    });
    await _initializeFCM();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FCM Token Viewer"),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshToken,
            tooltip: "Refresh Token",
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Permission Status Card
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          _permissionStatus.contains("authorized") 
                            ? Icons.check_circle 
                            : Icons.warning,
                          color: _permissionStatus.contains("authorized") 
                            ? Colors.green 
                            : Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _permissionStatus,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Instructions Card
                const Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info, color: Color(0xFF2196F3)),
                            SizedBox(width: 8),
                            Text(
                              "How to use this token:",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          "1. Copy the FCM token below\n"
                          "2. Go to Firebase Console > Cloud Messaging\n"
                          "3. Click 'Send your first message'\n"
                          "4. Paste the token in 'Send test message to FCM registration token'\n"
                          "5. Add title, body, and send!",
                          style: TextStyle(fontSize: 14, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // FCM Token Card
                Expanded(
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.token, color: Color(0xFF2196F3)),
                              const SizedBox(width: 8),
                              const Text(
                                "FCM Registration Token:",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              if (_isLoading)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Token Display
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: SingleChildScrollView(
                                child: SelectableText(
                                  _token,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                    color: Colors.black87,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Copy Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _token.startsWith("Fetching") || _token.startsWith("Error") 
                                ? null 
                                : _copyToClipboard,
                              icon: const Icon(Icons.copy),
                              label: const Text("Copy Token to Clipboard"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2196F3),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
