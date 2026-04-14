import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:complaints/core/router/app_router.dart';
import 'package:complaints/features/admin/complaints/ui/desktop/admin_complaint_detail_screen.dart';
import 'package:complaints/features/admin/complaints/ui/desktop/admin_complaints_screen.dart';
import 'package:complaints/features/admin/complaints/ui/mobile/mobile_admin_complaints_screen.dart';
import 'package:complaints/features/admin/dashboard/ui/desktop/admin_dashboard_screen.dart';
import 'package:complaints/features/admin/dashboard/ui/mobile/mobile_admin_dashboard_screen.dart';
import 'package:complaints/features/admin/notifications/ui/desktop/admin_activity_screen.dart';
import 'package:complaints/features/admin/notifications/ui/mobile/mobile_admin_activity_screen.dart';
import 'package:complaints/features/admin/profile/ui/mobile/mobile_admin_profile_screen.dart';
import 'package:complaints/features/admin/reports/ui/desktop/reports_screen.dart';

/// Must match [AdminShell] layout split.
const double kAdminShellMobileBreakpoint = 768;

bool adminShellIsMobileLayout(BuildContext context) =>
    MediaQuery.sizeOf(context).width < kAdminShellMobileBreakpoint;

class AdminDashboardRouteBody extends StatelessWidget {
  const AdminDashboardRouteBody({super.key});

  @override
  Widget build(BuildContext context) {
    return adminShellIsMobileLayout(context)
        ? const MobileAdminDashboardScreen()
        : const AdminDashboardScreen();
  }
}

class AdminComplaintsRouteBody extends StatelessWidget {
  const AdminComplaintsRouteBody({super.key});

  @override
  Widget build(BuildContext context) {
    return adminShellIsMobileLayout(context)
        ? const MobileAdminComplaintsScreen()
        : const AdminComplaintsScreen();
  }
}

class AdminActivityRouteBody extends StatelessWidget {
  const AdminActivityRouteBody({super.key});

  @override
  Widget build(BuildContext context) {
    return adminShellIsMobileLayout(context)
        ? const MobileAdminActivityScreen()
        : const AdminActivityScreen();
  }
}

class AdminReportsRouteBody extends StatelessWidget {
  const AdminReportsRouteBody({super.key});

  @override
  Widget build(BuildContext context) {
    if (adminShellIsMobileLayout(context)) {
      return const _AdminReportsMobileRedirect();
    }
    return const ReportsScreen();
  }
}

/// Reports are desktop-only; mobile admins export from the dashboard FAB.
class _AdminReportsMobileRedirect extends StatefulWidget {
  const _AdminReportsMobileRedirect();

  @override
  State<_AdminReportsMobileRedirect> createState() =>
      _AdminReportsMobileRedirectState();
}

class _AdminReportsMobileRedirectState extends State<_AdminReportsMobileRedirect> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.go(AppRoutes.adminDashboard);
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class AdminProfileRouteBody extends StatelessWidget {
  const AdminProfileRouteBody({super.key});

  @override
  Widget build(BuildContext context) {
    if (adminShellIsMobileLayout(context)) {
      return const MobileAdminProfileScreen();
    }
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: const MobileAdminProfileScreen(),
      ),
    );
  }
}

class AdminComplaintDetailRouteBody extends StatelessWidget {
  const AdminComplaintDetailRouteBody({required this.complaintId, super.key});

  final String complaintId;

  @override
  Widget build(BuildContext context) {
    return AdminComplaintDetailScreen(complaintId: complaintId);
  }
}
