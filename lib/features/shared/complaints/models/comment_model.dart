import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment_model.freezed.dart';
part 'comment_model.g.dart';

@freezed
abstract class CommentModel with _$CommentModel {
  const factory CommentModel({
    required String id,
    @JsonKey(name: 'complaint_id') required String complaintId,
    @JsonKey(name: 'user_id') required String userId,
    required String content,
    @JsonKey(name: 'created_at') DateTime? createdAt,

  }) = _CommentModel;

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);
}
