import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/cache/role_cache.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

// ── Repository provider ────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(Supabase.instance.client);
});

// ── Auth state stream ──────────────────────────────────────────────────

final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).watchAuthState();
});

// ── Current user profile ───────────────────────────────────────────────

final currentUserProvider =
    AsyncNotifierProvider<CurrentUserNotifier, UserModel?>(
  CurrentUserNotifier.new,
);

class CurrentUserNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    ref.watch(authStateChangesProvider);
    return ref.read(authRepositoryProvider).getCurrentUser();
  }

  Future<void> refresh() async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).getCurrentUser(),
    );
  }
}

// ── Derived role helpers ───────────────────────────────────────────────

/// Whether the current user is an admin.
///
/// Uses [RoleCache] as an immediate synchronous source while
/// [currentUserProvider] is still loading. This guarantees the
/// correct theme and shell are rendered on the very first frame.
final isAdminProvider = Provider<bool>((ref) {
  final asyncUser = ref.watch(currentUserProvider);
  if (asyncUser.hasValue) {
    return asyncUser.valueOrNull?.role == 'admin';
  }
  // While loading / on cold launch, use the pre-warmed cache.
  return RoleCache.load() == 'admin';
});

/// Current user's ID (null if not signed in).
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProvider).valueOrNull?.id;
});

// ── Sign in ────────────────────────────────────────────────────────────

final signInProvider =
    AutoDisposeAsyncNotifierProvider<SignInNotifier, void>(
  SignInNotifier.new,
);

class SignInNotifier extends AutoDisposeAsyncNotifier<void> {
  bool _mounted = true;

  @override
  FutureOr<void> build() {
    ref.onDispose(() => _mounted = false);
  }

  Future<bool> execute({
    required String email,
    required String password,
  }) async {
    if (state.isLoading) return false;
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() => ref.read(authRepositoryProvider).signIn(
          email: email,
          password: password,
        ));
    if (_mounted) state = result;
    return !result.hasError;
  }
}

// ── Sign up ────────────────────────────────────────────────────────────

final signUpProvider =
    AutoDisposeAsyncNotifierProvider<SignUpNotifier, void>(
  SignUpNotifier.new,
);

class SignUpNotifier extends AutoDisposeAsyncNotifier<void> {
  bool _mounted = true;

  @override
  FutureOr<void> build() {
    ref.onDispose(() => _mounted = false);
  }

  Future<bool> execute({
    required String email,
    required String password,
    required String fullName,
  }) async {
    if (state.isLoading) return false;
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() => ref.read(authRepositoryProvider).signUp(
          email: email,
          password: password,
          fullName: fullName,
        ));
    if (_mounted) state = result;
    return !result.hasError;
  }
}

// ── Reset password ─────────────────────────────────────────────────────

final resetPasswordProvider =
    AutoDisposeAsyncNotifierProvider<ResetPasswordNotifier, void>(
  ResetPasswordNotifier.new,
);

class ResetPasswordNotifier extends AutoDisposeAsyncNotifier<void> {
  bool _mounted = true;

  @override
  FutureOr<void> build() {
    ref.onDispose(() => _mounted = false);
  }

  Future<bool> execute(String email) async {
    if (state.isLoading) return false;
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() => ref.read(authRepositoryProvider).resetPassword(email));
    if (_mounted) state = result;
    return !result.hasError;
  }
}

// ── Sign out ───────────────────────────────────────────────────────────

final signOutProvider =
    AutoDisposeAsyncNotifierProvider<SignOutNotifier, void>(
  SignOutNotifier.new,
);

class SignOutNotifier extends AutoDisposeAsyncNotifier<void> {
  bool _mounted = true;

  @override
  FutureOr<void> build() {
    ref.onDispose(() => _mounted = false);
  }

  Future<void> execute() async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    // Clear cached role before signing out so the next user starts clean.
    await RoleCache.clear();
    final result = await AsyncValue.guard(() => ref.read(authRepositoryProvider).signOut());
    if (_mounted) state = result;
  }
}
