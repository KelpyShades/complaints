import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/error_handler.dart';
import '../data/complaint_media_constants.dart';
import '../models/comment_model.dart';
import '../models/complaint_attachment_model.dart';
import '../models/complaint_model.dart';

/// Handles all complaint and comment CRUD + realtime subscriptions.
class ComplaintRepository {
  ComplaintRepository(this._client);

  final SupabaseClient _client;

  // ── Complaints CRUD ──────────────────────────────────────────────────

  /// Fetches complaints, optionally filtered by status or user.
  Future<List<ComplaintModel>> getComplaints({
    ComplaintStatus? status,
    String? userId,
  }) async {
    try {
      var query = _client.from('complaints').select();

      if (status != null) {
        query = query.eq('status', status.name);
      }
      if (userId != null) {
        query = query.eq('user_id', userId);
      }

      final data = await query.order('created_at', ascending: false);
      return data.map((e) => ComplaintModel.fromJson(e)).toList();
    } catch (e, st) {
      throw ErrorHandler.handle(e, st);
    }
  }

  Future<ComplaintModel> getComplaintById(String id) async {
    try {
      final data = await _client
          .from('complaints')
          .select()
          .eq('id', id)
          .single();
      return ComplaintModel.fromJson(data);
    } catch (e, st) {
      throw ErrorHandler.handle(e, st);
    }
  }

  Future<ComplaintModel> createComplaint({
    required String title,
    required String description,
    required String category,
    required String userId,
  }) async {
    try {
      final data = await _client
          .from('complaints')
          .insert({
            'title': title,
            'description': description,
            'category': category,
            'user_id': userId,
          })
          .select()
          .single();
      return ComplaintModel.fromJson(data);
    } catch (e, st) {
      throw ErrorHandler.handle(e, st);
    }
  }

  String getRawStatus(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.pending:
        return 'pending';
      case ComplaintStatus.inProgress:
        return 'in_progress';
      case ComplaintStatus.resolved:
        return 'resolved';
      case ComplaintStatus.rejected:
        return 'rejected';
    }
  }

  Future<ComplaintModel> updateComplaint({
    required String id,
    String? title,
    String? description,
    String? category,
    ComplaintStatus? status,
    String? assignedTo,
  }) async {
    try {
      final updates = <String, dynamic>{
        'title': ?title,
        'description': ?description,
        'category': ?category,
        if (status != null) 'status': getRawStatus(status),
        'assigned_to': ?assignedTo,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final data = await _client
          .from('complaints')
          .update(updates)
          .eq('id', id)
          .select()
          .single();
      return ComplaintModel.fromJson(data);
    } catch (e, st) {
      throw ErrorHandler.handle(e, st);
    }
  }

  Future<void> deleteComplaint(String id) async {
    try {
      await _client.from('complaints').delete().eq('id', id);
    } catch (e, st) {
      throw ErrorHandler.handle(e, st);
    }
  }

  // ── Attachments (v1: audio) ─────────────────────────────────────────

  Future<List<ComplaintAttachmentModel>> getComplaintAttachments(
    String complaintId,
  ) async {
    try {
      final data = await _client
          .from('complaint_attachments')
          .select()
          .eq('complaint_id', complaintId)
          .order('created_at', ascending: true);
      return (data as List<dynamic>)
          .map(
            (e) => ComplaintAttachmentModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
    } catch (e, st) {
      throw ErrorHandler.handle(e, st);
    }
  }

  /// Uploads bytes to Storage, then inserts `complaint_attachments` (rolls back object on DB failure).
  Future<ComplaintAttachmentModel> uploadComplaintAudio({
    required String complaintId,
    required String userId,
    required Uint8List bytes,
    required String mimeType,
    required int fileSize,
    int? durationSeconds,
    required String fileExtension,
  }) async {
    if (fileSize != bytes.length) {
      throw ArgumentError('fileSize must match byte length.');
    }
    if (bytes.isEmpty) {
      throw ArgumentError('Audio payload is empty.');
    }
    if (bytes.length > kComplaintAudioMaxBytes) {
      throw Exception(
        'That recording is too large. Maximum size is '
        '${kComplaintAudioMaxBytes ~/ (1024 * 1024)} MB.',
      );
    }

    final ext = fileExtension.replaceFirst(RegExp(r'^\.'), '');
    final objectPath = '$complaintId/${const Uuid().v4()}.$ext';

    try {
      await _client.storage.from(kComplaintMediaBucketId).uploadBinary(
        objectPath,
        bytes,
        fileOptions: FileOptions(contentType: mimeType),
      );
    } catch (e, st) {
      throw ErrorHandler.handle(e, st);
    }

    try {
      final row = await _client.from('complaint_attachments').insert({
        'complaint_id': complaintId,
        'user_id': userId,
        'type': 'audio',
        'storage_path': objectPath,
        'mime_type': mimeType,
        'file_size': fileSize,
        'duration_seconds': durationSeconds,
      }).select().single();
      return ComplaintAttachmentModel.fromJson(row);
    } catch (e, st) {
      try {
        await _client.storage.from(kComplaintMediaBucketId).remove([objectPath]);
      } catch (_) {}
      throw ErrorHandler.handle(e, st);
    }
  }

  Future<String> signedUrlForComplaintMedia(
    String storagePath, {
    int expiresInSeconds = 3600,
  }) async {
    try {
      return await _client.storage
          .from(kComplaintMediaBucketId)
          .createSignedUrl(storagePath, expiresInSeconds);
    } catch (e, st) {
      throw ErrorHandler.handle(e, st);
    }
  }

  // ── Realtime ─────────────────────────────────────────────────────────

  /// Streams all complaint changes in real time.
  Stream<List<ComplaintModel>> watchComplaints() {
    return _client
        .from('complaints')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((e) => ComplaintModel.fromJson(e)).toList());
  }

  // ── Comments ─────────────────────────────────────────────────────────


  Future<CommentModel> addComment({
    required String complaintId,
    required String userId,
    required String content,
  }) async {
    try {
      final data = await _client
          .from('complaint_comments')
          .insert({
            'complaint_id': complaintId,
            'user_id': userId,
            'content': content,
          })
          .select()
          .single();
      return CommentModel.fromJson(data);
    } catch (e, st) {
      throw ErrorHandler.handle(e, st);
    }
  }

  /// Streams comments for a specific complaint in real time.
  Stream<List<CommentModel>> watchComment(String complaintId) {
    return _client
        .from('complaint_comments')
        .stream(primaryKey: ['id'])
        .eq('complaint_id', complaintId)
        .order('created_at')
        .map((data) => data.map((e) => CommentModel.fromJson(e)).toList());
  }
}
