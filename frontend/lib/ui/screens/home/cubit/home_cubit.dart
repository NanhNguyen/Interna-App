import 'package:injectable/injectable.dart';
import '../../../cubit/base_cubit.dart';
import '../../../../data/constant/enums.dart';
import '../../../../data/service/auth_service.dart';
import '../../../../data/repo/notification_repo.dart';
import '../../../../data/repo/schedule_request_repo.dart';
import '../../../../data/model/schedule_request_model.dart';
import '../../../di/di_config.dart';
import '../../notifications/cubit/notification_cubit.dart';
import '../../../../data/repo/meal_repo.dart';
import '../../../../data/model/meal_model.dart';
import 'home_state.dart';

@lazySingleton
class HomeCubit extends BaseCubit<HomeState> {
  final ScheduleRequestRepo _scheduleRepo;
  final NotificationRepo _notificationRepo;
  final MealRepo _mealRepo;
  final AuthService _authService;

  HomeCubit(this._authService, this._scheduleRepo, this._notificationRepo, this._mealRepo)
    : super(HomeState(user: _authService.currentUser));

  Future<void> loadData() async {
    safeCall(() async {
      final currentUser = _authService.currentUser;
      final isManagerOrHR =
          currentUser?.role == UserRole.MANAGER ||
          currentUser?.role == UserRole.HR;

      final notifCubit = getIt<NotificationCubit>();
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));

      final results = await Future.wait([
        if (!isManagerOrHR)
          _scheduleRepo.getMySchedules()
        else
          Future.value(<ScheduleRequestModel>[]),
        notifCubit.loadNotifications(),
        if (isManagerOrHR)
          _scheduleRepo.getAllSchedules()
        else
          Future.value(<ScheduleRequestModel>[]),
        // Meals
        if (isManagerOrHR)
          _mealRepo.getOverview(now)
        else
          _mealRepo.getMyMeals(),
      ]);

      final mySchedules = results[0] as List<ScheduleRequestModel>;
      final allSchedules = results[2] as List<ScheduleRequestModel>;
      final meals = results[3] as List<MealModel>;

      // Pending count
      final schedulesForCount = isManagerOrHR ? allSchedules : mySchedules;
      final pendingCount = schedulesForCount
          .where((s) => s.status == RequestStatus.PENDING)
          .toList()
          .groupByGroupId()
          .length;

      // Meal info
      int mealCountToday = 0;
      bool isMealRegisteredToday = false;

      if (isManagerOrHR) {
        mealCountToday = meals.length;
      } else {
        isMealRegisteredToday = meals.any((m) {
          if (m.isRecurring) {
            final todayWeekday = now.weekday - 1; // 0=Mon, 1=Tue...
            return m.weekdays.any((w) => w.index == todayWeekday);
          } else {
            return m.specificDates.any((d) => 
               d.year == now.year && d.month == now.month && d.day == now.day);
          }
        });
      }

      emit(
        state.copyWith(
          status: BaseStatus.success,
          user: currentUser,
          pendingCount: pendingCount,
          mealCountToday: mealCountToday,
          isMealRegisteredToday: isMealRegisteredToday,
          todaySchedule: null, // Removed as per user request
        ),
      );
    });
  }
}
