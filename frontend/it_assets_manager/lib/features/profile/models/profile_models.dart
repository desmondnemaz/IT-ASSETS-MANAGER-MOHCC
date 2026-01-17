class UserProfileResponse {
  final Map<String, dynamic> user;
  final dynamic profile;

  UserProfileResponse({required this.user, required this.profile});

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    final profileJson = json['profile'];
    final userType = userJson['user_type'];

    dynamic profileData;
    if (userType == 'MOH') {
      profileData = MOHProfile.fromJson(profileJson);
    } else if (userType == 'NGO') {
      profileData = NGOProfile.fromJson(profileJson);
    }

    return UserProfileResponse(user: userJson, profile: profileData);
  }
}

class MOHProfile {
  final String department;
  final String position;
  final int? stationId;
  final String? stationName;
  final String? provinceName;
  final String? districtName;

  MOHProfile({
    required this.department,
    required this.position,
    this.stationId,
    this.stationName,
    this.provinceName,
    this.districtName,
  });

  factory MOHProfile.fromJson(Map<String, dynamic> json) {
    String? pName = json['province_name'] ?? json['province'];
    String? dName = json['district_name'] ?? json['district'];
    String? sName = json['station_name'];

    if (json['station'] is Map) {
      final station = json['station'] as Map<String, dynamic>;
      pName ??= station['province_name'] ?? station['province'];
      dName ??= station['district_name'] ?? station['district'];
      sName ??= station['station_name'];
    }

    return MOHProfile(
      department: json['department'] ?? '',
      position: json['position'] ?? '',
      stationId: json['station'] is int
          ? json['station']
          : json['station']?['id'],
      stationName: sName,
      provinceName: pName,
      districtName: dName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'department': department,
      'position': position,
      'station': stationId,
    };
  }
}

class NGOProfile {
  final String organizationName;
  final String position;

  NGOProfile({required this.organizationName, required this.position});

  factory NGOProfile.fromJson(Map<String, dynamic> json) {
    return NGOProfile(
      organizationName: json['organization_name'] ?? '',
      position: json['position'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'organization_name': organizationName, 'position': position};
  }
}
