// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meal_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MealModel _$MealModelFromJson(Map<String, dynamic> json) {
  return _MealModel.fromJson(json);
}

/// @nodoc
mixin _$MealModel {
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  MealShift get shift => throw _privateConstructorUsedError;
  bool get isRecurring => throw _privateConstructorUsedError;
  List<MealWeekday> get weekdays => throw _privateConstructorUsedError;
  @JsonKey(name: 'startDate')
  DateTime get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'endDate')
  DateTime? get endDate => throw _privateConstructorUsedError;
  List<DateTime> get specificDates => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  @JsonKey(name: 'createdAt')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this MealModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MealModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MealModelCopyWith<MealModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealModelCopyWith<$Res> {
  factory $MealModelCopyWith(MealModel value, $Res Function(MealModel) then) =
      _$MealModelCopyWithImpl<$Res, MealModel>;
  @useResult
  $Res call({
    @JsonKey(name: '_id') String id,
    String userId,
    MealShift shift,
    bool isRecurring,
    List<MealWeekday> weekdays,
    @JsonKey(name: 'startDate') DateTime startDate,
    @JsonKey(name: 'endDate') DateTime? endDate,
    List<DateTime> specificDates,
    String? note,
    @JsonKey(name: 'createdAt') DateTime? createdAt,
  });
}

/// @nodoc
class _$MealModelCopyWithImpl<$Res, $Val extends MealModel>
    implements $MealModelCopyWith<$Res> {
  _$MealModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MealModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? shift = null,
    Object? isRecurring = null,
    Object? weekdays = null,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? specificDates = null,
    Object? note = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            shift: null == shift
                ? _value.shift
                : shift // ignore: cast_nullable_to_non_nullable
                      as MealShift,
            isRecurring: null == isRecurring
                ? _value.isRecurring
                : isRecurring // ignore: cast_nullable_to_non_nullable
                      as bool,
            weekdays: null == weekdays
                ? _value.weekdays
                : weekdays // ignore: cast_nullable_to_non_nullable
                      as List<MealWeekday>,
            startDate: null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endDate: freezed == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            specificDates: null == specificDates
                ? _value.specificDates
                : specificDates // ignore: cast_nullable_to_non_nullable
                      as List<DateTime>,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MealModelImplCopyWith<$Res>
    implements $MealModelCopyWith<$Res> {
  factory _$$MealModelImplCopyWith(
    _$MealModelImpl value,
    $Res Function(_$MealModelImpl) then,
  ) = __$$MealModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: '_id') String id,
    String userId,
    MealShift shift,
    bool isRecurring,
    List<MealWeekday> weekdays,
    @JsonKey(name: 'startDate') DateTime startDate,
    @JsonKey(name: 'endDate') DateTime? endDate,
    List<DateTime> specificDates,
    String? note,
    @JsonKey(name: 'createdAt') DateTime? createdAt,
  });
}

/// @nodoc
class __$$MealModelImplCopyWithImpl<$Res>
    extends _$MealModelCopyWithImpl<$Res, _$MealModelImpl>
    implements _$$MealModelImplCopyWith<$Res> {
  __$$MealModelImplCopyWithImpl(
    _$MealModelImpl _value,
    $Res Function(_$MealModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MealModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? shift = null,
    Object? isRecurring = null,
    Object? weekdays = null,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? specificDates = null,
    Object? note = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$MealModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        shift: null == shift
            ? _value.shift
            : shift // ignore: cast_nullable_to_non_nullable
                  as MealShift,
        isRecurring: null == isRecurring
            ? _value.isRecurring
            : isRecurring // ignore: cast_nullable_to_non_nullable
                  as bool,
        weekdays: null == weekdays
            ? _value._weekdays
            : weekdays // ignore: cast_nullable_to_non_nullable
                  as List<MealWeekday>,
        startDate: null == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endDate: freezed == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        specificDates: null == specificDates
            ? _value._specificDates
            : specificDates // ignore: cast_nullable_to_non_nullable
                  as List<DateTime>,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MealModelImpl implements _MealModel {
  const _$MealModelImpl({
    @JsonKey(name: '_id') required this.id,
    required this.userId,
    required this.shift,
    this.isRecurring = false,
    final List<MealWeekday> weekdays = const [],
    @JsonKey(name: 'startDate') required this.startDate,
    @JsonKey(name: 'endDate') this.endDate,
    final List<DateTime> specificDates = const [],
    this.note,
    @JsonKey(name: 'createdAt') this.createdAt,
  }) : _weekdays = weekdays,
       _specificDates = specificDates;

  factory _$MealModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MealModelImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String id;
  @override
  final String userId;
  @override
  final MealShift shift;
  @override
  @JsonKey()
  final bool isRecurring;
  final List<MealWeekday> _weekdays;
  @override
  @JsonKey()
  List<MealWeekday> get weekdays {
    if (_weekdays is EqualUnmodifiableListView) return _weekdays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weekdays);
  }

  @override
  @JsonKey(name: 'startDate')
  final DateTime startDate;
  @override
  @JsonKey(name: 'endDate')
  final DateTime? endDate;
  final List<DateTime> _specificDates;
  @override
  @JsonKey()
  List<DateTime> get specificDates {
    if (_specificDates is EqualUnmodifiableListView) return _specificDates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_specificDates);
  }

  @override
  final String? note;
  @override
  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'MealModel(id: $id, userId: $userId, shift: $shift, isRecurring: $isRecurring, weekdays: $weekdays, startDate: $startDate, endDate: $endDate, specificDates: $specificDates, note: $note, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.shift, shift) || other.shift == shift) &&
            (identical(other.isRecurring, isRecurring) ||
                other.isRecurring == isRecurring) &&
            const DeepCollectionEquality().equals(other._weekdays, _weekdays) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            const DeepCollectionEquality().equals(
              other._specificDates,
              _specificDates,
            ) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    shift,
    isRecurring,
    const DeepCollectionEquality().hash(_weekdays),
    startDate,
    endDate,
    const DeepCollectionEquality().hash(_specificDates),
    note,
    createdAt,
  );

  /// Create a copy of MealModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MealModelImplCopyWith<_$MealModelImpl> get copyWith =>
      __$$MealModelImplCopyWithImpl<_$MealModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MealModelImplToJson(this);
  }
}

abstract class _MealModel implements MealModel {
  const factory _MealModel({
    @JsonKey(name: '_id') required final String id,
    required final String userId,
    required final MealShift shift,
    final bool isRecurring,
    final List<MealWeekday> weekdays,
    @JsonKey(name: 'startDate') required final DateTime startDate,
    @JsonKey(name: 'endDate') final DateTime? endDate,
    final List<DateTime> specificDates,
    final String? note,
    @JsonKey(name: 'createdAt') final DateTime? createdAt,
  }) = _$MealModelImpl;

  factory _MealModel.fromJson(Map<String, dynamic> json) =
      _$MealModelImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String get id;
  @override
  String get userId;
  @override
  MealShift get shift;
  @override
  bool get isRecurring;
  @override
  List<MealWeekday> get weekdays;
  @override
  @JsonKey(name: 'startDate')
  DateTime get startDate;
  @override
  @JsonKey(name: 'endDate')
  DateTime? get endDate;
  @override
  List<DateTime> get specificDates;
  @override
  String? get note;
  @override
  @JsonKey(name: 'createdAt')
  DateTime? get createdAt;

  /// Create a copy of MealModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MealModelImplCopyWith<_$MealModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
