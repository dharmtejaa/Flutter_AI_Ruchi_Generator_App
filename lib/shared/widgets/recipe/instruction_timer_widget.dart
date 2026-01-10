import 'dart:async';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/core/utils/time_parser_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Inline timer widget for recipe instructions with time mentions
class InstructionTimerWidget extends StatefulWidget {
  final Duration duration;
  final VoidCallback? onComplete;

  const InstructionTimerWidget({
    super.key,
    required this.duration,
    this.onComplete,
  });

  @override
  State<InstructionTimerWidget> createState() => _InstructionTimerWidgetState();
}

class _InstructionTimerWidgetState extends State<InstructionTimerWidget> {
  Timer? _timer;
  late Duration _remainingTime;
  bool _isRunning = false;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.duration;
  }

  @override
  void dispose() {
    _timer?.cancel();
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
          widget.onComplete?.call();
        }
      });
    });
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
