import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/providers/auth_provider.dart';
import '../models/activity_model.dart';
import '../repositories/activity_repository.dart';

// ── Repository ─────────────────────────────────────────────────────────

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepository(Supabase.instance.client);
});

// ── Realtime Stream ────────────────────────────────────────────────────

final activityListProvider = StreamProvider<List<ActivityModel>>((ref) {
  final repo = ref.watch(activityRepositoryProvider);
  return repo.watchActivities();
});

// ── Unread Badge Count ─────────────────────────────────────────────────

/// Evaluates the unread count from the current activities stream.
/// Shows all unread for students, and for admins it benchmarks against local last-seen.
final unreadActivityCountProvider = Provider<int>((ref) {
  final activitiesAsync = ref.watch(activityListProvider);
  final user = ref.watch(currentUserProvider).valueOrNull;

  if (user == null) return 0;

  final isAdmin = user.role == 'admin';

  return activitiesAsync.maybeWhen(
    data: (activities) {
      if (isAdmin) {
        final lastSeen = user.lastSeenActivitiesAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return activities.where((a) => (a.createdAt ?? DateTime.now()).isAfter(lastSeen)).length;
      }
      return activities.where((a) => a.readAt == null).length;
    },
    orElse: () => 0,
  );
});

// ── Mark Read Action ───────────────────────────────────────────────────

final markNotificationsReadProvider = Provider((ref) {
  return () async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    final repo = ref.read(activityRepositoryProvider);
    if (user.role == 'admin') {
      await repo.updateLastSeenActivities(user.id);
      // Refresh current user to update the last_seen_activities_at field locally
      ref.invalidate(currentUserProvider);
    } else {
      await repo.markAllAsRead(user.id);
    }
  };
});
