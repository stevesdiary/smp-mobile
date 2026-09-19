import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationModel {
  final String id;
  final String title;
  final String message;
  final String time;
  final String date;
  final _NotificationType type;
  bool isRead;

  _NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.date,
    required this.type,
    this.isRead = false,
  });
}

enum _NotificationType { absence, grade, fee, general }

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Dummy data
  final List<_NotificationModel> _notifications = [
    _NotificationModel(
      id: '1',
      title: 'Child marked absent',
      message: 'Emeka Obi was marked ABSENT on\nTuesday, 26 May 2026',
      time: '9:02 AM',
      date: 'Today',
      type: _NotificationType.absence,
    ),
    _NotificationModel(
      id: '2',
      title: 'New grade posted',
      message: 'Mathematics: 87% (B) - Algebra Quiz',
      time: 'Yesterday',
      date: 'Earlier',
      type: _NotificationType.grade,
      isRead: true,
    ),
    _NotificationModel(
      id: '3',
      title: 'Fee reminder',
      message: 'Term 3 School Fees (₦50,000) are due next week on June 15, 2026.',
      time: 'Mon',
      date: 'Earlier',
      type: _NotificationType.fee,
      isRead: true,
    ),
    _NotificationModel(
      id: '4',
      title: 'School Newsletter',
      message: 'May newsletter is now available. Read about our upcoming events.',
      time: 'May 20',
      date: 'Earlier',
      type: _NotificationType.general,
      isRead: true,
    ),
  ];

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n.isRead = true;
      }
    });
  }

  void _dismissNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
  }

  Color _getIconColor(_NotificationType type) {
    final theme = Theme.of(context).colorScheme;
    switch (type) {
      case _NotificationType.absence:
        return theme.error;
      case _NotificationType.grade:
        return const Color(0xFF34C759); // success green
      case _NotificationType.fee:
        return const Color(0xFFFF9F0A); // warning amber
      case _NotificationType.general:
        return const Color(0xFF5051BD); // interactive blue
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Notifications',
          style: theme.textTheme.displayLarge?.copyWith(fontSize: 28),
        ),
        actions: [
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Mark all read',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF5051BD), // primaryLight
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState(theme)
          : _buildList(theme),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "You're all caught up",
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(ThemeData theme) {
    // Group notifications by date
    final today = _notifications.where((n) => n.date == 'Today').toList();
    final earlier = _notifications.where((n) => n.date != 'Today').toList();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (today.isNotEmpty) ...[
          _buildSectionHeader(theme, 'Today'),
          ...today.map((n) => _buildNotificationItem(theme, n)),
        ],
        if (earlier.isNotEmpty) ...[
          if (today.isNotEmpty) const SizedBox(height: 16),
          _buildSectionHeader(theme, 'Earlier'),
          ...earlier.map((n) => _buildNotificationItem(theme, n)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(ThemeData theme, _NotificationModel notification) {
    final bgColor = notification.isRead
        ? const Color(0xFFF4F3F8) // surfaceSecondary
        : Colors.white;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => _dismissNotification(notification.id),
      background: Container(
        color: theme.colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Container(
        color: bgColor,
        padding: const EdgeInsets.all(16),
        // subtle left border if unread
        decoration: BoxDecoration(
          border: !notification.isRead
              ? const Border(
                  left: BorderSide(
                    color: Color(0xFF5051BD), // primaryLight
                    width: 2.0,
                  ),
                )
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Colored dot icon
            Container(
              margin: const EdgeInsets.only(top: 4, right: 12),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getIconColor(notification.type),
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: notification.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        notification.time,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
