import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/error_handler.dart';
import '../models/activity_model.dart';

/// Repository for fetching user or admin activities/notifications.
class ActivityRepository {
  ActivityRepository(this._client);

  final SupabaseClient _client;

  /// Watch activities stream from DB (handled by RLS: admins see all,
  /// students see own).
  Stream<List<ActivityModel>> watchActivities() {
    return _client
        .from('complaint_activities')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(100) // load top 100 for now
        .map((records) => records.map((e) => ActivityModel.fromJson(e)).toList());
  }

  /// Log a new activity.
  Future<void> logActivity({
    required String userId,
    required String complaintId,
    required String title,
    required String type, // 'status_change', 'new_comment', 'new_complaint'
  }) async {
    try {
      await _client.from('complaint_activities').insert({
        'user_id': userId,
        'complaint_id': complaintId,
        'title': title,
        'type': type,
      });
    } catch (e, st) {
      ErrorHandler.handle(e, st);
    }
  }

  /// Mark all unread activities for a given user as read.
  Future<void> markAllAsRead(String userId) async {
    try {
      await _client
          .from('complaint_activities')
          .update({'read_at': DateTime.now().toIso8601String()})
          .eq('user_id', userId)
          .isFilter('read_at', null); // Only touch unread ones
    } catch (e, st) {
      ErrorHandler.handle(e, st);
    }
  }

  /// Update the last_seen_activities_at timestamp for a user (typically admin).
  Future<void> updateLastSeenActivities(String userId) async {
    try {
      await _client
          .from('profiles')
          .update({'last_seen_activities_at': DateTime.now().toIso8601String()})
          .eq('id', userId);
    } catch (e, st) {
      ErrorHandler.handle(e, st);
    }
  }
}
