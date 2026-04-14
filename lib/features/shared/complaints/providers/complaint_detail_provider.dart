import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/realtime_list_stream_replay.dart';
import '../models/comment_model.dart';
import '../models/complaint_attachment_model.dart';
import '../models/complaint_model.dart';
import 'complaint_repository_provider.dart';

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
    state = await AsyncValue.guard(() async {
      final complaint = await ref.read(complaintRepositoryProvider).updateComplaint(
            id: arg,
            status: status,
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
    final source =
        ref.watch(complaintRepositoryProvider).watchComment(complaintId);
    return replayLastListOnStreamError(source);
  },
);

// ── Attachments (e.g. voice notes) ─────────────────────────────────────

final complaintAttachmentsProvider =
    FutureProvider.autoDispose.family<List<ComplaintAttachmentModel>, String>(
  (ref, complaintId) {
    return ref.watch(complaintRepositoryProvider).getComplaintAttachments(
          complaintId,
        );
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
    state = await AsyncValue.guard(() async {
      await ref.read(complaintRepositoryProvider).addComment(
            complaintId: complaintId,
            userId: userId,
            content: content,
          );
    });
    return !state.hasError;
  }
}
