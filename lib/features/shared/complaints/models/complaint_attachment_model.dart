import 'package:freezed_annotation/freezed_annotation.dart';

part 'complaint_attachment_model.freezed.dart';
part 'complaint_attachment_model.g.dart';

@JsonEnum(alwaysCreate: true)
enum ComplaintAttachmentType {
  audio,
  image,
  document,
}

@freezed
abstract class ComplaintAttachmentModel with _$ComplaintAttachmentModel {
  const factory ComplaintAttachmentModel({
    required String id,
    @JsonKey(name: 'complaint_id') required String complaintId,
    @JsonKey(name: 'user_id') required String userId,
    @Default(ComplaintAttachmentType.audio) ComplaintAttachmentType type,
    @JsonKey(name: 'storage_path') required String storagePath,
    @JsonKey(name: 'mime_type') required String mimeType,
    @JsonKey(name: 'file_size') required int fileSize,
    @JsonKey(name: 'duration_seconds') int? durationSeconds,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _ComplaintAttachmentModel;

  factory ComplaintAttachmentModel.fromJson(Map<String, dynamic> json) =>
      _$ComplaintAttachmentModelFromJson(json);
}
