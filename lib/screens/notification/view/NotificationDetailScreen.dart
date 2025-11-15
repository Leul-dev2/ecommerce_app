import 'package:flutter/material.dart';
import '../../../models/NotificationModel.dart';

class NotificationDetailScreen extends StatelessWidget {
  final NotificationModel notification;
  const NotificationDetailScreen({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Notification')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(notification.message, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
            Text('Received: ${notification.timestamp}', style: theme.textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}
