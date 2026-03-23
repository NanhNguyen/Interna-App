import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../data/constant/enums.dart';
import '../../../../data/model/user_model.dart';
import '../../../../data/model/schedule_request_model.dart';

part 'home_state.freezed.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    @Default(BaseStatus.initial) BaseStatus status,
    String? errorMessage,
    UserModel? user,
    @Default(0) int pendingCount,
    @Default(0) int mealCountToday,
    @Default(false) bool isMealRegisteredToday,
    ScheduleRequestModel? todaySchedule,
  }) = _HomeState;
}
