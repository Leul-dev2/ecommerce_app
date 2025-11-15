import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../providers/notifications_provider.dart';
import 'local_notifications.dart';

/// Global navigator key to handle notification taps from background.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class PushService {
  static Future<void> init(NotificationsProvider notifProvider) async {
    await LocalNotifications.init();

    final messaging = FirebaseMessaging.instance;

    // Ask for user permission (iOS mandatory, Android auto-granted).
    await messaging.requestPermission();

    // Token & refresh
    await _ensureTokenSaved();
    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      await _saveToken(token);
    });

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final title = message.notification?.title ?? message.data['title'] ?? 'Notification';
      final body = message.notification?.body ?? message.data['message'] ?? '';

      await LocalNotifications.show(
        id: Random().nextInt(1 << 31),
        title: title,
        body: body,
      );

      // If signed in, persist to Firestore inbox.
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await notifProvider.addFromRemoteMessage(user.uid, message);
      }
    });

    // User taps a notification when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _navigateToNotificationInbox();
    });

    // App launched by tapping a notification (terminated state)
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _navigateToNotificationInbox();
    }
  }

  static void _navigateToNotificationInbox() {
    final ctx = rootNavigatorKey.currentContext;
    if (ctx == null) return;
    Navigator.of(ctx).pushNamed('/notifications');
  }

  static Future<void> _ensureTokenSaved() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await _saveToken(token);
  }

  static Future<void> _saveToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
      {'fcmToken': token, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }
}
