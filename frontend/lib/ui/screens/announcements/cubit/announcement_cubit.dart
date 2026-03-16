import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../data/constant/enums.dart';
import '../../../../data/repo/announcement_repo.dart';
import 'announcement_state.dart';

@injectable
class AnnouncementCubit extends Cubit<AnnouncementState> {
  final AnnouncementRepo _repo;

  AnnouncementCubit(this._repo) : super(const AnnouncementState());

  Future<void> loadAnnouncements() async {
    emit(state.copyWith(status: BaseStatus.loading));
    try {
      final items = await _repo.getAnnouncements();
      emit(state.copyWith(status: BaseStatus.success, announcements: items));
    } catch (e) {
      emit(
        state.copyWith(status: BaseStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<bool> createAnnouncement(String title, String content) async {
    emit(state.copyWith(submitStatus: BaseStatus.loading));
    try {
      final newItem = await _repo.createAnnouncement({
        'title': title,
        'content': content,
      });
      emit(
        state.copyWith(
          submitStatus: BaseStatus.success,
          announcements: [newItem, ...state.announcements],
        ),
      );
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          submitStatus: BaseStatus.error,
          errorMessage: 'Đăng thông báo thất bại: $e',
        ),
      );
      return false;
    }
  }

  Future<void> markSeen(String id) async {
    try {
      await _repo.markSeen(id);
    } catch (_) {}
  }
}
