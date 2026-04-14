import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class ActivityModel {
  final String id;
  final String complaintId;
  final String type; // 'status_changed', 'comment_added', 'complaint_submitted'
  final String message;
  final String? oldStatus;
  final String? newStatus;
  final String complaintTitle;
  final DateTime? createdAt;

  const ActivityModel({
    required this.id,
    required this.complaintId,
    required this.type,
    required this.message,
    this.oldStatus,
    this.newStatus,
    required this.complaintTitle,
    this.createdAt,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String,
      complaintId: json['complaint_id'] as String,
      type: json['type'] as String,
      message: json['message'] as String,
      oldStatus: json['old_status'] as String?,
      newStatus: json['new_status'] as String?,
      complaintTitle: json['complaint_title'] as String,
      createdAt: json['created_at'] == null 
          ? null 
          : DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'complaint_id': complaintId,
      'type': type,
      'message': message,
      'old_status': oldStatus,
      'new_status': newStatus,
      'complaint_title': complaintTitle,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
