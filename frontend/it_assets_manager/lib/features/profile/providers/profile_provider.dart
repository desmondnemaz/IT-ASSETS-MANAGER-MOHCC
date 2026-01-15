import 'package:flutter/material.dart';
import '../data/profile_repository.dart';
import '../models/location_models.dart';
import '../models/profile_models.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository;

  ProfileProvider(this._repository);

  // Data Lists
  List<Province> _provinces = [];
  List<District> _districts = [];
  List<Station> _stations = [];
  UserProfileResponse? _userProfile;

  // Selections
  Province? _selectedProvince;
  District? _selectedDistrict;
  Station? _selectedStation;
  String? _selectedStationType; // 'HQ', 'PO', 'DO', 'FC'

  // State
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Province> get provinces => _provinces;
  List<District> get districts => _districts;
  List<Station> get stations => _stations;
  Province? get selectedProvince => _selectedProvince;
  District? get selectedDistrict => _selectedDistrict;
  Station? get selectedStation => _selectedStation;
  String? get selectedStationType => _selectedStationType;
  UserProfileResponse? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initial Load
  Future<void> loadProvinces() async {
    _isLoading = true;
    notifyListeners();
    try {
      _provinces = await _repository.getProvinces();
    } catch (e) {
      _errorMessage = "Failed to load provinces";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Setters & Cascading Logic

  void setStationType(String? type) {
    _selectedStationType = type;
    _selectedProvince = null;
    _selectedDistrict = null;
    _selectedStation = null;
    _districts = [];
    _stations = [];

    // If HQ, we assume National Office and might auto-fetch stations if needed,
    // but typically HQ might just need province selection (Harare) or direct station fetch.
    // implementing simplified logic: Type -> Province -> (District) -> Station

    notifyListeners();
  }

  Future<void> setSelectedProvince(Province? province) async {
    _selectedProvince = province;
    _selectedDistrict = null;
    _selectedStation = null;
    _districts = [];
    _stations = [];

    if (province != null) {
      // If type is HQ or PO, we might fetch stations directly valid for that province
      if (_selectedStationType == 'PO') {
        await _fetchStations(provinceId: province.id, type: 'PO');
      } else if (_selectedStationType == 'HQ') {
        await _fetchStations(provinceId: province.id, type: 'HQ');
      } else {
        // Fetch Districts for DO / Service Delivery (FC)
        await _fetchDistricts(province.id);
      }
    }
    notifyListeners();
  }

  Future<void> _fetchDistricts(int provinceId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _districts = await _repository.getDistricts(provinceId);
    } catch (e) {
      _errorMessage = "Failed to load districts";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setSelectedDistrict(District? district) async {
    _selectedDistrict = district;
    _selectedStation = null;
    _stations = [];

    if (district != null) {
      // Fetch Stations for this district
      await _fetchStations(districtId: district.id, type: _selectedStationType);
    }
    notifyListeners();
  }

  Future<void> _fetchStations({
    int? provinceId,
    int? districtId,
    String? type,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      _stations = await _repository.getStations(
        provinceId: provinceId,
        districtId: districtId,
        type: type,
      );
    } catch (e) {
      _errorMessage = "Failed to load stations";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedStation(Station? station) {
    _selectedStation = station;
    notifyListeners();
  }

  Future<bool> submitMOHProfile(String department, String position) async {
    if (_selectedStation == null) {
      _errorMessage = "Please select a station";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _repository.submitMOHProfile(
        department: department,
        position: position,
        stationId: _selectedStation!.id,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Failed to submit profile";
      notifyListeners();
      return false;
    }
  }

  Future<bool> submitNGOProfile(
    String organizationName,
    String position,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.submitNGOProfile(
        organizationName: organizationName,
        position: position,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Failed to submit profile";
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userProfile = await _repository.getProfile();
    } catch (e) {
      _errorMessage = "Failed to fetch profile";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateProfile(data);
      await fetchProfile(); // Refresh local data
      return true;
    } catch (e) {
      _errorMessage = "Failed to update profile";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAccountAndProfile({
    required Map<String, dynamic> accountData,
    required Map<String, dynamic> profileData,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Run both in parallel or sequence, sequence is safer for error handling
      await _repository.updateAccount(accountData);
      await _repository.updateProfile(profileData);
      await fetchProfile(); // Refresh local data
      return true;
    } catch (e) {
      _errorMessage = "Failed to update account or profile";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
