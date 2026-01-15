import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/user_model.dart';

class AuthRepository {
  final DioClient _dioClient;
  final FlutterSecureStorage _storage;

  AuthRepository(this._dioClient, this._storage);

  Future<User> login(String username, String password) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.login,
        data: {'username': username, 'password': password},
      );

      final data = response.data;
      final tokens = data['tokens'];
      final userJson = data['user'];

      // Save Tokens
      await _storage.write(key: 'access_token', value: tokens['access']);
      await _storage.write(key: 'refresh_token', value: tokens['refresh']);

      return User.fromJson(userJson);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String nationalId,
    required String userType,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      await _dioClient.dio.post(
        ApiConstants.register,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'username': username,
          'email': email,
          'national_id': nationalId,
          'user_type': userType,
          'password': password,
          'password2': confirmPassword,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.profileMe);
      // The endpoint returns { "user": {...}, "profile": {...} }
      // We map the "user" part to our User model
      return User.fromJson(response.data['user']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }
}
