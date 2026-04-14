import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:complaints/core/utils/realtime_list_stream_replay.dart';
import 'package:complaints/features/shared/complaints/models/complaint_model.dart';

/// Admin summary statistics.
class AdminDashboardStats {
  const AdminDashboardStats({
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

// ── Realtime Stream from Supabase ───────────────────────────────────────

final adminRawComplaintsProvider = StreamProvider<List<ComplaintModel>>((ref) {
  final source = Supabase.instance.client
      .from('complaints')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false)
      .map((data) => data.map((e) => ComplaintModel.fromJson(e)).toList());
  return replayLastListOnStreamError(source);
});

// ── Stats derived from realtime data ────────────────────────────────────

final adminDashboardStatsProvider = Provider<AsyncValue<AdminDashboardStats>>((ref) {
  final asyncData = ref.watch(adminRawComplaintsProvider);

  return asyncData.when(
    skipError: true,
    skipLoadingOnReload: true,
    skipLoadingOnRefresh: true,
    data: (complaints) => AsyncData(
      AdminDashboardStats(
        total: complaints.length,
        pending:
            complaints.where((c) => c.status == ComplaintStatus.pending).length,
        inProgress: complaints
            .where((c) => c.status == ComplaintStatus.inProgress)
            .length,
        resolved:
            complaints.where((c) => c.status == ComplaintStatus.resolved).length,
      ),
    ),
    loading: () => const AsyncLoading(),
    error: (_, _) => const AsyncLoading(),
  );
});

// ── Recent 5 complaints derived from realtime data ──────────────────────

final adminRecentComplaintsProvider = Provider<AsyncValue<List<ComplaintModel>>>((ref) {
  final asyncData = ref.watch(adminRawComplaintsProvider);
  return asyncData.when(
    skipError: true,
    skipLoadingOnReload: true,
    skipLoadingOnRefresh: true,
    data: (complaints) => AsyncData(complaints.take(5).toList()),
    loading: () => const AsyncLoading(),
    error: (_, _) => const AsyncLoading(),
  );
});
