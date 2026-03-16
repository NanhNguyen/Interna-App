import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'api_client.dart';

@lazySingleton
class AnnouncementApi {
  final ApiClient _apiClient;

  AnnouncementApi(this._apiClient);

  Future<Response> getAnnouncements() {
    return _apiClient.get('/announcements');
  }

  Future<Response> createAnnouncement(Map<String, dynamic> data) {
    return _apiClient.post('/announcements', data: data);
  }

  Future<Response> markSeen(String id) {
    return _apiClient.patch('/announcements/$id/seen');
  }
}
