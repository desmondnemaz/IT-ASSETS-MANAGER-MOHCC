import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/admin_models.dart';

class AdminRepository {
  final DioClient _dioClient;

  AdminRepository(this._dioClient);

  Future<List<AdminUser>> fetchUsers() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.adminUserList);
      final List<dynamic> data = response.data;
      return data.map((json) => AdminUser.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(int userId, String newPassword) async {
    try {
      await _dioClient.dio.patch(
        ApiConstants.adminResetPassword(userId),
        data: {'new_password': newPassword},
      );
    } catch (e) {
      rethrow;
    }
  }
}
