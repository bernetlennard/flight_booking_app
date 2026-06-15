class UserRegistration {
  final String name;
  final String email;
  final String password;

  UserRegistration({
    required this.name,
    required this.email,
    required this.password,
  });

  factory UserRegistration.fromJson(Map<String, dynamic> json) {
    return UserRegistration(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
    };
  }
}
