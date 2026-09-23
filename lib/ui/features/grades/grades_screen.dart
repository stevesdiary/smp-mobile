import 'package:flutter/material.dart';
import '../../../data/models/child_model.dart';
import '../../../data/models/academic_models.dart';
import '../../../data/repositories/parent_repository.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  List<Child> _children = [];
  Child? _selected;
  List<GradeModel> _grades = [];
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
      if (_selected != null) await _loadGrades(_selected!.id);
    } catch (_) {
      setState(() { _error = 'Failed to load data.'; _loading = false; });
    }
  }

  Future<void> _loadGrades(String studentId) async {
    setState(() { _loading = true; _error = null; });
    try {
      final grades = await parentRepository.getChildGrades(studentId);
      setState(() { _grades = grades; });
    } catch (_) {
      setState(() { _error = 'Failed to load grades.'; });
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
              title: Text('Grades', style: textTheme.headlineMedium),
            ),

            // Child selector
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
                            _loadGrades(child.id);
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
                        onPressed: () => _selected != null ? _loadGrades(_selected!.id) : _loadChildren(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_grades.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('No grades found.')),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _GradeTile(grade: _grades[i]),
                    childCount: _grades.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GradeTile extends StatelessWidget {
  final GradeModel grade;
  const _GradeTile({required this.grade});

  Color _gradeColor(String letter) {
    switch (letter) {
      case 'A': return const Color(0xFF2E7D32);
      case 'B': return const Color(0xFF1565C0);
      case 'C': return const Color(0xFFE65100);
      case 'D': return const Color(0xFFF57F17);
      default:  return const Color(0xFFBA1A1A);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = _gradeColor(grade.letterGrade);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF8E8E93).withValues(alpha: 0.2), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              grade.letterGrade,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(grade.subjectName, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  '${grade.score.toStringAsFixed(0)} / ${grade.maxScore.toStringAsFixed(0)} · ${grade.percentage.toStringAsFixed(1)}%',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          _ProgressArc(percentage: grade.percentage / 100, color: color),
        ],
      ),
    );
  }
}

class _ProgressArc extends StatelessWidget {
  final double percentage;
  final Color color;
  const _ProgressArc({required this.percentage, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: CircularProgressIndicator(
        value: percentage,
        strokeWidth: 4,
        backgroundColor: color.withValues(alpha: 0.15),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
