import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/providers/auth_provider.dart';
import '../models/complaint_model.dart';
import '../repositories/complaint_repository.dart';

// ── Repository ─────────────────────────────────────────────────────────

final complaintRepositoryProvider = Provider<ComplaintRepository>((ref) {
  return ComplaintRepository(Supabase.instance.client);
});

// ── Filter state ───────────────────────────────────────────────────────

final complaintStatusFilterProvider = StateProvider<ComplaintStatus?>((ref) {
  return null;
});

// ── Realtime complaint list ────────────────────────────────────────────

final complaintListProvider =
    StreamProvider<List<ComplaintModel>>((ref) {
  final repo = ref.watch(complaintRepositoryProvider);
  return repo.watchComplaints();
});

/// Filtered view of the complaint list.
///
/// - Students: see only their own complaints.
/// - Admins: see all complaints.
/// Applies optional status filter on top.
final filteredComplaintsProvider =
    Provider<AsyncValue<List<ComplaintModel>>>((ref) {
  final complaintsAsync = ref.watch(complaintListProvider);
  final statusFilter = ref.watch(complaintStatusFilterProvider);
  final isAdmin = ref.watch(isAdminProvider);
  final currentUserId = ref.watch(currentUserIdProvider);

  return complaintsAsync.when(
    data: (complaints) {
      var filtered = complaints;

      // Students only see their own complaints
      if (!isAdmin && currentUserId != null) {
        filtered =
            filtered.where((c) => c.userId == currentUserId).toList();
      }

      if (statusFilter != null) {
        filtered = filtered.where((c) => c.status == statusFilter).toList();
      }

      return AsyncData(filtered);
    },
    loading: () => const AsyncLoading(),
    error: (e, st) => AsyncError(e, st),
  );
});
