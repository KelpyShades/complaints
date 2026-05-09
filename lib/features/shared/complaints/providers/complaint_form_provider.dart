import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/providers/auth_provider.dart';
import '../data/complaint_media_constants.dart';
import '../models/pending_complaint_audio.dart';
import '../models/pending_complaint_image.dart';
import '../utils/read_pending_audio_bytes.dart';
import 'complaint_repository_provider.dart';

// ── Complaint form provider ────────────────────────────────────────────

final complaintFormProvider =
    AsyncNotifierProvider.autoDispose<ComplaintFormNotifier, void>(
  ComplaintFormNotifier.new,
);

sealed class ComplaintFormSubmitOutcome {}

final class ComplaintFormSubmitSuccess extends ComplaintFormSubmitOutcome {}

final class ComplaintFormSubmitFailure extends ComplaintFormSubmitOutcome {
  ComplaintFormSubmitFailure(this.error);
  final Object error;
}

/// Complaint row exists in the database but uploading the voice note failed.
final class ComplaintFormSubmitMissingAudio extends ComplaintFormSubmitOutcome {
  ComplaintFormSubmitMissingAudio({
    required this.complaintId,
    required this.error,
  });
  final String complaintId;
  final Object error;
}

/// Manages complaint form submission (create / edit) and optional audio upload.
class ComplaintFormNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<ComplaintFormSubmitOutcome> submit({
    required String title,
    required String description,
    required String category,
    String? existingId,
    PendingComplaintAudio? audio,
    List<PendingComplaintImage>? images,
  }) async {
    state = const AsyncLoading();

    final repo = ref.read(complaintRepositoryProvider);

    try {
      if (existingId != null) {
        await repo.updateComplaint(
          id: existingId,
          title: title,
          description: description,
          category: category,
        );

        state = const AsyncData(null);
        return ComplaintFormSubmitSuccess();
      }

      final user = await ref.read(currentUserProvider.future);
      if (user == null) throw Exception('You must be signed in.');

      final complaint = await repo.createComplaint(
        title: title,
        description: description,
        category: category,
        userId: user.id,
      );

      if (audio != null) {
        try {
          final bytes = await readPendingComplaintAudioBytes(audio);
          if (bytes.length > kComplaintAudioMaxBytes) {
            throw Exception(
              'That recording is too large. Maximum size is '
              '${kComplaintAudioMaxBytes ~/ (1024 * 1024)} MB.',
            );
          }
          await repo.uploadComplaintAudio(
            complaintId: complaint.id,
            userId: user.id,
            bytes: bytes,
            mimeType: audio.mimeType,
            fileSize: bytes.length,
            durationSeconds: audio.durationSeconds,
            fileExtension: audio.fileExtension,
          );
        } catch (e) {
          state = const AsyncData(null);
          return ComplaintFormSubmitMissingAudio(
            complaintId: complaint.id,
            error: e,
          );
        }
      }

      if (images != null && images.isNotEmpty) {
        for (final image in images) {
          try {
            final bytes = await image.file.readAsBytes();
            if (bytes.length > kComplaintImageMaxBytes) {
              throw Exception(
                'An image is too large. Maximum size is '
                '${kComplaintImageMaxBytes ~/ (1024 * 1024)} MB.',
              );
            }
            await repo.uploadComplaintImage(
              complaintId: complaint.id,
              userId: user.id,
              bytes: bytes,
              mimeType: image.mimeType,
              fileSize: bytes.length,
              fileExtension: image.fileExtension,
            );
          } catch (e) {
            // Log or handle partial image upload failure. For now, continue.
          }
        }
      }

      state = const AsyncData(null);
      return ComplaintFormSubmitSuccess();
    } catch (e, st) {
      state = AsyncError(e, st);
      return ComplaintFormSubmitFailure(e);
    }
  }

  /// Retries only the Storage + `complaint_attachments` insert for an existing complaint.
  Future<ComplaintFormSubmitOutcome> retryAudioUpload({
    required String complaintId,
    required PendingComplaintAudio audio,
  }) async {
    state = const AsyncLoading();
    final repo = ref.read(complaintRepositoryProvider);

    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) throw Exception('You must be signed in.');

      final bytes = await readPendingComplaintAudioBytes(audio);
      if (bytes.length > kComplaintAudioMaxBytes) {
        throw Exception(
          'That recording is too large. Maximum size is '
          '${kComplaintAudioMaxBytes ~/ (1024 * 1024)} MB.',
        );
      }

      await repo.uploadComplaintAudio(
        complaintId: complaintId,
        userId: user.id,
        bytes: bytes,
        mimeType: audio.mimeType,
        fileSize: bytes.length,
        durationSeconds: audio.durationSeconds,
        fileExtension: audio.fileExtension,
      );

      state = const AsyncData(null);
      return ComplaintFormSubmitSuccess();
    } catch (e, st) {
      state = AsyncError(e, st);
      return ComplaintFormSubmitFailure(e);
    }
  }
}

