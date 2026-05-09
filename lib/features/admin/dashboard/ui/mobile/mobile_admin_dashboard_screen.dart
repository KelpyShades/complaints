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

/// Mirrors [MobileStudentComplaintsScreen] — bento stats + recent [ComplaintCard] list.
class MobileAdminDashboardScreen extends ConsumerStatefulWidget {
  const MobileAdminDashboardScreen({super.key});

  @override
  ConsumerState<MobileAdminDashboardScreen> createState() =>
      _MobileAdminDashboardScreenState();
}

class _MobileAdminDashboardScreenState
    extends ConsumerState<MobileAdminDashboardScreen> {
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
    final bottomFabClearance = MediaQuery.viewPaddingOf(context).bottom + 88;

    return ColoredBox(
      color: theme.colorScheme.background,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, bottomFabClearance),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DashboardWelcomeBlock(
                      theme: theme,
                      name: currentUser?.fullName ?? 'Admin',
                    ),
                    const SizedBox(height: 28),
                    AsyncValueWidget<AdminDashboardStats>(
                      value: statsAsync,
                      onRetry: () => ref.invalidate(adminRawComplaintsProvider),
                      data: (stats) {
                        final open = stats.pending + stats.inProgress;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            DashboardBentoHeroTotalCard(theme: theme, total: stats.total),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 158,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: DashboardBentoAccentStatCard(
                                      theme: theme,
                                      label: 'Resolved',
                                      value: stats.resolved,
                                      icon: LucideIcons.circleCheck,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
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
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),
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
                    const SizedBox(height: 12),
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
                              if (i > 0) const SizedBox(height: 10),
                              ComplaintCard(
                                complaint: recent[i],
                                onTap: () => context.go(
                                  AppRoutes.adminComplaintDetailPath(
                                    recent[i].id,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 18,
            bottom: 18 + MediaQuery.viewPaddingOf(context).bottom,
            child: FloatingActionButton(
              onPressed: _isExporting ? null : _export,
              backgroundColor: theme.colorScheme.primary,
              tooltip: 'Export to Excel',
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: _isExporting
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: theme.colorScheme.primaryForeground,
                      ),
                    )
                  : Icon(
                      LucideIcons.fileSpreadsheet,
                      color: theme.colorScheme.primaryForeground,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}


