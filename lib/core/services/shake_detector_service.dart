import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Service for detecting phone shake gestures
class ShakeDetectorService {
  static final ShakeDetectorService _instance =
      ShakeDetectorService._internal();
  factory ShakeDetectorService() => _instance;
  ShakeDetectorService._internal();

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  /// Shake detection threshold (m/s²)
  static const double _shakeThreshold = 15.0;

  /// Minimum time between shake events (milliseconds)
  static const int _shakeCooldown = 1000;

  DateTime? _lastShakeTime;
  bool _isListening = false;

  /// Callback when shake is detected
  Function? onShakeDetected;

  bool get isListening => _isListening;

  /// Start listening for shake events
  void startListening({required Function onShake}) {
    if (_isListening) return;

    onShakeDetected = onShake;

    _accelerometerSubscription = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        _handleAccelerometerEvent(event);
      },
      onError: (error) {
        if (kDebugMode) {
          print('Accelerometer error: $error');
        }
      },
    );

    _isListening = true;
  }

  /// Stop listening for shake events
  void stopListening() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _isListening = false;
    onShakeDetected = null;
  }

  void _handleAccelerometerEvent(AccelerometerEvent event) {
    // Calculate total acceleration magnitude
    final double acceleration = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    // Remove gravity (~9.8 m/s²) and check if above threshold
    final double adjustedAcceleration = (acceleration - 9.8).abs();

    if (adjustedAcceleration > _shakeThreshold) {
      _triggerShake();
    }
  }

  void _triggerShake() {
    final now = DateTime.now();

    // Check cooldown to prevent multiple rapid triggers
    if (_lastShakeTime != null) {
      final timeSinceLastShake = now.difference(_lastShakeTime!).inMilliseconds;
      if (timeSinceLastShake < _shakeCooldown) {
        return;
      }
    }

    _lastShakeTime = now;
    onShakeDetected?.call();

    if (kDebugMode) {
      print('Shake detected!');
    }
  }

  /// Dispose resources
  void dispose() {
    stopListening();
  }
}
