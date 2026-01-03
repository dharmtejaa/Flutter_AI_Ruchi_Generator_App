import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Service to handle haptic feedback throughout the app.
/// "Forces" vibration even if system touch haptics are disabled
/// by using the Vibration package to access hardware directly where possible.
class HapticService {
  /// Toggle to globally enable/disable if we want specific app control later.
  static bool isEnabled = true;

  /// Trigger a light impact (e.g. for simple taps, navigation).
  static Future<void> lightImpact() async {
    if (!isEnabled) return;

    // Check for custom vibrator capabilities
    final hasVibrator = await Vibration.hasVibrator();
    final hasAmplitudeControl = await Vibration.hasAmplitudeControl() || false;

    if (hasVibrator) {
      if (hasAmplitudeControl) {
        // Use amplitude to create a crisp "light" feel
        // 30ms duration with ~25% intensity (64/255)
        Vibration.vibrate(duration: 30, amplitude: 60);
      } else {
        // Fallback for devices without amplitude control
        // Slightly longer duration to ensure the motor actually spins up
        Vibration.vibrate(duration: 30);
      }
    } else {
      // Last resort: System fallback
      HapticFeedback.lightImpact();
    }
  }

  /// Trigger a medium impact (e.g. for success actions).
  static Future<void> mediumImpact() async {
    if (!isEnabled) return;

    final hasVibrator = await Vibration.hasVibrator();
    final hasAmplitudeControl = await Vibration.hasAmplitudeControl();

    if (hasVibrator) {
      if (hasAmplitudeControl) {
        // 40ms duration with ~50% intensity
        Vibration.vibrate(duration: 40, amplitude: 128);
      } else {
        Vibration.vibrate(duration: 50);
      }
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  /// Trigger a heavy impact (e.g. for errors or deletes).
  static Future<void> heavyImpact() async {
    if (!isEnabled) return;

    final hasVibrator = await Vibration.hasVibrator();

    if (hasVibrator) {
      // Full power
      Vibration.vibrate(duration: 100);
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  /// Trigger a selection click (e.g. extensively used in scrollers/pickers).
  static Future<void> selectionClick() async {
    if (!isEnabled) return;

    final hasVibrator = await Vibration.hasVibrator();
    final hasAmplitudeControl = await Vibration.hasAmplitudeControl();

    if (hasVibrator) {
      if (hasAmplitudeControl) {
        // Very sharp, low intensity click
        Vibration.vibrate(duration: 15, amplitude: 40);
      } else {
        Vibration.vibrate(duration: 20);
      }
    } else {
      HapticFeedback.selectionClick();
    }
  }
}
