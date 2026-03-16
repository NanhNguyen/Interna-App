import '../model/announcement_model.dart';

abstract class AnnouncementRepo {
  Future<List<AnnouncementModel>> getAnnouncements();
  Future<AnnouncementModel> createAnnouncement(Map<String, dynamic> data);
  Future<void> markSeen(String id);
}
