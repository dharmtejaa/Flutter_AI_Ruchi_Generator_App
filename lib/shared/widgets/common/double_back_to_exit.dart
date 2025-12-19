import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A widget that requires the user to press back twice to exit the app.
/// Shows a message on the first back press.
///
/// Example usage:
/// ```dart
/// DoubleBackToExit(
///   message: 'Press back again to exit',
///   child: Scaffold(
///     body: YourContent(),
///   ),
/// )
/// ```
class DoubleBackToExit extends StatefulWidget {
  /// The child widget to wrap
  final Widget child;

  /// Message to show when the user presses back the first time
  final String message;

  /// Duration to wait before resetting the back press state (default: 2 seconds)
  final Duration exitDuration;

  const DoubleBackToExit({
    super.key,
    required this.child,
    this.message = 'Press back again to exit',
    this.exitDuration = const Duration(seconds: 2),
  });

  @override
  State<DoubleBackToExit> createState() => _DoubleBackToExitState();
}

class _DoubleBackToExitState extends State<DoubleBackToExit> {
  DateTime? _lastBackPressTime;

  Future<void> _handleBackPress() async {
    final now = DateTime.now();

    // Check if back was pressed within the exit duration
    if (_lastBackPressTime != null &&
        now.difference(_lastBackPressTime!) < widget.exitDuration) {
      // Haptic feedback before exit
      HapticFeedback.mediumImpact();
      // Exit the app properly
      SystemNavigator.pop();
    } else {
      // First back press - show message and update time
      _lastBackPressTime = now;
      HapticFeedback.lightImpact();
      _showExitMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress();
      },
      child: widget.child,
    );
  }

  void _showExitMessage() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.exit_to_app,
              color: Theme.of(context).colorScheme.onInverseSurface,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        duration: widget.exitDuration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
      ),
    );
  }
}
