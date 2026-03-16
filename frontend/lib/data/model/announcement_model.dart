import 'package:freezed_annotation/freezed_annotation.dart';

part 'announcement_model.freezed.dart';
part 'announcement_model.g.dart';

@freezed
class AnnouncementModel with _$AnnouncementModel {
  const factory AnnouncementModel({
    @JsonKey(name: '_id') required String id,
    required String authorId,
    required String authorName,
    required String title,
    required String content,
    @Default([]) List<String> seenBy,
    @JsonKey(name: 'createdAt') required DateTime createdAt,
  }) = _AnnouncementModel;

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementModelFromJson(json);
}
