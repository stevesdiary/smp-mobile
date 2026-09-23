import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Sticky Header
            SliverAppBar(
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: theme.scaffoldBackgroundColor,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good morning, Parent',
                    style: textTheme.headlineMedium,
                  ),
                  Text(
                    'Tuesday, 26 May 2026',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Badge(
                    label: const Text('2'),
                    backgroundColor: colorScheme.error,
                    child: const Icon(Icons.notifications_outlined),
                  ),
                  onPressed: () {
                    // TODO: Navigate to notifications
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
            
            // Child Summary Cards (Horizontal Scroll)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: 2, // Dummy count
                  itemBuilder: (context, index) {
                    final names = ['Emeka Obi', 'Chidi Obi'];
                    final classes = ['JSS 1', 'SSS 3'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: _ChildSummaryCard(
                        name: names[index],
                        className: classes[index],
                      ),
                    );
                  },
                ),
              ),
            ),

            // Quick Actions Row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _QuickActionIcon(icon: Icons.assignment_turned_in_outlined, label: 'Attendance', onTap: () => context.go('/home/attendance')),
                        _QuickActionIcon(icon: Icons.bar_chart_rounded, label: 'Grades', onTap: () => context.go('/home/grades')),
                        _QuickActionIcon(icon: Icons.calendar_month_outlined, label: 'Timetable', onTap: () => context.go('/home/timetable')),
                        _QuickActionIcon(icon: Icons.payment_outlined, label: 'Fees', onTap: () => context.go('/home/fees')),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Today's Activity Feed
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Today',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final items = [
                      const _ActivityFeedItem(
                        icon: Icons.check_circle,
                        iconColor: Color(0xFF00897B),
                        title: 'Emeka Obi — Attendance: Present',
                        time: '08:15 AM',
                      ),
                      const _ActivityFeedItem(
                        icon: Icons.check_circle,
                        iconColor: Color(0xFF00897B),
                        title: 'Chidi Obi — Attendance: Present',
                        time: '08:20 AM',
                      ),
                      const _ActivityFeedItem(
                        icon: Icons.bar_chart_rounded,
                        iconColor: Color(0xFF3B3BA8),
                        title: 'Emeka Obi — New grade posted: Mathematics',
                        time: '10:00 AM',
                      ),
                      const _ActivityFeedItem(
                        icon: Icons.campaign_outlined,
                        iconColor: Color(0xFFE65100),
                        title: 'School Notice: End of term assembly',
                        time: '11:30 AM',
                      ),
                    ];
                    return items[index];
                  },
                  childCount: 4,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class _ChildSummaryCard extends StatelessWidget {
  final String name;
  final String className;

  const _ChildSummaryCard({
    required this.name,
    required this.className,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF8E8E93).withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFF0F0FF),
                foregroundColor: colorScheme.primary,
                child: Text(name[0]), // Initials
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '$className · Greenwood Academy',
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          // Sparkline placeholder
          Row(
            children: List.generate(
              7,
              (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: index == 6 ? Colors.orange : Colors.cyan, // Last day amber, rest cyan
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Attendance 94%  ·  1 alert',
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _QuickActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionIcon({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0FF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            icon: Icon(icon, color: const Color(0xFF3B3BA8), size: 28),
            onPressed: onTap,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ActivityFeedItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String time;

  const _ActivityFeedItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
