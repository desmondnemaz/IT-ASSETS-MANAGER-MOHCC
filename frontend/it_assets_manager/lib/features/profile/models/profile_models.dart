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

  MOHProfile({
    required this.department,
    required this.position,
    this.stationId,
    this.stationName,
  });

  factory MOHProfile.fromJson(Map<String, dynamic> json) {
    return MOHProfile(
      department: json['department'] ?? '',
      position: json['position'] ?? '',
      stationId: json['station'],
      stationName:
          json['station_name'], // Assuming we might add this in the future or it exists
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
