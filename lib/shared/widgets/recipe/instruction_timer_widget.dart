import 'dart:async';
import 'package:ai_ruchi/core/services/haptic_service.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:vibration/vibration.dart';
import 'package:ai_ruchi/core/utils/time_parser_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:ai_ruchi/providers/recipe_provider.dart';

/// Inline timer widget for recipe instructions with time mentions
class InstructionTimerWidget extends StatefulWidget {
  final Duration duration;
  final VoidCallback? onComplete;
  final int? stepIndex;

  const InstructionTimerWidget({
    super.key,
    required this.duration,
    this.onComplete,
    this.stepIndex,
  });

  @override
  State<InstructionTimerWidget> createState() => _InstructionTimerWidgetState();
}

class _InstructionTimerWidgetState extends State<InstructionTimerWidget> {
  Timer? _timer;
  late Duration _remainingTime;
  late AudioPlayer _audioPlayer;
  bool _isRunning = false;
  bool _isComplete = false;

  StreamSubscription<TimerEvent>? _timerSubscription;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.duration;
    _audioPlayer = AudioPlayer();

    // Listen for voice commands
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RecipeProvider>();
      _timerSubscription = provider.timerCommandStream.listen((event) {
        // If event targets specific step, check index.
        // If no index provided, check if we are the "current" meaningful timer?
        // Simpler: Check if we are the currently playing step or next incomplete.
        // For now, let's assume the parent passes us OUR index?
        // Widget doesn't have index props yet.
        // We need to add `index` to InstructionTimerWidget constructor first.

        // Wait, I missed adding `index` to the widget in the plan.
        // I'll assume valid if:
        // 1. Explicit index matches
        // 2. Or if index is null (global command), and this is the "active" timer.
        // What defines active? Maybe if it's visible?
        // Let's rely on the parent (instructions tab) to only dispatch if it matches?
        // No, stream is broadcast.

        // Let's refactor InstructionTimerWidget to accept `index` in separate step if needed.
        // For now, I will modify the constructor here too.

        _handleTimerEvent(event);
      });
    });
  }

  void _handleTimerEvent(TimerEvent event) {
    if (event.stepIndex != null && event.stepIndex != widget.stepIndex) {
      return;
    }
    // If stepIndex is null, maybe applying to all? Or none?
    // Let's assume voice commands will try to find the "active" step index.

    switch (event.action) {
      case TimerAction.start:
        if (!_isRunning && !_isComplete) _startTimer();
        break;
      case TimerAction.pause:
        if (_isRunning) _pauseTimer();
        break;
      case TimerAction.reset:
        _resetTimer();
        break;
    }
  }

  @override
  void dispose() {
    _timerSubscription?.cancel();
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isComplete) {
      _resetTimer();
    }

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
        } else {
          _timer?.cancel();
          _isRunning = false;
          _isComplete = true;
          _playCompletionBeep();
          widget.onComplete?.call();
        }
      });
    });
  }

  /// Play beep-like feedback on timer completion
  void _playCompletionBeep() async {
    // Multiple short vibrations to simulate beep pattern
    HapticService.heavyImpact();
    await SystemSound.play(SystemSoundType.alert);

    // Play custom beep sound with audioplayers
    try {
      await _audioPlayer.play(AssetSource('sounds/beep.mp3'));
    } catch (e) {
      debugPrint('Error playing beep sound: $e');
    }

    // Vibrate pattern
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(pattern: [0, 500, 200, 500]);
    }
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingTime = widget.duration;
      _isRunning = false;
      _isComplete = false;
    });
  }

  double get _progress {
    if (widget.duration.inSeconds == 0) return 1.0;
    return 1.0 - (_remainingTime.inSeconds / widget.duration.inSeconds);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: EdgeInsets.only(top: AppSizes.spaceHeightXs),
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSm,
        vertical: AppSizes.vPaddingXs,
      ),
      decoration: BoxDecoration(
        color: _isComplete
            ? Colors.green.withValues(alpha: 0.1)
            : colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: _isComplete
              ? Colors.green.withValues(alpha: 0.3)
              : colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timer info row
          Row(
            children: [
              Icon(
                _isComplete ? Icons.check_circle : Icons.timer_outlined,
                size: 16.sp,
                color: _isComplete ? Colors.green : colorScheme.primary,
              ),
              SizedBox(width: 6.w),
              Text(
                _isComplete
                    ? 'Timer Complete!'
                    : TimeParserUtils.formatCountdown(_remainingTime),
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _isComplete ? Colors.green : colorScheme.primary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const Spacer(),
              // Control buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Start/Pause button
                  _buildControlButton(
                    icon: _isRunning ? Icons.pause : Icons.play_arrow,
                    onTap: _isRunning ? _pauseTimer : _startTimer,
                    colorScheme: colorScheme,
                  ),
                  SizedBox(width: 4.w),
                  // Reset button
                  _buildControlButton(
                    icon: Icons.replay,
                    onTap: _resetTimer,
                    colorScheme: colorScheme,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 6.h),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2.r),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: colorScheme.outline.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                _isComplete ? Colors.green : colorScheme.primary,
              ),
              minHeight: 4.h,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Icon(icon, size: 16.sp, color: colorScheme.primary),
      ),
    );
  }
}
