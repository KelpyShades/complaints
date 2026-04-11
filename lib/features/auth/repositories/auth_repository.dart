import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/app_exception.dart' as app;
import '../../../core/error/error_handler.dart';
import '../models/user_model.dart';

/// Handles all Supabase auth operations and profile management.
class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  /// Signs in with email and password.
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final userId = response.user?.id;
      if (userId == null) {
        throw const app.AuthException(
          message: 'Sign in failed. Please try again.',
        );
      }

      return _fetchProfile(userId);
    } catch (e, st) {
      throw ErrorHandler.handle(e, st);
    }
  }

  /// Creates a new account with email, password, and full name.
  ///
  /// The `full_name` is passed via user metadata so the database
  /// trigger (`handle_new_user`) can read it and create the profile.
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      final userId = response.user?.id;
      if (userId == null) {
        throw const app.AuthException(
          message: 'Sign up failed. Please try again.',
        );
      }

      return _fetchProfile(userId);
    } catch (e, st) {
      throw ErrorHandler.handle(e, st);
    }
  }

  /// Signs the user out.
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e, st) {
      throw ErrorHandler.handle(e, st);
    }
  }

  /// Sends a password reset email.
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e, st) {
      throw ErrorHandler.handle(e, st);
    }
  }

  /// Returns the current user's profile, or `null` if not signed in.
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;
      return _fetchProfile(user.id);
    } catch (e, st) {
      throw ErrorHandler.handle(e, st);
    }
  }

  /// Streams auth state changes from Supabase.
  Stream<AuthState> watchAuthState() {
    return _client.auth.onAuthStateChange;
  }

  /// Returns the current session synchronously (can be null).
  Session? get currentSession => _client.auth.currentSession;

  // ── Private ──────────────────────────────────────────────────────────

  Future<UserModel> _fetchProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return UserModel.fromJson(data);
  }
}
