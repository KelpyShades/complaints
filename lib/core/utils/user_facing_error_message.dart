import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Short, non-technical copy for UI surfaces (lists, banners, [ErrorView]).
String userFacingErrorMessage(Object error) {
  if (error is supabase.AuthException) {
    return 'Sign-in problem. Please try again.';
  }
  if (error is supabase.PostgrestException) {
    return 'Could not load data. Check your connection and try again.';
  }
  if (error is SocketException) {
    return 'You appear to be offline. Connect, then try again.';
  }
  final raw = error.toString();
  final lower = raw.toLowerCase();
  if (lower.contains('realtime') ||
      lower.contains('websocket') ||
      lower.contains('channel error')) {
    return 'Live updates paused. Your list should still show — pull to refresh or try again.';
  }
  if (lower.contains('jwt') || lower.contains('session')) {
    return 'Your session may have expired. Sign in again.';
  }
  return 'Something went wrong. Please try again.';
}
