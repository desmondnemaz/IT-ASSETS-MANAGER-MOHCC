import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/location_models.dart';
import '../models/profile_models.dart';

class ProfileRepository {
  final DioClient _dioClient;

  ProfileRepository(this._dioClient);

  Future<List<Province>> getProvinces() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.provinces);
      return (response.data as List).map((e) => Province.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<District>> getDistricts(int provinceId) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.districts,
        queryParameters: {'province_id': provinceId},
      );
      return (response.data as List).map((e) => District.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Station>> getStations({
    int? districtId,
    int? provinceId,
    String? type,
  }) async {
    try {
      final Map<String, dynamic> query = {};
      if (districtId != null) query['district_id'] = districtId;
      if (provinceId != null) query['province_id'] = provinceId;
      if (type != null) query['type'] = type;

      final response = await _dioClient.dio.get(
        ApiConstants.stations,
        queryParameters: query,
      );
      return (response.data as List).map((e) => Station.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> submitMOHProfile({
    required String department,
    required String position,
    required int stationId,
  }) async {
    await _dioClient.dio.post(
      ApiConstants.finishProfile,
      data: {
        'department': department,
        'position': position,
        'station': stationId,
      },
    );
  }

  Future<void> submitNGOProfile({
    required String organizationName,
    required String position,
  }) async {
    await _dioClient.dio.post(
      ApiConstants.finishProfile,
      data: {'organization_name': organizationName, 'position': position},
    );
  }

  Future<UserProfileResponse> getProfile() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.profileMe);
      return UserProfileResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      await _dioClient.dio.put(ApiConstants.updateProfile, data: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateAccount(Map<String, dynamic> data) async {
    try {
      await _dioClient.dio.put(ApiConstants.updateAccount, data: data);
    } catch (e) {
      rethrow;
    }
  }
}
