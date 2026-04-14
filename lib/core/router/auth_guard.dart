import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:complaints/features/auth/cache/role_cache.dart';
import 'app_router.dart';

/// Role-aware auth guard for GoRouter.
///
/// The [redirect] function is async — it resolves the user's role
/// BEFORE allowing navigation to any protected screen. On first launch
/// it fetches the profile from Supabase; on subsequent launches it reads
/// [RoleCache] synchronously. Either way the correct shell is shown on
/// the very first frame with no wrong-role flash.
class AuthGuard extends ChangeNotifier {
  AuthGuard() {
    _subscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (event) {
        if (event.event == AuthChangeEvent.signedOut) {
          RoleCache.clear();
        }
        notifyListeners();
      },
    );
  }

  late final StreamSubscription<AuthState> _subscription;

  static const _publicRoutes = [
    AppRoutes.login,
    AppRoutes.register,
    AppRoutes.forgotPassword,
  ];

  /// GoRouter redirect — FutureOr allows async role resolution.
  Future<String?> redirect(BuildContext context, GoRouterState state) async {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;
    final location = state.matchedLocation;
    final isOnPublicRoute = _publicRoutes.contains(location);

    // Not logged in → must stay on public routes.
    if (!isLoggedIn) {
      return isOnPublicRoute ? null : AppRoutes.login;
    }

    // Logged in → resolve role (sync when cached, async on first login).
    final role = await _resolveRole(session.user.id);
    final isAdmin = role == UserRole.admin;

    // Redirect from public/root pages to role-appropriate home.
    if (isOnPublicRoute || location == '/' || location == AppRoutes.adminRoot || location == AppRoutes.studentRoot) {
      return isAdmin ? AppRoutes.adminDashboard : AppRoutes.studentComplaints;
    }

    // Block cross-role access.
    if (isAdmin && location.startsWith('/student')) return AppRoutes.adminDashboard;
    if (!isAdmin && location.startsWith('/admin')) return AppRoutes.studentComplaints;

    return null; // Allow navigation.
  }

  /// Resolves role using cache when available; falls back to Supabase.
  Future<String> _resolveRole(String userId) async {
    final cached = RoleCache.load();
    if (cached != null) return cached;

    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .single();
      final role = (data['role'] as String?) ?? 'user';
      await RoleCache.save(role);
      return role;
    } catch (_) {
      return 'user'; // Safe default — never grants admin accidentally.
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Extracted role constants to avoid magic strings.
abstract final class UserRole {
  static const admin = 'admin';
  static const user = 'user';
}
