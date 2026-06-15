import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/user_registration.dart';
import '../models/auth_request.dart';
import '../models/auth_response.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8080';
  String? _token;
  User? _currentUser;

  String? get token => _token;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _token != null;

  Future<User> register(UserRegistration registration) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(registration.toJson()),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Registrierung fehlgeschlagen: ${response.body}');
    }
  }

  Future<AuthResponse> login(String email, String password) async {
    final authRequest = AuthRequest(email: email, password: password);
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(authRequest.toJson()),
    );

    if (response.statusCode == 200) {
      final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
      _token = authResponse.token;
      _currentUser = authResponse.user;
      return authResponse;
    } else {
      throw Exception('Login fehlgeschlagen: ${response.body}');
    }
  }

  Future<User> getProfile() async {
    if (_token == null) throw Exception('Nicht authentifiziert');

    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      _currentUser = User.fromJson(jsonDecode(response.body));
      return _currentUser!;
    } else {
      throw Exception('Profil konnte nicht geladen werden');
    }
  }

  void logout() {
    _token = null;
    _currentUser = null;
  }
}
