import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/NotificationModel.dart';

class NotificationsProvider with ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final Box _cacheBox = Hive.box('notifications_cache');
  StreamSubscription<QuerySnapshot>? _sub;

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Load cached notifications (offline support)
  void loadFromCache() {
    final raw = _cacheBox.get('notifications') as List<dynamic>?;
    if (raw != null) {
      _notifications = raw.map((data) {
        final map = Map<String, dynamic>.from(
          (data as Map).map((k, v) => MapEntry(k.toString(), v)),
        );
        return NotificationModel.fromMap(map);
      }).toList();
      notifyListeners();
    }
  }

  /// Save to cache
  void _cache() {
    final raw = _notifications.map((n) => n.toMap()).toList();
    _cacheBox.put('notifications', raw);
  }

  /// Start listening to Firestore for updates
  void listenToNotifications(String uid) {
    _sub?.cancel();
    _sub = _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snap) {
      _notifications = snap.docs.map((d) => NotificationModel.fromFirestore(d.id, d.data())).toList();
      _cache();
      notifyListeners();
    });
  }

  /// Mark single notification as read
  Future<void> markAsRead(NotificationModel notif, String uid) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notif.id)
        .update({'isRead': true});
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(String uid) async {
    final batch = _db.batch();
    final col = _db.collection('users').doc(uid).collection('notifications');
    final q = await col.where('isRead', isEqualTo: false).get();
    for (var d in q.docs) {
      batch.update(d.reference, {'isRead': true});
    }
    await batch.commit();
  }

  /// Store incoming push into Firestore inbox
  Future<void> addFromRemoteMessage(String uid, RemoteMessage message) async {
    final data = message.data;
    final title = message.notification?.title ?? data['title'] ?? 'Notification';
    final body = message.notification?.body ?? data['message'] ?? '';
    final iconPath = data['iconPath'] ?? 'assets/icons/notification.svg';

    await _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .add({
      'title': title,
      'message': body,
      'iconPath': iconPath,
      'isRead': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
