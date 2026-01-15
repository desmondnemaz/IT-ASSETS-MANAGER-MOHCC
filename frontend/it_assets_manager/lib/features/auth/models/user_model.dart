class User {
  final int id;
  final String username;
  final String email;
  final String userType;
  final bool profileComplete;
  final bool isAdmin;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.userType,
    required this.profileComplete,
    required this.isAdmin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      userType: json['user_type'],
      profileComplete: json['profile_complete'],
      isAdmin: json['is_admin'] ?? false,
    );
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? userType,
    bool? profileComplete,
    bool? isAdmin,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      profileComplete: profileComplete ?? this.profileComplete,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
