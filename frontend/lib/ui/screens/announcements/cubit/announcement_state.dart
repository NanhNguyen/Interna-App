import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../data/constant/enums.dart';
import '../../../../data/model/announcement_model.dart';

part 'announcement_state.freezed.dart';

@freezed
class AnnouncementState with _$AnnouncementState {
  const factory AnnouncementState({
    @Default(BaseStatus.initial) BaseStatus status,
    @Default(BaseStatus.initial) BaseStatus submitStatus,
    @Default([]) List<AnnouncementModel> announcements,
    String? errorMessage,
  }) = _AnnouncementState;
}
