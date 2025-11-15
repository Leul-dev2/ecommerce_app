import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecommerce/providers/notifications_provider.dart';
import '../../../models/NotificationModel.dart';
import 'NotificationDetailScreen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _formatTimeAgo(DateTime ts) {
    final now = DateTime.now();
    final diff = now.difference(ts);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays} days ago';
  }

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<NotificationsProvider>(context, listen: false)
            .listenToNotifications(user.uid);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<NotificationsProvider>(context, listen: true);
    final user = FirebaseAuth.instance.currentUser;
    final notifications = provider.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () async {
                if (user != null) await provider.markAllAsRead(user.uid);
              },
              child: const Text('Mark all as read'),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/illustrations/empty_notifications.svg',
                      height: 180,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "No notifications yet!",
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "We'll notify you about order updates, offers and more.",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NotificationDetailScreen(notification: notif),
                      ),
                    );
                    if (user != null) {
                      provider.markAsRead(notif, user.uid);
                    }
                  },
                  child: NotificationTile(
                    notification: notif,
                    timeAgo: _formatTimeAgo(notif.timestamp),
                  ),
                );
              },
            ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final String timeAgo;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: notification.isRead
            ? theme.colorScheme.surface
            : theme.colorScheme.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead
              ? Colors.transparent
              : theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            notification.iconPath,
            width: 36,
            height: 36,
            colorFilter: ColorFilter.mode(
              theme.colorScheme.primary,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  timeAgo,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (!notification.isRead)
            Container(
              margin: const EdgeInsets.only(left: 8, top: 4),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
