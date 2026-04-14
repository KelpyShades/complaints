import 'package:freezed_annotation/freezed_annotation.dart';

part 'complaint_model.freezed.dart';
part 'complaint_model.g.dart';

/// Possible statuses for a complaint.
enum ComplaintStatus {
  pending,
  @JsonValue('in_progress')
  inProgress,
  resolved,
  rejected;

  String get label => switch (this) {
        pending => 'Pending',
        inProgress => 'In Progress',
        resolved => 'Resolved',
        rejected => 'Rejected',
      };
}

@freezed
abstract class ComplaintModel with _$ComplaintModel {
  const factory ComplaintModel({
    required String id,
    required String title,
    required String description,
    required String category,
    @Default(ComplaintStatus.pending) ComplaintStatus status,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'assigned_to') String? assignedTo,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _ComplaintModel;

  factory ComplaintModel.fromJson(Map<String, dynamic> json) =>
      _$ComplaintModelFromJson(json);
}
