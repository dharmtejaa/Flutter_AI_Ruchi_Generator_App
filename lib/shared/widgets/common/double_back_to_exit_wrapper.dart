import 'package:ai_ruchi/shared/widgets/common/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A widget that prevents accidental app exit by requiring double back press.
/// Shows a snackbar message on first back press asking user to press again to exit.
class DoubleBackToExitWrapper extends StatefulWidget {
  final Widget child;
  final String message;
  final Duration exitDuration;

  const DoubleBackToExitWrapper({
    super.key,
    required this.child,
    this.message = 'Press back again to exit',
    this.exitDuration = const Duration(seconds: 2),
  });

  @override
  State<DoubleBackToExitWrapper> createState() =>
      _DoubleBackToExitWrapperState();
}

class _DoubleBackToExitWrapperState extends State<DoubleBackToExitWrapper> {
  DateTime? _lastBackPressTime;

  Future<bool> _handleBackPress() async {
    final now = DateTime.now();

    // Check if back was pressed within the exit duration
    if (_lastBackPressTime != null &&
        now.difference(_lastBackPressTime!) < widget.exitDuration) {
      // Haptic feedback for exit
      HapticFeedback.mediumImpact();
      // Exit the app
      SystemNavigator.pop();
      return true;
    }

    // First back press - show message and record time
    _lastBackPressTime = now;

    // Haptic feedback for warning
    HapticFeedback.selectionClick();

    // Show snackbar message
    if (mounted) {
      CustomSnackBar.showInfo(context, widget.message);
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBackPress();
        }
      },
      child: widget.child,
    );
  }
}
