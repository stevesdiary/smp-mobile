import 'package:flutter/material.dart';
import '../../../data/models/academic_models.dart';
import '../../../data/repositories/parent_repository.dart';

class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  late Future<List<FeeSummary>> _future;

  @override
  void initState() {
    super.initState();
    _future = parentRepository.getFeeSummaries();
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
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text('Fees', style: textTheme.headlineMedium),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: FutureBuilder<List<FeeSummary>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
                  }
                  if (snapshot.hasError) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Failed to load fees', style: textTheme.bodyMedium),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => setState(() { _future = parentRepository.getFeeSummaries(); }),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final summaries = snapshot.data ?? [];
                  if (summaries.isEmpty) {
                    return const SliverFillRemaining(child: Center(child: Text('No fee records found.')));
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _ChildFeeCard(summary: summaries[i]),
                      childCount: summaries.length,
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

class _ChildFeeCard extends StatelessWidget {
  final FeeSummary summary;
  const _ChildFeeCard({required this.summary});

  String _fmt(double amount, String currency) =>
      '$currency ${amount.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final hasOutstanding = summary.outstanding > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8E8E93).withValues(alpha: 0.2), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFF0F0FF),
                  child: Text(
                    summary.studentName.isNotEmpty ? summary.studentName[0] : '?',
                    style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(summary.studentName, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                ),
                if (hasOutstanding)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBA1A1A).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Outstanding',
                      style: textTheme.labelMedium?.copyWith(color: const Color(0xFFBA1A1A), fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),

          // Summary row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _SummaryPill(label: 'Total', amount: summary.total, currency: summary.assignments.isNotEmpty ? summary.assignments.first.currency : 'NGN', color: colorScheme.primary),
                const SizedBox(width: 12),
                _SummaryPill(label: 'Paid', amount: summary.paid, currency: summary.assignments.isNotEmpty ? summary.assignments.first.currency : 'NGN', color: const Color(0xFF2E7D32)),
                const SizedBox(width: 12),
                _SummaryPill(label: 'Due', amount: summary.outstanding, currency: summary.assignments.isNotEmpty ? summary.assignments.first.currency : 'NGN', color: const Color(0xFFBA1A1A)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFC7C5D3)),

          // Fee items
          ...summary.assignments.map((a) => _FeeItem(assignment: a)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final double amount;
  final String currency;
  final Color color;
  const _SummaryPill({required this.label, required this.amount, required this.currency, required this.color});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(label, style: textTheme.bodySmall?.copyWith(color: color)),
            const SizedBox(height: 2),
            Text(
              '$currency ${amount.toStringAsFixed(0)}',
              style: textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeeItem extends StatelessWidget {
  final FeeAssignment assignment;
  const _FeeItem({required this.assignment});

  static const _statusColors = {
    'PAID': Color(0xFF2E7D32),
    'UNPAID': Color(0xFFBA1A1A),
    'PARTIAL': Color(0xFFE65100),
    'OVERDUE': Color(0xFFBA1A1A),
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = _statusColors[assignment.status] ?? const Color(0xFF777682);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(assignment.feeName, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                Text(assignment.category, style: textTheme.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${assignment.currency} ${assignment.totalAmount.toStringAsFixed(0)}',
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  assignment.status,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
