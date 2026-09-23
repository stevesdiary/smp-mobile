import 'package:flutter/material.dart';
import '../../../data/models/child_model.dart';
import '../../../data/models/academic_models.dart';
import '../../../data/repositories/parent_repository.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  List<Child> _children = [];
  Child? _selected;
  Map<int, List<TimetableEntry>> _byDay = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    try {
      final children = await parentRepository.getChildren();
      setState(() {
        _children = children;
        _selected = children.isNotEmpty ? children.first : null;
      });
      if (_selected != null) await _loadTimetable(_selected!.id);
    } catch (_) {
      setState(() { _error = 'Failed to load data.'; _loading = false; });
    }
  }

  Future<void> _loadTimetable(String studentId) async {
    setState(() { _loading = true; _error = null; });
    try {
      final entries = await parentRepository.getChildTimetable(studentId);
      final map = <int, List<TimetableEntry>>{};
      for (final e in entries) {
        map.putIfAbsent(e.dayOfWeek, () => []).add(e);
      }
      setState(() { _byDay = map; });
    } catch (_) {
      setState(() { _error = 'Failed to load timetable.'; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              backgroundColor: theme.scaffoldBackgroundColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text('Timetable', style: textTheme.headlineMedium),
            ),

            if (_children.length > 1)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: _children.map((child) {
                      final selected = _selected?.id == child.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(child.displayName),
                          selected: selected,
                          onSelected: (_) {
                            setState(() => _selected = child);
                            _loadTimetable(child.id);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

            if (_loading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, style: TextStyle(color: colorScheme.error)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => _selected != null ? _loadTimetable(_selected!.id) : _loadChildren(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_byDay.isEmpty)
              const SliverFillRemaining(child: Center(child: Text('No timetable found.')))
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final day = _byDay.keys.toList()..sort();
                      final d = day[i];
                      return _DaySection(day: d, entries: _byDay[d]!);
                    },
                    childCount: _byDay.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  final int day;
  final List<TimetableEntry> entries;
  const _DaySection({required this.day, required this.entries});

  static const _days = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _days[day],
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ...entries.map((e) => _EntryTile(entry: e)),
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  final TimetableEntry entry;
  const _EntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF8E8E93).withValues(alpha: 0.2), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${entry.startTime}\n${entry.endTime}',
              textAlign: TextAlign.center,
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.subjectName, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                if (entry.room != null)
                  Text(entry.room!, style: textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
