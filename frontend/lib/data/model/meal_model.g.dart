// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MealModelImpl _$$MealModelImplFromJson(Map<String, dynamic> json) =>
    _$MealModelImpl(
      id: json['_id'] as String,
      userId: json['userId'] as String,
      shift: $enumDecode(_$MealShiftEnumMap, json['shift']),
      isRecurring: json['isRecurring'] as bool? ?? false,
      weekdays:
          (json['weekdays'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$MealWeekdayEnumMap, e))
              .toList() ??
          const [],
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      specificDates:
          (json['specificDates'] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e as String))
              .toList() ??
          const [],
      note: json['note'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$MealModelImplToJson(
  _$MealModelImpl instance,
) => <String, dynamic>{
  '_id': instance.id,
  'userId': instance.userId,
  'shift': _$MealShiftEnumMap[instance.shift]!,
  'isRecurring': instance.isRecurring,
  'weekdays': instance.weekdays.map((e) => _$MealWeekdayEnumMap[e]!).toList(),
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'specificDates': instance.specificDates
      .map((e) => e.toIso8601String())
      .toList(),
  'note': instance.note,
  'createdAt': instance.createdAt?.toIso8601String(),
};

const _$MealShiftEnumMap = {
  MealShift.MORNING: 'MORNING',
  MealShift.AFTERNOON: 'AFTERNOON',
  MealShift.BOTH: 'BOTH',
};

const _$MealWeekdayEnumMap = {
  MealWeekday.MONDAY: 'MONDAY',
  MealWeekday.TUESDAY: 'TUESDAY',
  MealWeekday.WEDNESDAY: 'WEDNESDAY',
  MealWeekday.THURSDAY: 'THURSDAY',
  MealWeekday.FRIDAY: 'FRIDAY',
};
