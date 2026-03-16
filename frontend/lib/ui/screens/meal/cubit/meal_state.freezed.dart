// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meal_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$MealState {
  BaseStatus get status => throw _privateConstructorUsedError;
  BaseStatus get submitStatus => throw _privateConstructorUsedError;
  List<MealModel> get meals => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of MealState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MealStateCopyWith<MealState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealStateCopyWith<$Res> {
  factory $MealStateCopyWith(MealState value, $Res Function(MealState) then) =
      _$MealStateCopyWithImpl<$Res, MealState>;
  @useResult
  $Res call({
    BaseStatus status,
    BaseStatus submitStatus,
    List<MealModel> meals,
    String? errorMessage,
  });
}

/// @nodoc
class _$MealStateCopyWithImpl<$Res, $Val extends MealState>
    implements $MealStateCopyWith<$Res> {
  _$MealStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MealState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? submitStatus = null,
    Object? meals = null,
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
            meals: null == meals
                ? _value.meals
                : meals // ignore: cast_nullable_to_non_nullable
                      as List<MealModel>,
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
abstract class _$$MealStateImplCopyWith<$Res>
    implements $MealStateCopyWith<$Res> {
  factory _$$MealStateImplCopyWith(
    _$MealStateImpl value,
    $Res Function(_$MealStateImpl) then,
  ) = __$$MealStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    BaseStatus status,
    BaseStatus submitStatus,
    List<MealModel> meals,
    String? errorMessage,
  });
}

/// @nodoc
class __$$MealStateImplCopyWithImpl<$Res>
    extends _$MealStateCopyWithImpl<$Res, _$MealStateImpl>
    implements _$$MealStateImplCopyWith<$Res> {
  __$$MealStateImplCopyWithImpl(
    _$MealStateImpl _value,
    $Res Function(_$MealStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MealState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? submitStatus = null,
    Object? meals = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$MealStateImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as BaseStatus,
        submitStatus: null == submitStatus
            ? _value.submitStatus
            : submitStatus // ignore: cast_nullable_to_non_nullable
                  as BaseStatus,
        meals: null == meals
            ? _value._meals
            : meals // ignore: cast_nullable_to_non_nullable
                  as List<MealModel>,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$MealStateImpl implements _MealState {
  const _$MealStateImpl({
    this.status = BaseStatus.initial,
    this.submitStatus = BaseStatus.initial,
    final List<MealModel> meals = const [],
    this.errorMessage,
  }) : _meals = meals;

  @override
  @JsonKey()
  final BaseStatus status;
  @override
  @JsonKey()
  final BaseStatus submitStatus;
  final List<MealModel> _meals;
  @override
  @JsonKey()
  List<MealModel> get meals {
    if (_meals is EqualUnmodifiableListView) return _meals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_meals);
  }

  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'MealState(status: $status, submitStatus: $submitStatus, meals: $meals, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.submitStatus, submitStatus) ||
                other.submitStatus == submitStatus) &&
            const DeepCollectionEquality().equals(other._meals, _meals) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    status,
    submitStatus,
    const DeepCollectionEquality().hash(_meals),
    errorMessage,
  );

  /// Create a copy of MealState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MealStateImplCopyWith<_$MealStateImpl> get copyWith =>
      __$$MealStateImplCopyWithImpl<_$MealStateImpl>(this, _$identity);
}

abstract class _MealState implements MealState {
  const factory _MealState({
    final BaseStatus status,
    final BaseStatus submitStatus,
    final List<MealModel> meals,
    final String? errorMessage,
  }) = _$MealStateImpl;

  @override
  BaseStatus get status;
  @override
  BaseStatus get submitStatus;
  @override
  List<MealModel> get meals;
  @override
  String? get errorMessage;

  /// Create a copy of MealState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MealStateImplCopyWith<_$MealStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
