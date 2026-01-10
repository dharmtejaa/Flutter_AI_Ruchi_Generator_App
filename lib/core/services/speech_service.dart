import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  static final SpeechService _instance = SpeechService._internal();

  factory SpeechService() {
    return _instance;
  }

  SpeechService._internal();

  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  Function(String)? _onStatus;
  Function(dynamic)? _onError;

  bool get isListening => _speechToText.isListening;
  bool get isAvailable => _isInitialized;

  Future<bool> initialize({
    Function(String)? onStatus,
    Function(dynamic)? onError,
  }) async {
    _onStatus = onStatus;
    _onError = onError;

    if (_isInitialized) return true;

    try {
      _isInitialized = await _speechToText.initialize(
        onError: (error) {
          debugPrint('Speech detection error: $error');
          _onError?.call(error);
        },
        onStatus: (status) {
          debugPrint('Speech status: $status');
          _onStatus?.call(status);
        },
      );
    } catch (e) {
      debugPrint('Speech initialization failed: $e');
      _isInitialized = false;
    }
    return _isInitialized;
  }

  Future<void> startListening({
    required Function(String) onResult,
    String? localeId,
  }) async {
    if (!_isInitialized) {
      final available = await initialize();
      if (!available) return;
    }

    if (_speechToText.isNotListening) {
      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            onResult(result.recognizedWords);
          }
        },
        localeId: localeId,
        pauseFor: const Duration(seconds: 3),
      );
    }
  }

  Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
  }

  Future<void> cancelListening() async {
    if (_speechToText.isListening) {
      await _speechToText.cancel();
    }
  }
}
