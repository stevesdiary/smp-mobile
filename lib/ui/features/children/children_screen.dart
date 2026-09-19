import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/child_model.dart';
import '../../../data/models/attendance_model.dart';
import '../../../data/repositories/children_repository.dart';
import 'children_provider.dart';

class ChildrenScreen extends StatefulWidget {
  const ChildrenScreen({super.key});

  @override
  State<ChildrenScreen> createState() => _ChildrenScreenState();
}

class _ChildrenScreenState extends State<ChildrenScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChildrenProvider>().load();
    });
  }

  void _openDetail(Child child) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ChildDetailSheet(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              backgroundColor: theme.scaffoldBackgroundColor,
              title: Text('My Children', style: textTheme.headlineMedium),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: Consumer<ChildrenProvider>(
                builder: (context, provider, _) {
                  if (provider.loading) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (provider.error != null) {
                    return SliverFillRemaining(
                      child: _ErrorState(onRetry: provider.load),
                    );
                  }
                  if (provider.children.isEmpty) {
                    return const SliverFillRemaining(child: _EmptyState());
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _ChildCard(
                          child: provider.children[index],
                          onTap: () => _openDetail(provider.children[index]),
                        ),
                      ),
                      childCount: provider.children.length,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Child Card ────────────────────────────────────────────────────────────────

class _ChildCard extends StatelessWidget {
  final Child child;
  final VoidCallback onTap;

  const _ChildCard({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF8E8E93).withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFF0F0FF),
              child: Text(
                child.initials,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.displayName,
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (child.studentId.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'ID: ${child.studentId}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  _StatusBadge(status: child.status),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'ACTIVE';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.green.shade700 : Colors.orange.shade700,
        ),
      ),
    );
  }
}

// ── Detail Bottom Sheet ───────────────────────────────────────────────────────

class _ChildDetailSheet extends StatefulWidget {
  final Child child;
  const _ChildDetailSheet({required this.child});

  @override
  State<_ChildDetailSheet> createState() => _ChildDetailSheetState();
}

class _ChildDetailSheetState extends State<_ChildDetailSheet> {
  late Future<List<AttendanceRecord>> _attendanceFuture;

  @override
  void initState() {
    super.initState();
    _attendanceFuture = childrenRepository.getChildAttendance(widget.child.id);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFC7C5D3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: const Color(0xFFF0F0FF),
                    child: Text(
                      widget.child.initials,
                      style: textTheme.headlineSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.child.displayName,
                          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        if (widget.child.studentId.isNotEmpty)
                          Text(
                            'ID: ${widget.child.studentId}',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(height: 1, color: Color(0xFFC7C5D3)),
            Expanded(
              child: FutureBuilder<List<AttendanceRecord>>(
                future: _attendanceFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Could not load attendance', style: textTheme.bodyMedium),
                    );
                  }
                  final records = snapshot.data ?? [];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                        child: Text(
                          'Recent Attendance',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      if (records.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text('No attendance records found.', style: textTheme.bodyMedium),
                        )
                      else
                        Expanded(
                          child: ListView.separated(
                            controller: controller,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: records.length,
                            separatorBuilder: (context, i) =>
                                const Divider(height: 1, color: Color(0xFFC7C5D3)),
                            itemBuilder: (_, i) => _AttendanceRow(record: records[i]),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  final AttendanceRecord record;
  const _AttendanceRow({required this.record});

  static const _statusColors = {
    'PRESENT': Color(0xFF2E7D32),
    'ABSENT': Color(0xFFBA1A1A),
    'LATE': Color(0xFFE65100),
    'EXCUSED': Color(0xFF1565C0),
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = _statusColors[record.status] ?? const Color(0xFF777682);
    final d = record.date;
    final label = '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: textTheme.bodyMedium)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              record.status,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty / Error States ──────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No children linked to your account',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Failed to load children', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
