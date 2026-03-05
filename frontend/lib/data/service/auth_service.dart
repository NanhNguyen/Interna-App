import 'package:injectable/injectable.dart';
import '../../foundation/storage/token_storage.dart';
import '../model/user_model.dart';
import '../repo/auth_repo.dart';
import '../repo/user_repo.dart';

@lazySingleton
class AuthService {
  final AuthRepo _authRepo;
  final UserRepo _userRepo;
  final TokenStorage _tokenStorage;
  UserModel? _currentUser;

  AuthService(this._authRepo, this._userRepo, this._tokenStorage);

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<void> initialize() async {
    final token = await _tokenStorage.getAccessToken();
    if (token != null) {
      try {
        _currentUser = await _authRepo.getProfile();
      } catch (e) {
        // If token is invalid/expired, we might want to clear it
        await _tokenStorage.clearTokens();
      }
    }
  }

  Future<void> login(String email, String password) async {
    _currentUser = await _authRepo.login(email, password);
  }

  Future<void> logout() async {
    await _authRepo.logout();
    _currentUser = null;
  }

  Future<void> changePassword(String newPassword) async {
    await _authRepo.changePassword(newPassword);
  }

  Future<void> updateProfile({required String name}) async {
    _currentUser = await _userRepo.updateProfile(name: name);
  }

  Future<void> uploadAvatar(String filePath) async {
    _currentUser = await _userRepo.uploadAvatar(filePath);
  }
}
