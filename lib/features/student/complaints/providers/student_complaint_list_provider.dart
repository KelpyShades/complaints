import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:complaints/core/utils/realtime_list_stream_replay.dart';
import 'package:complaints/features/auth/providers/auth_provider.dart';
import 'package:complaints/features/shared/complaints/models/complaint_model.dart';

// ── Student Realtime Stream ────────────────────────────────────────────

/// Live complaints for the signed-in student.
///
/// Replays the last successful snapshot when the realtime channel errors.
final studentRawComplaintsProvider = StreamProvider<List<ComplaintModel>>((
  ref,
) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return Stream.value(const <ComplaintModel>[]);
  }

  final source = Supabase.instance.client
      .from('complaints')
      .stream(primaryKey: ['id'])
      .eq('user_id', userId)
      .order('created_at', ascending: false)
      .map((rows) => rows.map((e) => ComplaintModel.fromJson(e)).toList());

  return replayLastListOnStreamError(source);
});

// ── Stats derived from realtime data ────────────────────────────────────

/// Minimal stats structure for the student dashboard.
class StudentDashboardStats {
  const StudentDashboardStats({
    required this.total,
    required this.pending,
    required this.inProgress,
    required this.resolved,
  });

  final int total;
  final int pending;
  final int inProgress;
  final int resolved;
}

final studentDashboardStatsProvider =
    Provider<AsyncValue<StudentDashboardStats>>((ref) {
  final asyncData = ref.watch(studentRawComplaintsProvider);

  return asyncData.when(
    skipError: true,
    skipLoadingOnReload: true,
    skipLoadingOnRefresh: true,
    data: (complaints) => AsyncData(
      StudentDashboardStats(
        total: complaints.length,
        pending: complaints
            .where((c) => c.status == ComplaintStatus.pending)
            .length,
        inProgress: complaints
            .where((c) => c.status == ComplaintStatus.inProgress)
            .length,
        resolved: complaints
            .where((c) => c.status == ComplaintStatus.resolved)
            .length,
      ),
    ),
    loading: () => const AsyncLoading(),
    error: (_, _) => const AsyncLoading(),
  );
});

final studentRecentComplaintsProvider =
    Provider<AsyncValue<List<ComplaintModel>>>((ref) {
  final asyncData = ref.watch(studentRawComplaintsProvider);
  return asyncData.when(
    skipError: true,
    skipLoadingOnReload: true,
    skipLoadingOnRefresh: true,
    data: (complaints) => AsyncData(complaints.take(3).toList()),
    loading: () => const AsyncLoading(),
    error: (_, _) => const AsyncLoading(),
  );
});

final studentComplaintStatusFilterProvider = StateProvider<ComplaintStatus?>(
  (ref) => null,
);

final studentFilteredComplaintsProvider =
    Provider<AsyncValue<List<ComplaintModel>>>((ref) {
  final complaintsAsync = ref.watch(studentRawComplaintsProvider);
  final statusFilter = ref.watch(studentComplaintStatusFilterProvider);

  return complaintsAsync.when(
    skipError: true,
    skipLoadingOnReload: true,
    skipLoadingOnRefresh: true,
    data: (complaints) {
      final activeOnes = complaints.where(
        (c) =>
            c.status == ComplaintStatus.pending ||
            c.status == ComplaintStatus.inProgress,
      );

      if (statusFilter != null) {
        return AsyncData(
          activeOnes.where((c) => c.status == statusFilter).toList(),
        );
      }
      return AsyncData(activeOnes.toList());
    },
    loading: () => const AsyncLoading(),
    error: (_, _) => const AsyncLoading(),
  );
});

final studentActiveComplaintsProvider =
    Provider<AsyncValue<List<ComplaintModel>>>((ref) {
  final complaintsAsync = ref.watch(studentRawComplaintsProvider);
  return complaintsAsync.when(
    skipError: true,
    skipLoadingOnReload: true,
    skipLoadingOnRefresh: true,
    data: (complaints) => AsyncData(
      complaints
          .where(
            (c) =>
                c.status == ComplaintStatus.pending ||
                c.status == ComplaintStatus.inProgress,
          )
          .toList(),
    ),
    loading: () => const AsyncLoading(),
    error: (_, _) => const AsyncLoading(),
  );
});

/// History tab filter: `null` means every status.
final studentHistoryStatusFilterProvider = StateProvider<ComplaintStatus?>(
  (ref) => null,
);

/// All complaints from the live stream, optionally narrowed by [studentHistoryStatusFilterProvider].
final studentFilteredHistoryComplaintsProvider =
    Provider<AsyncValue<List<ComplaintModel>>>((ref) {
  final complaintsAsync = ref.watch(studentRawComplaintsProvider);
  final statusFilter = ref.watch(studentHistoryStatusFilterProvider);

  return complaintsAsync.when(
    skipError: true,
    skipLoadingOnReload: true,
    skipLoadingOnRefresh: true,
    data: (complaints) {
      if (statusFilter == null) return AsyncData(complaints);
      return AsyncData(
        complaints.where((c) => c.status == statusFilter).toList(),
      );
    },
    loading: () => const AsyncLoading(),
    error: (_, _) => const AsyncLoading(),
  );
});
