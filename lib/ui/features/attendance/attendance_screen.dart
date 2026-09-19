import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smp_mobile/data/models/attendance_model.dart';
import 'attendance_provider.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    context.read<AttendanceProvider>().load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        title: Text('Attendance', style: theme.textTheme.headlineSmall),
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(provider.error!, style: TextStyle(color: cs.error)),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _load, child: const Text('Retry')),
                ],
              ),
            );
          }
          return CustomScrollView(
            slivers: [
          if (provider.children.length > 1)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 48,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: provider.children.map((child) {
                        final selected = provider.selectedChild?.id == child.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(child.displayName),
                            selected: selected,
                            onSelected: (_) => provider.selectChild(child),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              if (provider.stats != null)
                SliverToBoxAdapter(
                  child: _StatsCard(stats: provider.stats!),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                sliver: provider.records.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 48),
                            child: Text('No attendance records found.'),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) =>
                              _RecordTile(record: provider.records[i]),
                          childCount: provider.records.length,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final AttendanceStats stats;
  const _StatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${stats.attendanceRate.toStringAsFixed(1)}%',
              style: tt.headlineLarge?.copyWith(
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Attendance rate this year',
              style: tt.bodyMedium?.copyWith(color: cs.onPrimaryContainer),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatPill(label: 'Present', value: stats.present, color: Colors.green),
                _StatPill(label: 'Absent', value: stats.absent, color: cs.error),
                _StatPill(label: 'Late', value: stats.late, color: Colors.orange),
                _StatPill(label: 'Excused', value: stats.excused, color: Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatPill({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color),
        ),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

class _RecordTile extends StatelessWidget {
  final AttendanceRecord record;
  const _RecordTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final (color, icon) = switch (record.status) {
      'PRESENT' => (Colors.green, Icons.check_circle),
      'ABSENT'  => (cs.error, Icons.cancel),
      'LATE'    => (Colors.orange, Icons.watch_later),
      _         => (Colors.blue, Icons.info),
    };

    final date = record.date;
    final label =
        '${date.day.toString().padLeft(2, '0')} ${_month(date.month)} ${date.year}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                record.status,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _month(int m) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m];
}
