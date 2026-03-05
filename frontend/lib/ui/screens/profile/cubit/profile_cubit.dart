import 'package:injectable/injectable.dart';
import '../../../cubit/base_cubit.dart';
import '../../../../data/constant/enums.dart';
import '../../../../data/service/auth_service.dart';
import '../../../di/di_config.dart';
import '../../home/cubit/home_cubit.dart';
import '../../notifications/cubit/notification_cubit.dart';
import '../../main/cubit/main_cubit.dart';
import 'profile_state.dart';

@injectable
class ProfileCubit extends BaseCubit<ProfileState> {
  final AuthService _authService;

  ProfileCubit(this._authService)
    : super(ProfileState(user: _authService.currentUser));

  Future<void> logout() async {
    safeCall(() async {
      await _authService.logout();

      // Reset singleton cubits to clear state for the next user
      if (getIt.isRegistered<HomeCubit>()) {
        getIt.resetLazySingleton<HomeCubit>();
      }
      if (getIt.isRegistered<NotificationCubit>()) {
        getIt.resetLazySingleton<NotificationCubit>();
      }
      if (getIt.isRegistered<MainCubit>()) {
        getIt.resetLazySingleton<MainCubit>();
      }

      emit(state.copyWith(status: BaseStatus.success, user: null));
    });
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    safeCall(() async {
      await _authService.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      // Auto logout after changing password
      await _authService.logout();
      if (getIt.isRegistered<HomeCubit>()) {
        getIt.resetLazySingleton<HomeCubit>();
      }
      if (getIt.isRegistered<NotificationCubit>()) {
        getIt.resetLazySingleton<NotificationCubit>();
      }
      if (getIt.isRegistered<MainCubit>()) {
        getIt.resetLazySingleton<MainCubit>();
      }

      emit(state.copyWith(status: BaseStatus.success, user: null));
    });
  }

  Future<void> updateProfile({required String name}) async {
    safeCall(() async {
      await _authService.updateProfile(name: name);
      emit(
        state.copyWith(
          status: BaseStatus.success,
          user: _authService.currentUser,
        ),
      );
    });
  }

  Future<void> uploadAvatar(String filePath) async {
    safeCall(() async {
      await _authService.uploadAvatar(filePath);
      emit(
        state.copyWith(
          status: BaseStatus.success,
          user: _authService.currentUser,
        ),
      );
    });
  }
}
