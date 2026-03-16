import 'package:injectable/injectable.dart';
import '../api/announcement_api.dart';
import '../model/announcement_model.dart';
import 'announcement_repo.dart';

@LazySingleton(as: AnnouncementRepo)
class AnnouncementRepoImpl implements AnnouncementRepo {
  final AnnouncementApi _api;

  AnnouncementRepoImpl(this._api);

  @override
  Future<List<AnnouncementModel>> getAnnouncements() async {
    final response = await _api.getAnnouncements();
    final List<dynamic> data = response.data;
    return data.map((json) => AnnouncementModel.fromJson(json)).toList();
  }

  @override
  Future<AnnouncementModel> createAnnouncement(
    Map<String, dynamic> data,
  ) async {
    final response = await _api.createAnnouncement(data);
    return AnnouncementModel.fromJson(response.data);
  }

  @override
  Future<void> markSeen(String id) async {
    await _api.markSeen(id);
  }
}
