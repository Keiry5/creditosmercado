enum UserType { admin, user }

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserType userType;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
  });
}