import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'api_client.dart';

@lazySingleton
class UserApi {
  final ApiClient _apiClient;

  UserApi(this._apiClient);

  Future<Response> updateProfile({required String name}) {
    return _apiClient.post('/users/update-profile', data: {'name': name});
  }

  Future<Response> uploadAvatar(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });

    return _apiClient.post('/users/upload-avatar', data: formData);
  }
}
