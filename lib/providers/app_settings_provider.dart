import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for app-wide settings and preferences
class AppSettingsProvider with ChangeNotifier {
  static const String _keyShakeToScan = 'shake_to_scan_enabled';
  static const String _keyTtsEnabled = 'tts_enabled';
  static const String _keyTtsSpeed = 'tts_speed';
  static const String _keyTtsPitch = 'tts_pitch';
  static const String _keyTtsVoice = 'tts_voice';
  static const String _keyDefaultServings = 'default_servings';

  bool _shakeToScanEnabled = true;
  bool _ttsEnabled = true;
  double _ttsSpeed = 0.5;
  double _ttsPitch = 1.0;
  String? _ttsVoice;
  int _defaultServings = 4;

  bool _isLoading = true;

  // Getters
  bool get shakeToScanEnabled => _shakeToScanEnabled;
  bool get ttsEnabled => _ttsEnabled;
  double get ttsSpeed => _ttsSpeed;
  double get ttsPitch => _ttsPitch;
  String? get ttsVoice => _ttsVoice;
  int get defaultServings => _defaultServings;
  bool get isLoading => _isLoading;

  /// Load settings from SharedPreferences
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _shakeToScanEnabled = prefs.getBool(_keyShakeToScan) ?? true;
      _ttsEnabled = prefs.getBool(_keyTtsEnabled) ?? true;
      _ttsSpeed = prefs.getDouble(_keyTtsSpeed) ?? 0.5;
      _ttsPitch = prefs.getDouble(_keyTtsPitch) ?? 1.0;
      _ttsVoice = prefs.getString(_keyTtsVoice);
      _defaultServings = prefs.getInt(_keyDefaultServings) ?? 4;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set shake-to-scan feature enabled/disabled
  Future<void> setShakeToScanEnabled(bool enabled) async {
    _shakeToScanEnabled = enabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShakeToScan, enabled);
  }

  /// Set TTS enabled/disabled
  Future<void> setTtsEnabled(bool enabled) async {
    _ttsEnabled = enabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTtsEnabled, enabled);
  }

  /// Set TTS speech speed (0.0 to 1.0)
  Future<void> setTtsSpeed(double speed) async {
    _ttsSpeed = speed.clamp(0.0, 1.0);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyTtsSpeed, _ttsSpeed);
  }

  /// Set TTS pitch (0.5 to 2.0)
  Future<void> setTtsPitch(double pitch) async {
    _ttsPitch = pitch.clamp(0.5, 2.0);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyTtsPitch, _ttsPitch);
  }

  /// Set TTS voice
  Future<void> setTtsVoice(String? voice) async {
    _ttsVoice = voice;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    if (voice != null) {
      await prefs.setString(_keyTtsVoice, voice);
    } else {
      await prefs.remove(_keyTtsVoice);
    }
  }

  /// Set default servings
  Future<void> setDefaultServings(int servings) async {
    _defaultServings = servings.clamp(1, 20);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDefaultServings, _defaultServings);
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_keyShakeToScan);
    await prefs.remove(_keyTtsEnabled);
    await prefs.remove(_keyTtsSpeed);
    await prefs.remove(_keyTtsPitch);
    await prefs.remove(_keyTtsVoice);
    await prefs.remove(_keyDefaultServings);

    _shakeToScanEnabled = true;
    _ttsEnabled = true;
    _ttsSpeed = 0.5;
    _ttsPitch = 1.0;
    _ttsVoice = null;
    _defaultServings = 4;

    notifyListeners();
  }
}
