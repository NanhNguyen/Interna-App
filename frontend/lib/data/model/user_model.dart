import 'package:freezed_annotation/freezed_annotation.dart';
import '../constant/enums.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    @JsonKey(name: '_id', readValue: _readId) required String id,
    required String email,
    required String name,
    required UserRole role,
    String? avatarUrl,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);
}

Object? _readId(Map json, String key) => json['_id'] ?? json['id'];
