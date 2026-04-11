import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../notifications/providers/activity_provider.dart';
import '../models/complaint_model.dart';
import '../models/comment_model.dart';
import 'complaint_list_provider.dart';

// ── Single complaint ───────────────────────────────────────────────────

final complaintDetailProvider = AsyncNotifierProvider.autoDispose
    .family<ComplaintDetailNotifier, ComplaintModel, String>(
  ComplaintDetailNotifier.new,
);

class ComplaintDetailNotifier
    extends AutoDisposeFamilyAsyncNotifier<ComplaintModel, String> {
  @override
  Future<ComplaintModel> build(String arg) async {
    return ref.read(complaintRepositoryProvider).getComplaintById(arg);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(complaintRepositoryProvider).getComplaintById(arg),
    );
  }

  Future<bool> updateStatus(ComplaintStatus status) async {
    state = const AsyncLoading();
    final activityRepo = ref.read(activityRepositoryProvider);
    
    state = await AsyncValue.guard(() async {
      final complaint = await ref.read(complaintRepositoryProvider).updateComplaint(
            id: arg,
            status: status,
          );
          
      // Log activity for the student to see
      await activityRepo.logActivity(
        userId: complaint.userId,
        complaintId: complaint.id,
        title: 'Status Updated',
        type: 'status_change',
      );
      
      return complaint;
    });
    
    return !state.hasError;
  }

  Future<bool> delete() async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(complaintRepositoryProvider).deleteComplaint(arg),
    );
    return !result.hasError;
  }
}

// ── Comments for a complaint ───────────────────────────────────────────

final complaintCommentsProvider =
    StreamProvider.autoDispose.family<List<CommentModel>, String>(
  (ref, complaintId) {
    return ref.watch(complaintRepositoryProvider).watchComment(complaintId);
  },
);

// ── Add comment ────────────────────────────────────────────────────────

final addCommentProvider =
    AsyncNotifierProvider.autoDispose<AddCommentNotifier, void>(
  AddCommentNotifier.new,
);

class AddCommentNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> execute({
    required String complaintId,
    required String userId,
    required String content,
  }) async {
    state = const AsyncLoading();
    final activityRepo = ref.read(activityRepositoryProvider);
    
    state = await AsyncValue.guard(() async {
      await ref.read(complaintRepositoryProvider).addComment(
            complaintId: complaintId,
            userId: userId,
            content: content,
          );
          
      // Get the complaint to know the owner
      final complaint = await ref.read(complaintRepositoryProvider).getComplaintById(complaintId);
      
      // Log activity for the relevant party (if admin commented, notify student, and vice versa)
      // For now, any comment shows in the complaint owner's feed
      await activityRepo.logActivity(
        userId: complaint.userId,
        complaintId: complaintId,
        title: 'New Message',
        type: 'new_comment',
      );
      
      // No return needed as state type is void
    });
    return !state.hasError;
  }
}
