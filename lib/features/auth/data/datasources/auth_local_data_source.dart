import 'dart:convert';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/user_model.dart';

class AuthLocalDataSource {
  final SecureStorageService _secureStorage;

  AuthLocalDataSource(this._secureStorage);

  Future<void> saveUserSession(UserModel user) async {
    await _secureStorage.saveToken(user.token);
    await _secureStorage.saveUserJson(jsonEncode(user.toJson()));
  }

  Future<UserModel?> getUserSession() async {
    final token = await _secureStorage.getToken();
    final userJson = await _secureStorage.getUserJson();
    if (token == null || userJson == null) return null;
    try {
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSession() async {
    await _secureStorage.clearSession();
  }

  Future<bool> hasValidToken() async {
    final token = await _secureStorage.getToken();
    return token != null && token.isNotEmpty;
  }
}
