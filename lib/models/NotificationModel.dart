// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String iconPath;
  final String? route;
  final Map<String, dynamic>? routeArgs;
  final bool isRead;
  final DateTime timestamp;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.iconPath,
    this.route,
    this.routeArgs,
    required this.isRead,
    required this.timestamp,
  });

  factory NotificationModel.fromFirestore(String id, Map<String, dynamic> data) {
    return NotificationModel(
      id: id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      iconPath: data['iconPath'] ?? '',
      route: data['route'],
      routeArgs: data['routeArgs'],
      isRead: data['isRead'] ?? false,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory NotificationModel.fromMap(Map<String, dynamic> data) {
    return NotificationModel(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      iconPath: data['iconPath'] ?? '',
      route: data['route'],
      routeArgs: data['routeArgs'],
      isRead: data['isRead'] ?? false,
      timestamp: DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'iconPath': iconPath,
      'route': route,
      'routeArgs': routeArgs,
      'isRead': isRead,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
