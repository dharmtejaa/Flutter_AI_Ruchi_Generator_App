import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Service for handling Text-to-Speech functionality for recipe instructions
class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();

  bool _isInitialized = false;
  bool _isSpeaking = false;
  String? _currentText;

  // Settings
  double _speechRate = 0.5; // 0.0 to 1.0
  double _pitch = 1.0; // 0.5 to 2.0
  double _volume = 1.0; // 0.0 to 1.0
  String? _selectedVoice;

  // Callbacks
  Function(String)? onStart;
  Function(String)? onComplete;
  Function(String)? onError;

  bool get isSpeaking => _isSpeaking;
  double get speechRate => _speechRate;
  double get pitch => _pitch;
  double get volume => _volume;
  String? get selectedVoice => _selectedVoice;

  /// Initialize TTS engine
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setPitch(_pitch);
      await _flutterTts.setVolume(_volume);

      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        onStart?.call(_currentText ?? '');
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        onComplete?.call(_currentText ?? '');
        _currentText = null;
      });

      _flutterTts.setErrorHandler((message) {
        _isSpeaking = false;
        onError?.call(message.toString());
        if (kDebugMode) {
          print('TTS Error: $message');
        }
      });

      _flutterTts.setCancelHandler(() {
        _isSpeaking = false;
        _currentText = null;
      });

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('TTS initialization error: $e');
      }
    }
  }

  /// Get available voices
  Future<List<Map<String, String>>> getAvailableVoices() async {
    try {
      final voices = await _flutterTts.getVoices;
      if (voices == null) return [];

      return (voices as List)
          .where(
            (voice) => voice['locale']?.toString().startsWith('en') ?? false,
          )
          .map(
            (voice) => {
              'name': voice['name']?.toString() ?? 'Unknown',
              'locale': voice['locale']?.toString() ?? 'en-US',
            },
          )
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting voices: $e');
      }
      return [];
    }
  }

  /// Speak the given text
  Future<void> speak(String text) async {
    if (!_isInitialized) await initialize();

    // Stop any ongoing speech
    if (_isSpeaking) {
      await stop();
    }

    _currentText = text;
    await _flutterTts.speak(text);
  }

  /// Stop speaking
  Future<void> stop() async {
    await _flutterTts.stop();
    _isSpeaking = false;
    _currentText = null;
  }

  /// Pause speaking (if supported)
  Future<void> pause() async {
    await _flutterTts.pause();
    _isSpeaking = false;
  }

  /// Set speech rate (0.0 to 1.0)
  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate.clamp(0.0, 1.0);
    await _flutterTts.setSpeechRate(_speechRate);
  }

  /// Set pitch (0.5 to 2.0)
  Future<void> setPitch(double pitch) async {
    _pitch = pitch.clamp(0.5, 2.0);
    await _flutterTts.setPitch(_pitch);
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _flutterTts.setVolume(_volume);
  }

  /// Set voice by name
  Future<void> setVoice(String voiceName, String locale) async {
    _selectedVoice = voiceName;
    await _flutterTts.setVoice({'name': voiceName, 'locale': locale});
  }

  /// Clean up resources
  Future<void> dispose() async {
    await stop();
  }
}
