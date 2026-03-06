import 'package:injectable/injectable.dart';
import '../api/api_client.dart';

@lazySingleton
class UserService {
  final ApiClient _apiClient;

  UserService(this._apiClient);

  Future<List<Map<String, dynamic>>> getManagers() async {
    final response = await _apiClient.get('users/managers');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<void> createAccount({
    required String name,
    required String email,
    required String password,
    required String role,
    String? managerId,
  }) async {
    await _apiClient.post(
      'users/create-account',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'managerId': ?managerId,
      },
    );
  }
}
