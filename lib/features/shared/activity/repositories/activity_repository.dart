import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/error_handler.dart';
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
        .limit(20)
        .map((records) => records.map((e) => ActivityModel.fromJson(e)).toList());
  }

  /// Update the last_seen_activities_at timestamp for a user (student + admin).
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
