import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/realtime_list_stream_replay.dart';
import '../../../auth/providers/auth_provider.dart';
import '../models/activity_model.dart';
import '../repositories/activity_repository.dart';

// ── Repository ─────────────────────────────────────────────────────────

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepository(Supabase.instance.client);
});

// ── Realtime Stream ────────────────────────────────────────────────────

final activityListProvider = StreamProvider<List<ActivityModel>>((ref) {
  final repo = ref.watch(activityRepositoryProvider);
  return replayLastListOnStreamError(repo.watchActivities());
});

// ── Activity feed presence (badge cleared while this route is visible) ──

final activityFeedOnScreenProvider = StateProvider<bool>((ref) => false);

/// Whether an activity row should show "new" chrome, using [created_at] vs
/// profile [lastSeenActivitiesAt] (no per-row read flags).
bool activityAppearsUnread(
  ActivityModel activity,
  DateTime? lastSeenActivitiesAt, {
  required bool browsingFeed,
}) {
  if (browsingFeed) return false;
  final created = activity.createdAt;
  if (lastSeenActivitiesAt == null) return true;
  if (created == null) return false;
  return created.isAfter(lastSeenActivitiesAt);
}

/// Persists `profiles.last_seen_activities_at` to now (student + admin).
Future<void> persistActivityFeedLastSeen(
  WidgetRef ref,
  bool Function() isStillMounted,
) async {
  final user = ref.read(currentUserProvider).valueOrNull;
  if (user == null) return;
  await ref.read(activityRepositoryProvider).updateLastSeenActivities(user.id);
  if (!isStillMounted()) return;
  ref.invalidate(currentUserProvider);
}

/// Call from shell [didUpdateWidget] / first frame when [location] changes.
/// [activityRoutePrefix] is e.g. [AppRoutes.studentNotifications].
///
/// Updates are deferred with [Future.microtask] so we never write
/// [activityFeedOnScreenProvider] while Riverpod is still building dependents
/// (e.g. [unreadActivityCountProvider]) during the same layout pass.
void syncActivityFeedShellLocation(
  WidgetRef ref, {
  required String previousLocation,
  required String nextLocation,
  required String activityRoutePrefix,
  required bool Function() isStillMounted,
}) {
  final was = previousLocation.startsWith(activityRoutePrefix);
  final now = nextLocation.startsWith(activityRoutePrefix);
  if (!was && now) {
    Future.microtask(() {
      if (!isStillMounted()) return;
      ref.read(activityFeedOnScreenProvider.notifier).state = true;
    });
  } else if (was && !now) {
    Future.microtask(() {
      if (!isStillMounted()) return;
      ref.read(activityFeedOnScreenProvider.notifier).state = false;
      unawaited(persistActivityFeedLastSeen(ref, isStillMounted));
    });
  }
}

// ── Unread Badge Count ─────────────────────────────────────────────────

/// Counts activities with `created_at` after [UserModel.lastSeenActivitiesAt].
/// While the activity feed route is focused ([activityFeedOnScreenProvider]),
/// the badge is 0. If last-seen is null, every loaded activity counts.
final unreadActivityCountProvider = Provider<int>((ref) {
  final activitiesAsync = ref.watch(activityListProvider);
  final user = ref.watch(currentUserProvider).valueOrNull;
  final onFeed = ref.watch(activityFeedOnScreenProvider);

  if (user == null || onFeed) return 0;

  return activitiesAsync.when(
    skipError: true,
    skipLoadingOnReload: true,
    skipLoadingOnRefresh: true,
    data: (activities) {
      final lastSeen = user.lastSeenActivitiesAt;
      if (lastSeen == null) return activities.length;
      return activities
          .where(
            (a) =>
                (a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
                    .isAfter(lastSeen),
          )
          .length;
    },
    loading: () => 0,
    error: (_, _) => 0,
  );
});
