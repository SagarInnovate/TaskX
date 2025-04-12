// lib/core/firebase/firebase_config.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../../firebase_options.dart';
import '../analytics/analytics_service.dart';

class FirebaseConfig {
  // Singleton pattern
  static final FirebaseConfig _instance = FirebaseConfig._internal();
  factory FirebaseConfig() => _instance;
  FirebaseConfig._internal();

  // Initialize Firebase services
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize analytics
    await _initializeAnalytics();

    // Initialize messaging
    await _initializeMessaging();
  }

  // Initialize Firebase Analytics
  Future<void> _initializeAnalytics() async {
    final analytics = AnalyticsService().analytics;

    // Enable analytics collection
    await analytics.setAnalyticsCollectionEnabled(true);

    // Log app open event
    await AnalyticsService().logAppOpen();
  }

  // Initialize Firebase Messaging for push notifications
  Future<void> _initializeMessaging() async {
    final messaging = FirebaseMessaging.instance;

    // Request permission (iOS)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Configure FCM token refresh listener
    messaging.onTokenRefresh.listen((fcmToken) {
      // Here you would typically send this token to your server
      print('FCM Token refreshed: $fcmToken');
    });

    // Handle received messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        // Show local notification
      }
    });

    // Get the initial message if the app was opened from a terminated state
    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      // Handle the initial message
      _handleMessage(initialMessage);
    }

    // Register a callback for handling messages when the app is in the background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    // Get the FCM token
    String? token = await messaging.getToken();
    print('FCM Token: $token');
  }

  // Handle incoming message
  void _handleMessage(RemoteMessage message) {
    // Handle message based on payload
    if (message.data.containsKey('type')) {
      final String type = message.data['type'];

      switch (type) {
        case 'task_assigned':
          // Navigate to the assigned task
          _navigateToTask(message.data['taskId']);
          break;
        case 'task_updated':
          // Navigate to the updated task
          _navigateToTask(message.data['taskId']);
          break;
        case 'workspace_invitation':
          // Navigate to workspace invitations
          _navigateToWorkspaceInvitations();
          break;
        default:
          // Default handling
          print('Unhandled message type: $type');
      }
    }
  }

  // Navigation methods (would be implemented in a real app)
  void _navigateToTask(String? taskId) {
    // This would be implemented to navigate to the task detail screen
    print('Navigate to task: $taskId');
  }

  void _navigateToWorkspaceInvitations() {
    // This would be implemented to navigate to the workspace invitations screen
    print('Navigate to workspace invitations');
  }

  // Configure error reporting
  Future<void> configureErrorReporting() async {
    // Set up error handling for uncaught errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      // Log error to analytics
      AnalyticsService().logError(
        'uncaught_flutter_error',
        details.exception.toString(),
      );
    };
  }
}
