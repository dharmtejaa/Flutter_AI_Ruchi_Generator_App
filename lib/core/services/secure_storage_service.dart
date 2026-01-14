import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for securely storing sensitive data like tokens, usernames, and passwords.
/// Uses encrypted storage (Keychain on iOS, EncryptedSharedPreferences on Android).
///
/// Use this for:
/// - Authentication tokens
/// - User credentials (username, password)
/// - API keys (if stored locally)
/// - Any other sensitive data
///
/// For non-sensitive data like preferences, use SharedPreferences instead.
class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Keys for secure storage
  static const String _keyAuthToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUsername = 'username';
  static const String _keyPassword = 'password';
  static const String _keyUserId = 'user_id';
  static const String _keyApiKey = 'api_key';

  // ============================================================================
  // AUTH TOKEN OPERATIONS
  // ============================================================================

  /// Save authentication token securely
  static Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _keyAuthToken, value: token);
  }

  /// Get authentication token
  static Future<String?> getAuthToken() async {
    return await _storage.read(key: _keyAuthToken);
  }

  /// Delete authentication token
  static Future<void> deleteAuthToken() async {
    await _storage.delete(key: _keyAuthToken);
  }

  // ============================================================================
  // REFRESH TOKEN OPERATIONS
  // ============================================================================

  /// Save refresh token securely
  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _keyRefreshToken, value: token);
  }

  /// Get refresh token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  /// Delete refresh token
  static Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _keyRefreshToken);
  }

  // ============================================================================
  // USER CREDENTIALS OPERATIONS
  // ============================================================================

  /// Save username securely
  static Future<void> saveUsername(String username) async {
    await _storage.write(key: _keyUsername, value: username);
  }

  /// Get username
  static Future<String?> getUsername() async {
    return await _storage.read(key: _keyUsername);
  }

  /// Save password securely (only if "Remember Me" feature is needed)
  static Future<void> savePassword(String password) async {
    await _storage.write(key: _keyPassword, value: password);
  }

  /// Get password
  static Future<String?> getPassword() async {
    return await _storage.read(key: _keyPassword);
  }

  /// Save user ID securely
  static Future<void> saveUserId(String userId) async {
    await _storage.write(key: _keyUserId, value: userId);
  }

  /// Get user ID
  static Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  // ============================================================================
  // API KEY OPERATIONS
  // ============================================================================

  /// Save API key securely
  static Future<void> saveApiKey(String key) async {
    await _storage.write(key: _keyApiKey, value: key);
  }

  /// Get API key
  static Future<String?> getApiKey() async {
    return await _storage.read(key: _keyApiKey);
  }

  /// Delete API key
  static Future<void> deleteApiKey() async {
    await _storage.delete(key: _keyApiKey);
  }

  // ============================================================================
  // GENERIC OPERATIONS
  // ============================================================================

  /// Save any key-value pair securely
  static Future<void> saveSecure(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Read any secure value by key
  static Future<String?> readSecure(String key) async {
    return await _storage.read(key: key);
  }

  /// Delete a secure value by key
  static Future<void> deleteSecure(String key) async {
    await _storage.delete(key: key);
  }

  /// Check if a key exists in secure storage
  static Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  /// Get all stored keys (useful for debugging, use cautiously)
  static Future<Map<String, String>> getAllSecure() async {
    return await _storage.readAll();
  }

  // ============================================================================
  // CLEAR OPERATIONS
  // ============================================================================

  /// Clear all user credentials (on logout)
  static Future<void> clearUserCredentials() async {
    await _storage.delete(key: _keyUsername);
    await _storage.delete(key: _keyPassword);
    await _storage.delete(key: _keyUserId);
  }

  /// Clear all tokens (on logout)
  static Future<void> clearTokens() async {
    await _storage.delete(key: _keyAuthToken);
    await _storage.delete(key: _keyRefreshToken);
  }

  /// Clear all secure storage (complete logout)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // ============================================================================
  // AUTH STATE CHECK
  // ============================================================================

  /// Check if user is authenticated (has valid token)
  static Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  /// Check if credentials are stored (for "Remember Me" feature)
  static Future<bool> hasStoredCredentials() async {
    final username = await getUsername();
    final password = await getPassword();
    return username != null && password != null;
  }
}
