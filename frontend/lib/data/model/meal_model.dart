import 'package:freezed_annotation/freezed_annotation.dart';

part 'meal_model.freezed.dart';
part 'meal_model.g.dart';

enum MealShift { MORNING, AFTERNOON, BOTH }

enum MealWeekday { MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY }

extension MealWeekdayExtension on MealWeekday {
  String get displayName {
    switch (this) {
      case MealWeekday.MONDAY:
        return 'Thứ 2';
      case MealWeekday.TUESDAY:
        return 'Thứ 3';
      case MealWeekday.WEDNESDAY:
        return 'Thứ 4';
      case MealWeekday.THURSDAY:
        return 'Thứ 5';
      case MealWeekday.FRIDAY:
        return 'Thứ 6';
    }
  }

  int get weekdayNumber {
    switch (this) {
      case MealWeekday.MONDAY:
        return 1;
      case MealWeekday.TUESDAY:
        return 2;
      case MealWeekday.WEDNESDAY:
        return 3;
      case MealWeekday.THURSDAY:
        return 4;
      case MealWeekday.FRIDAY:
        return 5;
    }
  }
}

extension MealShiftExtension on MealShift {
  String get displayName {
    switch (this) {
      case MealShift.MORNING:
        return 'Bữa sáng';
      case MealShift.AFTERNOON:
        return 'Bữa trưa';
      case MealShift.BOTH:
        return 'Cả ngày';
    }
  }
}

@freezed
class MealModel with _$MealModel {
  const factory MealModel({
    @JsonKey(name: '_id') required String id,
    required String userId,
    required MealShift shift,
    @Default(false) bool isRecurring,
    @Default([]) List<MealWeekday> weekdays,
    @JsonKey(name: 'startDate') required DateTime startDate,
    @JsonKey(name: 'endDate') DateTime? endDate,
    @Default([]) List<DateTime> specificDates,
    String? note,
    @JsonKey(name: 'createdAt') DateTime? createdAt,
  }) = _MealModel;

  factory MealModel.fromJson(Map<String, dynamic> json) =>
      _$MealModelFromJson(json);
}
