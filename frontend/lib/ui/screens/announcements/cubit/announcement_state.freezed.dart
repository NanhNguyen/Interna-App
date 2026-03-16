// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'announcement_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AnnouncementState {
  BaseStatus get status => throw _privateConstructorUsedError;
  BaseStatus get submitStatus => throw _privateConstructorUsedError;
  List<AnnouncementModel> get announcements =>
      throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of AnnouncementState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnnouncementStateCopyWith<AnnouncementState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnnouncementStateCopyWith<$Res> {
  factory $AnnouncementStateCopyWith(
    AnnouncementState value,
    $Res Function(AnnouncementState) then,
  ) = _$AnnouncementStateCopyWithImpl<$Res, AnnouncementState>;
  @useResult
  $Res call({
    BaseStatus status,
    BaseStatus submitStatus,
    List<AnnouncementModel> announcements,
    String? errorMessage,
  });
}

/// @nodoc
class _$AnnouncementStateCopyWithImpl<$Res, $Val extends AnnouncementState>
    implements $AnnouncementStateCopyWith<$Res> {
  _$AnnouncementStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnnouncementState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? submitStatus = null,
    Object? announcements = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as BaseStatus,
            submitStatus: null == submitStatus
                ? _value.submitStatus
                : submitStatus // ignore: cast_nullable_to_non_nullable
                      as BaseStatus,
            announcements: null == announcements
                ? _value.announcements
                : announcements // ignore: cast_nullable_to_non_nullable
                      as List<AnnouncementModel>,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AnnouncementStateImplCopyWith<$Res>
    implements $AnnouncementStateCopyWith<$Res> {
  factory _$$AnnouncementStateImplCopyWith(
    _$AnnouncementStateImpl value,
    $Res Function(_$AnnouncementStateImpl) then,
  ) = __$$AnnouncementStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    BaseStatus status,
    BaseStatus submitStatus,
    List<AnnouncementModel> announcements,
    String? errorMessage,
  });
}

/// @nodoc
class __$$AnnouncementStateImplCopyWithImpl<$Res>
    extends _$AnnouncementStateCopyWithImpl<$Res, _$AnnouncementStateImpl>
    implements _$$AnnouncementStateImplCopyWith<$Res> {
  __$$AnnouncementStateImplCopyWithImpl(
    _$AnnouncementStateImpl _value,
    $Res Function(_$AnnouncementStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AnnouncementState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? submitStatus = null,
    Object? announcements = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$AnnouncementStateImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as BaseStatus,
        submitStatus: null == submitStatus
            ? _value.submitStatus
            : submitStatus // ignore: cast_nullable_to_non_nullable
                  as BaseStatus,
        announcements: null == announcements
            ? _value._announcements
            : announcements // ignore: cast_nullable_to_non_nullable
                  as List<AnnouncementModel>,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$AnnouncementStateImpl implements _AnnouncementState {
  const _$AnnouncementStateImpl({
    this.status = BaseStatus.initial,
    this.submitStatus = BaseStatus.initial,
    final List<AnnouncementModel> announcements = const [],
    this.errorMessage,
  }) : _announcements = announcements;

  @override
  @JsonKey()
  final BaseStatus status;
  @override
  @JsonKey()
  final BaseStatus submitStatus;
  final List<AnnouncementModel> _announcements;
  @override
  @JsonKey()
  List<AnnouncementModel> get announcements {
    if (_announcements is EqualUnmodifiableListView) return _announcements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_announcements);
  }

  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'AnnouncementState(status: $status, submitStatus: $submitStatus, announcements: $announcements, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnnouncementStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.submitStatus, submitStatus) ||
                other.submitStatus == submitStatus) &&
            const DeepCollectionEquality().equals(
              other._announcements,
              _announcements,
            ) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    status,
    submitStatus,
    const DeepCollectionEquality().hash(_announcements),
    errorMessage,
  );

  /// Create a copy of AnnouncementState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnnouncementStateImplCopyWith<_$AnnouncementStateImpl> get copyWith =>
      __$$AnnouncementStateImplCopyWithImpl<_$AnnouncementStateImpl>(
        this,
        _$identity,
      );
}

abstract class _AnnouncementState implements AnnouncementState {
  const factory _AnnouncementState({
    final BaseStatus status,
    final BaseStatus submitStatus,
    final List<AnnouncementModel> announcements,
    final String? errorMessage,
  }) = _$AnnouncementStateImpl;

  @override
  BaseStatus get status;
  @override
  BaseStatus get submitStatus;
  @override
  List<AnnouncementModel> get announcements;
  @override
  String? get errorMessage;

  /// Create a copy of AnnouncementState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnnouncementStateImplCopyWith<_$AnnouncementStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
