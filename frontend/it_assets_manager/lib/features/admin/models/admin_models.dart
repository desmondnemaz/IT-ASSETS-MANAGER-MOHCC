import 'package:equatable/equatable.dart';

class AdminUser extends Equatable {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String userType;
  final bool isAdmin;

  const AdminUser({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.userType,
    required this.isAdmin,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as int,
      username: json['username'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      userType: json['user_type'] as String,
      isAdmin: json['is_admin'] as bool,
    );
  }

  @override
  List<Object?> get props => [
    id,
    username,
    firstName,
    lastName,
    email,
    userType,
    isAdmin,
  ];

  String get fullName => "$firstName $lastName";
}
