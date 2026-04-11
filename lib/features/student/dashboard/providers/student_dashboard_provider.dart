import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:complaints/features/complaints/models/complaint_model.dart';
import 'package:complaints/features/auth/providers/auth_provider.dart';

// ── Student Realtime Stream ────────────────────────────────────────────

final studentRawComplaintsProvider = StreamProvider<List<ComplaintModel>>((ref) {
  // Students ONLY see their own.
  // We reuse the stream but filter it at the source query level.
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const Stream.empty();

  return Supabase.instance.client
      .from('complaints')
      .stream(primaryKey: ['id'])
      .eq('user_id', userId)
      .order('created_at', ascending: false)
      .map((data) => data.map((e) => ComplaintModel.fromJson(e)).toList());
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

final studentDashboardStatsProvider = Provider<AsyncValue<StudentDashboardStats>>((ref) {
  final asyncData = ref.watch(studentRawComplaintsProvider);
  
  return asyncData.whenData((complaints) {
    return StudentDashboardStats(
      total: complaints.length,
      pending: complaints.where((c) => c.status == ComplaintStatus.pending).length,
      inProgress: complaints.where((c) => c.status == ComplaintStatus.inProgress).length,
      resolved: complaints.where((c) => c.status == ComplaintStatus.resolved).length,
    );
  });
});

final studentRecentComplaintsProvider = Provider<AsyncValue<List<ComplaintModel>>>((ref) {
  final asyncData = ref.watch(studentRawComplaintsProvider);
  return asyncData.whenData((complaints) => complaints.take(3).toList());
});
