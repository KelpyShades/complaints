import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:complaints/core/push_notifications/notification_service.dart';
import '../../providers/report_provider.dart';
import '../../utils/excel_exporter.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key, this.showHeaderExport = true});

  /// When false (e.g. mobile shell with FAB), hide the header export button.
  final bool showHeaderExport;

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isExporting = false;

  void _updateDates(DateTime? start, DateTime? end) {
    setState(() {
      _startDate = start;
      _endDate = end;
    });
    ref.read(reportProvider.notifier).setDateRange(start, end);
  }

  Future<void> _export() async {
    final data = ref.read(filteredReportDataProvider);
    if (data.isEmpty) {
      NotificationService.showError(context, 'No data to export for this date range.');
      return;
    }

    setState(() => _isExporting = true);
    final success = await ExcelExporter.export(data);
    setState(() => _isExporting = false);

    if (success && mounted) {
      NotificationService.showSuccess(context, 'Report generated successfully.');
    }
  }

  void _clearDates() {
    _updateDates(null, null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final data = ref.watch(filteredReportDataProvider);
    final total = data.length;
    final resolved = data.where((c) => c.status.name == 'resolved').length;
    final pending = data.where((c) => c.status.name == 'pending').length;
    
    // Calculate category breakdown
    final categoryCounts = <String, int>{};
    for (var c in data) {
      categoryCounts[c.category] = (categoryCounts[c.category] ?? 0) + 1;
    }

    return Material(
      color: theme.colorScheme.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('System Reports', style: theme.textTheme.h3),
                if (widget.showHeaderExport)
                  ShadButton(
                    onPressed: _isExporting ? null : _export,
                    size: ShadButtonSize.sm,
                    leading: _isExporting
                        ? const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: SizedBox.square(
                              dimension: 14,
                              child: ShadProgress(),
                            ),
                          )
                        : const Icon(LucideIcons.download, size: 16),
                    child: Text(_isExporting ? 'Exporting...' : 'Export Excel'),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Filters Panel
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.card,
                border: Border.all(color: theme.colorScheme.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filters', style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w600)),
                      if (_startDate != null || _endDate != null)
                        ShadButton.ghost(
                          size: ShadButtonSize.sm,
                          onPressed: _clearDates,
                          child: const Text('Clear Filters'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ActionChip(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _startDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) _updateDates(date, _endDate);
                        },
                        label: Text(_startDate != null ? '${_startDate!.year}-${_startDate!.month}-${_startDate!.day}' : 'Start Date'),
                        avatar: const Icon(LucideIcons.calendar, size: 16),
                      ),
                      const Text('to'),
                      ActionChip(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _endDate ?? DateTime.now(),
                            firstDate: _startDate ?? DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) _updateDates(_startDate, date);
                        },
                        label: Text(_endDate != null ? '${_endDate!.year}-${_endDate!.month}-${_endDate!.day}' : 'End Date'),
                        avatar: const Icon(LucideIcons.calendar, size: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Summary Metrics
            Text('Selected Period Summary', style: theme.textTheme.h4),
            const SizedBox(height: 16),
            
            GridView.count(
              crossAxisCount: MediaQuery.sizeOf(context).width > 800 ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2,
              children: [
                _MetricCard(title: 'Total Logged', value: total.toString()),
                _MetricCard(title: 'Resolved', value: resolved.toString(), color: Colors.green),
                _MetricCard(title: 'Pending', value: pending.toString(), color: Colors.orange),
                _MetricCard(
                  title: 'Resolution Rate', 
                  value: total > 0 ? '${((resolved / total) * 100).toStringAsFixed(1)}%' : '0%',
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            Text('Category Breakdown', style: theme.textTheme.h4),
            const SizedBox(height: 16),
            
            if (categoryCounts.isEmpty)
              Text('No data available.', style: theme.textTheme.muted)
            else
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: categoryCounts.entries.map((e) {
                  return Container(
                    width: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.card,
                      border: Border.all(color: theme.colorScheme.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(e.key, style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w600)),
                         const SizedBox(height: 8),
                         Text('${e.value} requests', style: theme.textTheme.h3),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value, this.color});
  
  final String title;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        border: Border.all(color: theme.colorScheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: theme.textTheme.small.copyWith(color: theme.colorScheme.mutedForeground)),
          const Spacer(),
          Text(value, style: theme.textTheme.h3.copyWith(color: color)),
        ],
      ),
    );
  }
}
