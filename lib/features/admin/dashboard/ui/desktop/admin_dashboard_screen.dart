import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:complaints/core/push_notifications/notification_service.dart';
import 'package:complaints/core/router/app_router.dart';
import 'package:complaints/core/widgets/async_value_widget.dart';
import 'package:complaints/features/admin/dashboard/providers/admin_dashboard_provider.dart';
import 'package:complaints/features/admin/reports/providers/report_provider.dart';
import 'package:complaints/features/admin/reports/utils/excel_exporter.dart';
import 'package:complaints/features/auth/providers/auth_provider.dart';
import 'package:complaints/features/shared/complaints/models/complaint_model.dart';
import 'package:complaints/features/shared/complaints/ui/widgets/complaint_card.dart';
import 'package:complaints/features/shared/complaints/ui/widgets/dashboard_stat_cards.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  bool _isExporting = false;

  Future<void> _export() async {
    final data = ref.read(filteredReportDataProvider);
    if (data.isEmpty) {
      NotificationService.showError(
        context,
        'No data to export.',
      );
      return;
    }

    setState(() => _isExporting = true);
    final success = await ExcelExporter.export(data);
    setState(() => _isExporting = false);

    if (success && mounted) {
      NotificationService.showSuccess(
        context,
        'Report generated successfully.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final statsAsync = ref.watch(adminDashboardStatsProvider);
    final rawAsync = ref.watch(adminRawComplaintsProvider);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: DashboardWelcomeBlock(
                  theme: theme,
                  name: currentUser?.fullName ?? 'Admin',
                ),
              ),
              ShadButton(
                onPressed: _isExporting ? null : _export,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _isExporting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(LucideIcons.fileSpreadsheet, size: 16),
                    const SizedBox(width: 8),
                    const Text('Export to Excel'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          AsyncValueWidget<AdminDashboardStats>(
            value: statsAsync,
            onRetry: () => ref.invalidate(adminRawComplaintsProvider),
            data: (stats) {
              final open = stats.pending + stats.inProgress;
              return SizedBox(
                height: 180,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 2,
                      child: DashboardBentoHeroTotalCard(
                        theme: theme,
                        total: stats.total,
                        caption: 'Across the system',
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 1,
                      child: DashboardBentoAccentStatCard(
                        theme: theme,
                        label: 'Resolved',
                        value: stats.resolved,
                        icon: LucideIcons.circleCheck,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 1,
                      child: DashboardBentoSurfaceStatCard(
                        theme: theme,
                        label: 'Open',
                        caption: 'Pending & in progress',
                        value: open,
                        icon: LucideIcons.clock,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
              'RECENT',
              style: theme.textTheme.small.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                letterSpacing: 1.05,
                color: theme.colorScheme.mutedForeground,
              ),
            ),
          ),
          const SizedBox(height: 16),
          AsyncValueWidget<List<ComplaintModel>>(
            value: rawAsync,
            onRetry: () => ref.invalidate(adminRawComplaintsProvider),
            data: (complaints) {
              final recent = complaints.take(5).toList();
              if (recent.isEmpty) {
                return DashboardRecentEmptyState(
                  theme: theme,
                  message: 'When students submit one, it will show up here.',
                );
              }
              return Column(
                children: [
                  for (var i = 0; i < recent.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    ComplaintCard(
                      complaint: recent[i],
                      onTap: () => context.go(
                        AppRoutes.adminComplaintDetailPath(recent[i].id),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
