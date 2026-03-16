// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AnnouncementModelImpl _$$AnnouncementModelImplFromJson(
  Map<String, dynamic> json,
) => _$AnnouncementModelImpl(
  id: json['_id'] as String,
  authorId: json['authorId'] as String,
  authorName: json['authorName'] as String,
  title: json['title'] as String,
  content: json['content'] as String,
  seenBy:
      (json['seenBy'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$AnnouncementModelImplToJson(
  _$AnnouncementModelImpl instance,
) => <String, dynamic>{
  '_id': instance.id,
  'authorId': instance.authorId,
  'authorName': instance.authorName,
  'title': instance.title,
  'content': instance.content,
  'seenBy': instance.seenBy,
  'createdAt': instance.createdAt.toIso8601String(),
};
