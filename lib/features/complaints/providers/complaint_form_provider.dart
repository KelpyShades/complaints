import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../../notifications/providers/activity_provider.dart';
import 'complaint_list_provider.dart';

// ── Complaint form provider ────────────────────────────────────────────

final complaintFormProvider =
    AsyncNotifierProvider.autoDispose<ComplaintFormNotifier, void>(
  ComplaintFormNotifier.new,
);

/// Manages complaint form submission (create / edit).
class ComplaintFormNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> submit({
    required String title,
    required String description,
    required String category,
    String? existingId,
  }) async {
    state = const AsyncLoading();

    final repo = ref.read(complaintRepositoryProvider);
    final activityRepo = ref.read(activityRepositoryProvider);

    try {
      if (existingId != null) {
        final complaint = await repo.updateComplaint(
          id: existingId,
          title: title,
          description: description,
          category: category,
        );
        
        await activityRepo.logActivity(
          userId: complaint.userId,
          complaintId: complaint.id,
          title: 'Complaint Updated',
          type: 'update',
        );
      } else {
        final user = await ref.read(currentUserProvider.future);
        if (user == null) throw Exception('You must be signed in.');

        final complaint = await repo.createComplaint(
          title: title,
          description: description,
          category: category,
          userId: user.id,
        );

        await activityRepo.logActivity(
          userId: user.id,
          complaintId: complaint.id,
          title: 'New Complaint Submitted',
          type: 'new_complaint',
        );
      }
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}
