import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../data/constant/enums.dart';
import '../../../../data/model/meal_model.dart';

part 'meal_state.freezed.dart';

@freezed
class MealState with _$MealState {
  const factory MealState({
    @Default(BaseStatus.initial) BaseStatus status,
    @Default(BaseStatus.initial) BaseStatus submitStatus,
    @Default([]) List<MealModel> meals,
    String? errorMessage,
  }) = _MealState;
}
