import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../models/user_registration.dart';
import '../models/auth_request.dart';
import '../models/auth_response.dart';

import '../utils/constants.dart';

class AuthService with ChangeNotifier {
  static const String baseUrl = Constants.baseUrl;
  final _storage = const FlutterSecureStorage();
  
  String? _token;
  User? _currentUser;

  String? get token => _token;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _token != null;

  AuthService() {
    _loadSession();
  }

  /// Lädt gespeicherte Sitzungsdaten (Token & User) beim App-Start
  Future<void> _loadSession() async {
    try {
      _token = await _storage.read(key: 'jwt_token');
      final userJson = await _storage.read(key: 'user_data');
      if (userJson != null) {
        _currentUser = User.fromJson(jsonDecode(userJson));
      }
    } catch (e) {
      debugPrint('Fehler beim Laden der Sitzung: $e');
    } finally {
      notifyListeners();
    }
  }

  /// Registriert einen neuen Benutzer
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

  /// Meldet den Benutzer an und speichert das Token persistent
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

      await _storage.write(key: 'jwt_token', value: _token);
      if (_currentUser != null) {
        await _storage.write(key: 'user_data', value: jsonEncode(_currentUser!.toJson()));
      }

      notifyListeners();
      return authResponse;
    } else {
      throw Exception('Login fehlgeschlagen: ${response.body}');
    }
  }

  /// Ruft das aktuelle Benutzerprofil ab
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
      await _storage.write(key: 'user_data', value: jsonEncode(_currentUser!.toJson()));
      notifyListeners();
      return _currentUser!;
    } else {
      if (response.statusCode == 401) logout();
      throw Exception('Profil konnte nicht geladen werden');
    }
  }

  /// Löscht die Sitzungsdaten und meldet den Benutzer ab
  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_data');
    notifyListeners();
  }
}
