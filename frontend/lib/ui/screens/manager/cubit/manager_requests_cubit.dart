import 'package:injectable/injectable.dart';
import '../../../cubit/base_cubit.dart';
import '../../../../data/constant/enums.dart';
import '../../../../data/repo/schedule_request_repo.dart';
import '../../../di/di_config.dart';
import '../../home/cubit/home_cubit.dart';
import 'manager_requests_state.dart';

@injectable
class ManagerRequestsCubit extends BaseCubit<ManagerRequestsState> {
  final ScheduleRequestRepo _scheduleRepo;

  ManagerRequestsCubit(this._scheduleRepo)
    : super(const ManagerRequestsState());

  Future<void> loadAllRequests() async {
    setLoading();
    try {
      final res = await _scheduleRepo.getAllSchedules();
      emit(
        state.copyWith(
          status: BaseStatus.success,
          requests: res,
          actionResult: null,
        ),
      );
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> approveRequest(String id) async {
    try {
      await _scheduleRepo.updateStatus(id, 'APPROVED');
      // Emit actionResult FIRST so listener fires before reload resets state
      emit(state.copyWith(actionResult: 'APPROVED'));
      _reloadAfterAction();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> rejectRequest(String id) async {
    try {
      await _scheduleRepo.updateStatus(id, 'REJECTED');
      emit(state.copyWith(actionResult: 'REJECTED'));
      _reloadAfterAction();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> approveBatch(String groupId) async {
    try {
      await _scheduleRepo.updateBatchStatus(groupId, 'APPROVED');
      emit(state.copyWith(actionResult: 'APPROVED'));
      _reloadAfterAction();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> rejectBatch(String groupId) async {
    try {
      await _scheduleRepo.updateBatchStatus(groupId, 'REJECTED');
      emit(state.copyWith(actionResult: 'REJECTED'));
      _reloadAfterAction();
    } catch (e) {
      setError(e.toString());
    }
  }

  /// Reload data in background without blocking the UI or overwriting actionResult
  void _reloadAfterAction() {
    Future.microtask(() async {
      try {
        final res = await _scheduleRepo.getAllSchedules();
        // Only update requests list, preserve actionResult
        emit(state.copyWith(status: BaseStatus.success, requests: res));
        getIt<HomeCubit>().loadData();
      } catch (_) {}
    });
  }
}
