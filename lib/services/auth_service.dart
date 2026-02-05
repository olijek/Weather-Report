import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _usersKey = 'users_map'; // json map: {login: hash}

  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  static Future<Map<String, String>> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) return {};

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, v.toString()));
  }

  static Future<void> _saveUsers(Map<String, String> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  static Future<bool> register(String login, String password) async {
    final users = await _loadUsers();

    if (users.containsKey(login)) {
      return false;
    }

    final hash = hashPassword(password);
    users[login] = hash;

    await _saveUsers(users);
    return true;
  }

  static Future<bool> login(String login, String password) async {
    final users = await _loadUsers();

    if (!users.containsKey(login)) return false;

    final hash = hashPassword(password);
    return users[login] == hash;
  }
}
