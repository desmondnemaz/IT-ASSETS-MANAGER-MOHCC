import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../data/auth_repository.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthProvider(this._authRepository);

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _user != null;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authRepository.login(username, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _isLoading = false;
      if (e.response != null && e.response?.data is Map) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(
          e.response!.data,
        );
        if (data.containsKey('detail')) {
          _errorMessage = data['detail'].toString();
        } else if (data.containsKey('non_field_errors')) {
          _errorMessage = (data['non_field_errors'] as List).join('\n');
        } else {
          // Join all errors from all fields
          _errorMessage = data.entries
              .map(
                (entry) =>
                    "${entry.key}: ${entry.value is List ? (entry.value as List).join(', ') : entry.value}",
              )
              .join('\n');
        }
      } else if (e.response != null) {
        _errorMessage = "Server error: ${e.response?.statusCode}";
      } else {
        _errorMessage =
            "Connection error. Please check your internet or server status.";
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String nationalId,
    required String userType,
    required String password,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.register(
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        nationalId: nationalId,
        userType: userType,
        password: password,
        confirmPassword: confirmPassword,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      if (e is DioException) {
        if (e.response?.data is Map) {
          final data = e.response!.data as Map;
          _errorMessage = data.values
              .map((v) => v is List ? v.join(' ') : v)
              .join('\n');
        } else {
          _errorMessage = e.response?.data?.toString() ?? "Registration failed";
        }
      } else {
        _errorMessage = e.toString();
      }
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _user = null;
    notifyListeners();
  }

  Future<bool> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = await _authRepository.getCurrentUser();
      _user = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _user = null;
      notifyListeners();
      return false;
    }
  }

  void markProfileComplete() {
    if (_user != null) {
      _user = _user!.copyWith(profileComplete: true);
      notifyListeners();
    }
  }
}
