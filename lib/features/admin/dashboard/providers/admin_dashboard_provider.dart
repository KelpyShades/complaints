import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:complaints/features/complaints/models/complaint_model.dart';

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
  // Admin sees all
  return Supabase.instance.client
      .from('complaints')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false)
      .map((data) => data.map((e) => ComplaintModel.fromJson(e)).toList());
});

// ── Stats derived from realtime data ────────────────────────────────────

final adminDashboardStatsProvider = Provider<AsyncValue<AdminDashboardStats>>((ref) {
  final asyncData = ref.watch(adminRawComplaintsProvider);
  
  return asyncData.whenData((complaints) {
    return AdminDashboardStats(
      total: complaints.length,
      pending: complaints.where((c) => c.status == ComplaintStatus.pending).length,
      inProgress: complaints.where((c) => c.status == ComplaintStatus.inProgress).length,
      resolved: complaints.where((c) => c.status == ComplaintStatus.resolved).length,
    );
  });
});

// ── Recent 5 complaints derived from realtime data ──────────────────────

final adminRecentComplaintsProvider = Provider<AsyncValue<List<ComplaintModel>>>((ref) {
  final asyncData = ref.watch(adminRawComplaintsProvider);
  return asyncData.whenData((complaints) => complaints.take(5).toList());
});
