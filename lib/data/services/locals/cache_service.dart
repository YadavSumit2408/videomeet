import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract class CacheService {
  Future<void> cacheToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
  Future<void> cacheUsers(List<dynamic> usersJson);
  List<dynamic>? getCachedUsers();
  Future<void> clearCache();
}

class CacheServiceImpl implements CacheService {
  final SharedPreferences prefs;
  static const _tokenKey = 'auth_token';
  static const _cachedUsersKey = 'cached_users';

  CacheServiceImpl(this.prefs);

  @override
  Future<void> cacheToken(String token) async {
    await prefs.setString(_tokenKey, token);
  }

  @override
  Future<String?> getToken() async {
    return prefs.getString(_tokenKey);
  }

  @override
  Future<void> clearToken() async {
    await prefs.remove(_tokenKey);
  }

  @override
  Future<void> cacheUsers(List<dynamic> usersJson) async {
    await prefs.setString(_cachedUsersKey, jsonEncode(usersJson));
  }

  @override
  List<dynamic>? getCachedUsers() {
    final data = prefs.getString(_cachedUsersKey);
    if (data != null) {
      return jsonDecode(data) as List<dynamic>;
    }
    return null;
  }

  @override
  Future<void> clearCache() async {
    await prefs.clear();
  }
}