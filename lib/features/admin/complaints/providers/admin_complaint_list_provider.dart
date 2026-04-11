import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../complaints/models/complaint_model.dart';
import '../../dashboard/providers/admin_dashboard_provider.dart';

// ── Filter state ───────────────────────────────────────────────────────

final adminComplaintStatusFilterProvider = StateProvider<ComplaintStatus?>((ref) => null);
final adminComplaintSearchQueryProvider = StateProvider<String>((ref) => '');

// ── Filtered view ──────────────────────────────────────────────────────

final adminFilteredComplaintsProvider = Provider<AsyncValue<List<ComplaintModel>>>((ref) {
  final complaintsAsync = ref.watch(adminRawComplaintsProvider);
  final statusFilter = ref.watch(adminComplaintStatusFilterProvider);
  final searchQuery = ref.watch(adminComplaintSearchQueryProvider).toLowerCase();

  return complaintsAsync.whenData((complaints) {
    var filtered = complaints;

    if (statusFilter != null) {
      filtered = filtered.where((c) => c.status == statusFilter).toList();
    }

    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((c) {
        final titleMatch = c.title.toLowerCase().contains(searchQuery);
        final descMatch = c.description.toLowerCase().contains(searchQuery);
        final categoryMatch = c.category.toLowerCase().contains(searchQuery);
        return titleMatch || descMatch || categoryMatch;
      }).toList();
    }

    return filtered;
  });
});
