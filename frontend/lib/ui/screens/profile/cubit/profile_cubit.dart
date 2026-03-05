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
    setLoading();
    try {
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

      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> changePassword(String newPassword) async {
    setLoading();
    try {
      await _authService.changePassword(newPassword);
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> updateProfile({required String name}) async {
    setLoading();
    try {
      await _authService.updateProfile(name: name);
      emit(
        state.copyWith(
          status: BaseStatus.success,
          user: _authService.currentUser,
        ),
      );
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> uploadAvatar(String filePath) async {
    setLoading();
    try {
      await _authService.uploadAvatar(filePath);
      emit(
        state.copyWith(
          status: BaseStatus.success,
          user: _authService.currentUser,
        ),
      );
    } catch (e) {
      setError(e.toString());
    }
  }
}
