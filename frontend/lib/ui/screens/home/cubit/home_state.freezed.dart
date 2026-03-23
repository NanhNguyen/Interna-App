// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$HomeState {
  BaseStatus get status => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  UserModel? get user => throw _privateConstructorUsedError;
  int get pendingCount => throw _privateConstructorUsedError;
  int get mealCountToday => throw _privateConstructorUsedError;
  bool get isMealRegisteredToday => throw _privateConstructorUsedError;
  ScheduleRequestModel? get todaySchedule => throw _privateConstructorUsedError;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HomeStateCopyWith<HomeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeStateCopyWith<$Res> {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) then) =
      _$HomeStateCopyWithImpl<$Res, HomeState>;
  @useResult
  $Res call({
    BaseStatus status,
    String? errorMessage,
    UserModel? user,
    int pendingCount,
    int mealCountToday,
    bool isMealRegisteredToday,
    ScheduleRequestModel? todaySchedule,
  });

  $UserModelCopyWith<$Res>? get user;
  $ScheduleRequestModelCopyWith<$Res>? get todaySchedule;
}

/// @nodoc
class _$HomeStateCopyWithImpl<$Res, $Val extends HomeState>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? errorMessage = freezed,
    Object? user = freezed,
    Object? pendingCount = null,
    Object? mealCountToday = null,
    Object? isMealRegisteredToday = null,
    Object? todaySchedule = freezed,
  }) {
    return _then(
      _value.copyWith(
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as BaseStatus,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            user: freezed == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as UserModel?,
            pendingCount: null == pendingCount
                ? _value.pendingCount
                : pendingCount // ignore: cast_nullable_to_non_nullable
                      as int,
            mealCountToday: null == mealCountToday
                ? _value.mealCountToday
                : mealCountToday // ignore: cast_nullable_to_non_nullable
                      as int,
            isMealRegisteredToday: null == isMealRegisteredToday
                ? _value.isMealRegisteredToday
                : isMealRegisteredToday // ignore: cast_nullable_to_non_nullable
                      as bool,
            todaySchedule: freezed == todaySchedule
                ? _value.todaySchedule
                : todaySchedule // ignore: cast_nullable_to_non_nullable
                      as ScheduleRequestModel?,
          )
          as $Val,
    );
  }

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $UserModelCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScheduleRequestModelCopyWith<$Res>? get todaySchedule {
    if (_value.todaySchedule == null) {
      return null;
    }

    return $ScheduleRequestModelCopyWith<$Res>(_value.todaySchedule!, (value) {
      return _then(_value.copyWith(todaySchedule: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HomeStateImplCopyWith<$Res>
    implements $HomeStateCopyWith<$Res> {
  factory _$$HomeStateImplCopyWith(
    _$HomeStateImpl value,
    $Res Function(_$HomeStateImpl) then,
  ) = __$$HomeStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    BaseStatus status,
    String? errorMessage,
    UserModel? user,
    int pendingCount,
    int mealCountToday,
    bool isMealRegisteredToday,
    ScheduleRequestModel? todaySchedule,
  });

  @override
  $UserModelCopyWith<$Res>? get user;
  @override
  $ScheduleRequestModelCopyWith<$Res>? get todaySchedule;
}

/// @nodoc
class __$$HomeStateImplCopyWithImpl<$Res>
    extends _$HomeStateCopyWithImpl<$Res, _$HomeStateImpl>
    implements _$$HomeStateImplCopyWith<$Res> {
  __$$HomeStateImplCopyWithImpl(
    _$HomeStateImpl _value,
    $Res Function(_$HomeStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? errorMessage = freezed,
    Object? user = freezed,
    Object? pendingCount = null,
    Object? mealCountToday = null,
    Object? isMealRegisteredToday = null,
    Object? todaySchedule = freezed,
  }) {
    return _then(
      _$HomeStateImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as BaseStatus,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        user: freezed == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as UserModel?,
        pendingCount: null == pendingCount
            ? _value.pendingCount
            : pendingCount // ignore: cast_nullable_to_non_nullable
                  as int,
        mealCountToday: null == mealCountToday
            ? _value.mealCountToday
            : mealCountToday // ignore: cast_nullable_to_non_nullable
                  as int,
        isMealRegisteredToday: null == isMealRegisteredToday
            ? _value.isMealRegisteredToday
            : isMealRegisteredToday // ignore: cast_nullable_to_non_nullable
                  as bool,
        todaySchedule: freezed == todaySchedule
            ? _value.todaySchedule
            : todaySchedule // ignore: cast_nullable_to_non_nullable
                  as ScheduleRequestModel?,
      ),
    );
  }
}

/// @nodoc

class _$HomeStateImpl implements _HomeState {
  const _$HomeStateImpl({
    this.status = BaseStatus.initial,
    this.errorMessage,
    this.user,
    this.pendingCount = 0,
    this.mealCountToday = 0,
    this.isMealRegisteredToday = false,
    this.todaySchedule,
  });

  @override
  @JsonKey()
  final BaseStatus status;
  @override
  final String? errorMessage;
  @override
  final UserModel? user;
  @override
  @JsonKey()
  final int pendingCount;
  @override
  @JsonKey()
  final int mealCountToday;
  @override
  @JsonKey()
  final bool isMealRegisteredToday;
  @override
  final ScheduleRequestModel? todaySchedule;

  @override
  String toString() {
    return 'HomeState(status: $status, errorMessage: $errorMessage, user: $user, pendingCount: $pendingCount, mealCountToday: $mealCountToday, isMealRegisteredToday: $isMealRegisteredToday, todaySchedule: $todaySchedule)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.pendingCount, pendingCount) ||
                other.pendingCount == pendingCount) &&
            (identical(other.mealCountToday, mealCountToday) ||
                other.mealCountToday == mealCountToday) &&
            (identical(other.isMealRegisteredToday, isMealRegisteredToday) ||
                other.isMealRegisteredToday == isMealRegisteredToday) &&
            (identical(other.todaySchedule, todaySchedule) ||
                other.todaySchedule == todaySchedule));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    status,
    errorMessage,
    user,
    pendingCount,
    mealCountToday,
    isMealRegisteredToday,
    todaySchedule,
  );

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HomeStateImplCopyWith<_$HomeStateImpl> get copyWith =>
      __$$HomeStateImplCopyWithImpl<_$HomeStateImpl>(this, _$identity);
}

abstract class _HomeState implements HomeState {
  const factory _HomeState({
    final BaseStatus status,
    final String? errorMessage,
    final UserModel? user,
    final int pendingCount,
    final int mealCountToday,
    final bool isMealRegisteredToday,
    final ScheduleRequestModel? todaySchedule,
  }) = _$HomeStateImpl;

  @override
  BaseStatus get status;
  @override
  String? get errorMessage;
  @override
  UserModel? get user;
  @override
  int get pendingCount;
  @override
  int get mealCountToday;
  @override
  bool get isMealRegisteredToday;
  @override
  ScheduleRequestModel? get todaySchedule;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HomeStateImplCopyWith<_$HomeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
