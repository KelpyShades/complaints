import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'admin_adaptive_screens.dart';
import '../../features/auth/ui/screens/forgot_password_screen.dart';
import '../../features/auth/ui/screens/login_screen.dart';
import '../../features/auth/ui/screens/register_screen.dart';
import 'admin_shell.dart';
import 'auth_guard.dart';
import 'student_adaptive_screens.dart';
import 'student_shell.dart';

/// Route path constants for the entire app.
abstract final class AppRoutes {
  // ── Public ──────────────────────────────────────────────────────────────
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';

  // ── Admin ───────────────────────────────────────────────────────────────
  static const adminRoot = '/admin';
  static const adminDashboard = '/admin/dashboard';
  static const adminComplaints = '/admin/complaints';
  static const adminComplaintDetail = '/admin/complaints/:id';
  static const adminNotifications = '/admin/notifications';
  static const adminReports = '/admin/reports';
  static const adminProfile = '/admin/profile';

  // ── Student ─────────────────────────────────────────────────────────────
  static const studentRoot = '/student';
  static const studentComplaints = '/student/complaints';
  static const studentHistory = '/student/history';
  static const studentProfile = '/student/profile';
  static const studentComplaintDetail = '/student/complaints/:id';
  static const studentComplaintNew = '/student/complaints/new';
  static const studentNotifications = '/student/notifications';

  // ── Helpers ─────────────────────────────────────────────────────────────
  static String adminComplaintDetailPath(String id) => '/admin/complaints/$id';
  static String studentComplaintDetailPath(String id) =>
      '/student/complaints/$id';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authGuard = AuthGuard();

  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: authGuard,
    redirect: authGuard.redirect,
    routes: [
      // ── Root redirect ──────────────────────────────────────────────────
      GoRoute(path: '/', redirect: (_, _) => AppRoutes.login),

      // ── Auth routes (no shell) ─────────────────────────────────────────
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, _) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, _) => const ForgotPasswordScreen(),
      ),

      // ── Admin routes ──────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) =>
            AdminShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.adminDashboard,
            builder: (_, _) => const AdminDashboardRouteBody(),
          ),
          GoRoute(
            path: AppRoutes.adminComplaints,
            builder: (_, _) => const AdminComplaintsRouteBody(),
          ),
          GoRoute(
            path: AppRoutes.adminComplaintDetail,
            builder: (_, state) => AdminComplaintDetailRouteBody(
              complaintId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: AppRoutes.adminNotifications,
            builder: (_, _) => const AdminActivityRouteBody(),
          ),
          GoRoute(
            path: AppRoutes.adminReports,
            builder: (_, _) => const AdminReportsRouteBody(),
          ),
          GoRoute(
            path: AppRoutes.adminProfile,
            builder: (_, _) => const AdminProfileRouteBody(),
          ),
        ],
      ),

      // ── Student routes (same paths; [StudentShell] + builders pick UI) ─
      ShellRoute(
        builder: (context, state, child) =>
            StudentShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.studentComplaintNew,
            builder: (_, _) => const StudentComplaintFormRouteBody(),
          ),
          GoRoute(
            path: AppRoutes.studentComplaints,
            builder: (_, _) => const StudentComplaintsRouteBody(),
          ),
          GoRoute(
            path: AppRoutes.studentHistory,
            builder: (_, _) => const StudentHistoryRouteBody(),
          ),
          GoRoute(
            path: AppRoutes.studentProfile,
            builder: (_, _) => const StudentProfileRouteBody(),
          ),
          GoRoute(
            path: AppRoutes.studentComplaintDetail,
            builder: (_, state) => StudentComplaintDetailRouteBody(
              complaintId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: AppRoutes.studentNotifications,
            builder: (_, _) => const StudentActivityRouteBody(),
          ),
        ],
      ),
    ],
  );
});
