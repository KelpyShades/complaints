import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/error_handler.dart';
import '../models/complaint_model.dart';
import '../models/comment_model.dart';

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
