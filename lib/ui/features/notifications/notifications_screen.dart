import 'package:flutter/material.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/notifications_repository.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<NotificationModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = notificationsRepository.getNotifications();
  }

  void _reload() => setState(() {
        _future = notificationsRepository.getNotifications();
      });

  Future<void> _markAllRead() async {
    await notificationsRepository.markAllRead();
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<NotificationModel>>(
          future: _future,
          builder: (context, snapshot) {
            final notifications = snapshot.data ?? [];
            final unread = notifications.where((n) => !n.read).toList();
            final read = notifications.where((n) => n.read).toList();

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  elevation: 0,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  title: Text('Notifications', style: textTheme.headlineMedium),
                  actions: [
                    if (unread.isNotEmpty)
                      TextButton(
                        onPressed: _markAllRead,
                        child: Text(
                          'Mark all read',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),

                if (snapshot.connectionState == ConnectionState.waiting)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (snapshot.hasError)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text('Failed to load notifications', style: textTheme.bodyMedium),
                          const SizedBox(height: 12),
                          ElevatedButton(onPressed: _reload, child: const Text('Retry')),
                        ],
                      ),
                    ),
                  )
                else if (notifications.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text('No notifications yet', style: textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  )
                else ...[
                  if (unread.isNotEmpty) ...[
                    _SectionHeader(label: 'New (${unread.length})'),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _NotificationTile(
                            notification: unread[i],
                            onTap: () async {
                              await notificationsRepository.markRead([unread[i].id]);
                              _reload();
                            },
                          ),
                          childCount: unread.length,
                        ),
                      ),
                    ),
                  ],
                  if (read.isNotEmpty) ...[
                    const _SectionHeader(label: 'Earlier'),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _NotificationTile(notification: read[i]),
                          childCount: read.length,
                        ),
                      ),
                    ),
                  ],
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const _NotificationTile({required this.notification, this.onTap});

  static const _typeIcons = {
    'attendance': Icons.assignment_turned_in_outlined,
    'grade': Icons.bar_chart_rounded,
    'notice': Icons.campaign_outlined,
    'event': Icons.event_outlined,
    'payment': Icons.payment_outlined,
  };

  static const _typeColors = {
    'attendance': Color(0xFF00897B),
    'grade': Color(0xFF3B3BA8),
    'notice': Color(0xFFE65100),
    'event': Color(0xFF6A1B9A),
    'payment': Color(0xFF2E7D32),
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final icon = _typeIcons[notification.type] ?? Icons.notifications_outlined;
    final color = _typeColors[notification.type] ?? const Color(0xFF050057);
    final isUnread = !notification.read;

    final d = notification.createdAt;
    final timeLabel = '${d.day}/${d.month}/${d.year}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnread ? color.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUnread
                ? color.withValues(alpha: 0.2)
                : const Color(0xFF8E8E93).withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(notification.body, style: textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    timeLabel,
                    style: textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
