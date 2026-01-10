import 'package:ai_ruchi/core/services/tts_service.dart';
import 'package:ai_ruchi/core/services/speech_service.dart';
import 'package:ai_ruchi/core/theme/app_shadows.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/core/utils/time_parser_utils.dart';
import 'package:ai_ruchi/models/recipe.dart';
import 'package:ai_ruchi/providers/recipe_provider.dart';
import 'package:ai_ruchi/shared/widgets/recipe/instruction_timer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class RecipeInstructionsTab extends StatefulWidget {
  final Recipe recipe;
  final VoidCallback onRegenerate;
  final VoidCallback onSave;

  const RecipeInstructionsTab({
    super.key,
    required this.recipe,
    required this.onRegenerate,
    required this.onSave,
  });

  @override
  State<RecipeInstructionsTab> createState() => _RecipeInstructionsTabState();
}

class _RecipeInstructionsTabState extends State<RecipeInstructionsTab> {
  final TtsService _ttsService = TtsService();
  final SpeechService _speechService = SpeechService();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _ttsService.initialize();
    _ttsService.onComplete = (_) {
      if (mounted) {
        final recipeProvider = context.read<RecipeProvider>();
        final playingIndex = recipeProvider.currentlyPlayingIndex;

        if (playingIndex != null) {
          // Mark current step as completed
          recipeProvider.markStepCompleted(playingIndex);
          // Clear playing index - do NOT auto-play next
          recipeProvider.setCurrentlyPlayingIndex(null);
        }
      }
    };

    // Initialize speech service with status listeners
    await _speechService.initialize(
      onStatus: (status) {
        if (mounted) {
          // Sync UI state with actual speech status
          if (status == 'notListening' || status == 'done') {
            // Continuous Listening Logic:
            // If explicit stop wasn't requested (we track this via internal flag?
            // actually _isListening is our flag for "user wants listening on").
            // So if _isListening is true, but status says done, we restart.

            if (_isListening) {
              // Restart listening immediately
              _speechService.startListening(
                onResult: (text) => _handleVoiceCommand(text),
              );
            } else {
              // Truly stopped
              setState(() => _isListening = false);
            }
          } else if (status == 'listening') {
            setState(() => _isListening = true);
          }
        }
      },
      onError: (errorStat) {
        if (mounted) {
          // If error is permanent, maybe stop.
          // But generally for continuous listening we might want to retry?
          // For now, let's stop on error to prevent infinite error loops.
          setState(() => _isListening = false);
        }
      },
    );
  }

  @override
  void dispose() {
    _ttsService.stop();
    _speechService.stopListening();
    super.dispose();
  }

  void _toggleListening() async {
    if (_isListening) {
      // User explicitly wants to stop
      setState(
        () => _isListening = false,
      ); // Update flag first so we don't auto-restart
      await _speechService.stopListening();
    } else {
      setState(() => _isListening = true);
      await _speechService.startListening(
        onResult: (text) {
          _handleVoiceCommand(text);
          // With continuous listening, we don't stop here.
        },
      );
    }
  }

  void _handleVoiceCommand(String text) {
    if (!mounted) return;
    debugPrint('Voice command: $text');
    final command = text.toLowerCase();

    final recipeProvider = context.read<RecipeProvider>();
    final instructions = widget.recipe.instructions;

    // --- Timer Commands ---
    if (command.contains('timer')) {
      int? stepTarget;
      // Try to infer step from context (currently playing or just general)
      // If "step X timer", we could parse that.
      // For now, let's dispatch globally (stepIndex: null) or to currently playing.
      // Actually, if we pass currentlyPlayingIndex, the timer widget for that step needs to match it.
      // But commonly the user is looking at the screen or listening to a step.
      // If audio is playing, use that index.
      // If not, use next incomplete? Or we can broadcast without index and let active/visible timers decide?
      // Our Widget logic checks: if (event.stepIndex != null && event.stepIndex != widget.stepIndex) return;
      // So if we send null, ALL timers receive it.
      // Do we want "Start timer" to start ALL timers? Probably not.
      // But usually only one is active/relevant.
      // Let's refine: If "Start Timer" -> Start timer for the *current step* being read.

      stepTarget = recipeProvider.currentlyPlayingIndex;
      // If nothing playing, maybe the first incomplete step?
      stepTarget ??= _getNextIncompleteStep();

      if (command.contains('start') || command.contains('begin')) {
        recipeProvider.dispatchTimerCommand(
          TimerAction.start,
          stepIndex: stepTarget,
        );
        return;
      }
      if (command.contains('stop') || command.contains('pause')) {
        recipeProvider.dispatchTimerCommand(
          TimerAction.pause,
          stepIndex: stepTarget,
        );
        // Note: Stop usually means pause for timers. Reset is separate.
        return;
      }
      if (command.contains('reset') || command.contains('restart')) {
        recipeProvider.dispatchTimerCommand(
          TimerAction.reset,
          stepIndex: stepTarget,
        );
        return;
      }
    }

    // "Stop" / "Pause" (TTS)
    // Only if NOT timer command (checked above)
    if (command.contains('stop') ||
        command.contains('pause') ||
        command.contains('quiet')) {
      _ttsService.stop();
      recipeProvider.setCurrentlyPlayingIndex(null);
      return;
    }

    // "Next"
    if (command.contains('next')) {
      int nextIndex = _getNextIncompleteStep();
      // If currently playing, go to next relative to that
      if (recipeProvider.currentlyPlayingIndex != null) {
        nextIndex = recipeProvider.currentlyPlayingIndex! + 1;
      }

      if (nextIndex < instructions.length && nextIndex >= 0) {
        _toggleTts(nextIndex, instructions[nextIndex]);
      }
      return;
    }

    // "Step X" parsing
    // Regex to find "step" followed by a number
    final stepMatch = RegExp(r'step\s+(\d+)').firstMatch(command);
    if (stepMatch != null) {
      final stepNum = int.tryParse(stepMatch.group(1) ?? '');
      if (stepNum != null && stepNum > 0 && stepNum <= instructions.length) {
        final index = stepNum - 1;
        _toggleTts(index, instructions[index]);
        return;
      }
    }

    // "Play" (plays current incomplete step)
    if (command.contains('play') ||
        command.contains('start') ||
        command.contains('read')) {
      final index = _getNextIncompleteStep();
      if (index < instructions.length) {
        _toggleTts(index, instructions[index]);
      }
      return;
    }
  }

  /// Check if a step can be toggled (must be sequential)
  bool _canToggleStep(int index) {
    final completedSteps = context.read<RecipeProvider>().completedSteps;
    // Can always toggle if it's currently completed (to uncomplete)
    if (completedSteps.contains(index)) {
      return true;
    }
    // Can only complete if all previous steps are completed
    for (int i = 0; i < index; i++) {
      if (!completedSteps.contains(i)) {
        return false;
      }
    }
    return true;
  }

  void _toggleStep(int index) {
    final recipeProvider = context.read<RecipeProvider>();
    if (!_canToggleStep(index)) {
      // Show a message that previous steps must be completed first
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Complete step ${_getNextIncompleteStep() + 1} first'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    recipeProvider.toggleStepCompletion(index);
  }

  /// Get the next step that needs to be completed
  int _getNextIncompleteStep() {
    final completedSteps = context.read<RecipeProvider>().completedSteps;
    for (int i = 0; i < widget.recipe.instructions.length; i++) {
      if (!completedSteps.contains(i)) {
        return i;
      }
    }
    return widget.recipe.instructions.length - 1;
  }

  /// Toggle TTS for an instruction - only works for unlocked, incomplete steps
  void _toggleTts(int index, String text) async {
    final recipeProvider = context.read<RecipeProvider>();
    final completedSteps = recipeProvider.completedSteps;
    final currentlyPlayingIndex = recipeProvider.currentlyPlayingIndex;

    // Check if step is already completed - silently ignore (no toast)
    if (completedSteps.contains(index)) {
      return;
    }

    // Check if step is locked (previous steps not completed)
    if (!_canToggleStep(index)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Complete step ${_getNextIncompleteStep() + 1} first to unlock audio',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (currentlyPlayingIndex == index) {
      // Currently playing this step, stop it
      await _ttsService.stop();
      recipeProvider.setCurrentlyPlayingIndex(null);
    } else {
      // Stop any current playback and start new
      await _ttsService.stop();
      recipeProvider.setCurrentlyPlayingIndex(index);

      // Speak - onComplete callback will handle auto-advance
      await _ttsService.speak(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final recipeProvider = context.watch<RecipeProvider>();
    final completedSteps = recipeProvider.completedSteps;
    final currentlyPlayingIndex = recipeProvider.currentlyPlayingIndex;

    return Column(
      children: [
        // Fixed progress header (stays at top of this tab)
        Container(
          color: colorScheme.surface,
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMd,
            vertical: AppSizes.vPaddingXs,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.paddingSm,
              vertical: AppSizes.vPaddingXs,
            ),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.format_list_numbered_rounded,
                  color: colorScheme.primary,
                  size: 18.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  '${widget.recipe.instructions.length} Steps',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
                const Spacer(),
                // Voice Command Toggle
                GestureDetector(
                  onTap: _toggleListening,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: _isListening
                          ? Colors.red.withValues(alpha: 0.1)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: _isListening
                          ? Border.all(color: Colors.red, width: 1.5)
                          : null,
                    ),
                    child: _isListening
                        ? Icon(
                            Icons.mic_rounded,
                            color: Colors.red,
                            size: 20.sp,
                          )
                        : Icon(
                            Icons.mic_none_rounded,
                            color: colorScheme.primary.withValues(alpha: 0.7),
                            size: 20.sp,
                          ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${completedSteps.length}/${widget.recipe.instructions.length}',
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(width: 8.w),
                SizedBox(
                  width: 60.w,
                  height: 4.h,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2.r),
                    child: LinearProgressIndicator(
                      value: widget.recipe.instructions.isEmpty
                          ? 0
                          : completedSteps.length /
                                widget.recipe.instructions.length,
                      backgroundColor: colorScheme.outline,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Scrollable instructions list
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(
              left: AppSizes.paddingLg,
              right: AppSizes.paddingLg,
              top: AppSizes.vPaddingSm,
              bottom: 120.h, // Extra space at bottom for FAB clearance
            ),
            itemCount: widget.recipe.instructions.length,
            itemBuilder: (context, index) {
              final instruction = widget.recipe.instructions[index];
              final isCompleted = completedSteps.contains(index);
              final isLastStep = index == widget.recipe.instructions.length - 1;
              final isLocked = !_canToggleStep(index);
              final isNextStep = index == _getNextIncompleteStep();
              final isPlaying = currentlyPlayingIndex == index;

              // Check for time in instruction
              final duration = TimeParserUtils.parseTimeFromText(instruction);
              final hasTimer = duration != null;

              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + (index * 50)),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(30 * (1 - value), 0),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Step indicator with line
                      Column(
                        children: [
                          // Audio play/stop button as step indicator
                          GestureDetector(
                            onTap: () => _toggleTts(index, instruction),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 40.w,
                              height: 40.h,
                              decoration: BoxDecoration(
                                gradient: isPlaying
                                    ? LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.orange,
                                          Colors.orange.shade700,
                                        ],
                                      )
                                    : isCompleted
                                    ? LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          colorScheme.primary,
                                          colorScheme.primary.withValues(
                                            alpha: 0.8,
                                          ),
                                        ],
                                      )
                                    : null,
                                color: isPlaying || isCompleted
                                    ? null
                                    : isLocked
                                    ? colorScheme.surfaceContainerHighest
                                    : colorScheme.surfaceContainer,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isPlaying
                                      ? Colors.orange
                                      : isCompleted
                                      ? colorScheme.primary
                                      : isNextStep
                                      ? colorScheme.primary.withValues(
                                          alpha: 0.5,
                                        )
                                      : colorScheme.outline.withValues(
                                          alpha: isLocked ? 0.3 : 1,
                                        ),
                                  width: isNextStep || isPlaying ? 2.5 : 2,
                                ),
                                boxShadow: isPlaying
                                    ? [
                                        BoxShadow(
                                          color: Colors.orange.withValues(
                                            alpha: 0.4,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : isCompleted
                                    ? [
                                        BoxShadow(
                                          color: colorScheme.primary.withValues(
                                            alpha: 0.3,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : isNextStep
                                    ? [
                                        BoxShadow(
                                          color: colorScheme.primary.withValues(
                                            alpha: 0.15,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: isPlaying
                                      ? Icon(
                                          Icons.stop_rounded,
                                          key: const ValueKey('stop'),
                                          color: Colors.white,
                                          size: AppSizes.iconSm,
                                        )
                                      : isCompleted
                                      ? Icon(
                                          Icons.check,
                                          key: const ValueKey('check'),
                                          color: colorScheme.onPrimary,
                                          size: AppSizes.iconSm,
                                        )
                                      : isLocked
                                      ? Icon(
                                          Icons.lock_outline,
                                          key: ValueKey('lock_$index'),
                                          color: colorScheme.onSurfaceVariant
                                              .withValues(alpha: 0.5),
                                          size: 16.sp,
                                        )
                                      : Icon(
                                          Icons.play_arrow_rounded,
                                          key: ValueKey('play_$index'),
                                          color: isNextStep
                                              ? colorScheme.primary
                                              : colorScheme.onSurfaceVariant,
                                          size: AppSizes.iconSm,
                                        ),
                                ),
                              ),
                            ),
                          ),
                          // Connecting line
                          if (!isLastStep)
                            Expanded(
                              child: Container(
                                width: 3.w,
                                margin: EdgeInsets.symmetric(
                                  vertical: AppSizes.vPaddingXs,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(1.5.r),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      isCompleted
                                          ? colorScheme.primary
                                          : colorScheme.outline,
                                      completedSteps.contains(index + 1)
                                          ? colorScheme.primary
                                          : colorScheme.outline,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(width: AppSizes.spaceMd),
                      // Instruction card
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _toggleStep(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: EdgeInsets.only(
                              bottom: isLastStep ? 0 : AppSizes.spaceHeightMd,
                            ),
                            padding: EdgeInsets.all(AppSizes.paddingMd),
                            decoration: BoxDecoration(
                              color: isPlaying
                                  ? Colors.orange.withValues(alpha: 0.05)
                                  : isCompleted
                                  ? colorScheme.primary.withValues(alpha: 0.05)
                                  : isLocked
                                  ? colorScheme.surfaceContainerHighest
                                        .withValues(alpha: 0.5)
                                  : colorScheme.surface,
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusLg,
                              ),
                              border: Border.all(
                                color: isPlaying
                                    ? Colors.orange.withValues(alpha: 0.3)
                                    : isCompleted
                                    ? colorScheme.primary.withValues(alpha: 0.3)
                                    : isNextStep
                                    ? colorScheme.primary.withValues(alpha: 0.3)
                                    : colorScheme.outline.withValues(
                                        alpha: isLocked ? 0.1 : 0.15,
                                      ),
                              ),
                              boxShadow: isLocked
                                  ? null
                                  : AppShadows.cardShadow(context),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Step number badge
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 2.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isPlaying
                                            ? Colors.orange.withValues(
                                                alpha: 0.15,
                                              )
                                            : colorScheme.primary.withValues(
                                                alpha: 0.1,
                                              ),
                                        borderRadius: BorderRadius.circular(
                                          4.r,
                                        ),
                                      ),
                                      child: Text(
                                        'Step ${index + 1}',
                                        style: textTheme.labelSmall?.copyWith(
                                          color: isPlaying
                                              ? Colors.orange
                                              : colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    if (hasTimer)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6.w,
                                          vertical: 2.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4.r,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.timer,
                                              size: 12.sp,
                                              color: Colors.blue,
                                            ),
                                            SizedBox(width: 4.w),
                                            Text(
                                              TimeParserUtils.formatDuration(
                                                duration,
                                              ),
                                              style: textTheme.labelSmall
                                                  ?.copyWith(
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 8.h),
                                // Instruction text
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: textTheme.bodyMedium!.copyWith(
                                    color: isCompleted
                                        ? colorScheme.onSurface.withValues(
                                            alpha: 0.6,
                                          )
                                        : isLocked
                                        ? colorScheme.onSurface.withValues(
                                            alpha: 0.4,
                                          )
                                        : colorScheme.onSurface,
                                    height: 1.5,
                                    decoration: isCompleted
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                  child: Text(instruction),
                                ),
                                // Timer widget for instructions with time (only for unlocked and incomplete steps)
                                if (hasTimer && !isLocked && !isCompleted)
                                  InstructionTimerWidget(
                                    duration: duration,
                                    stepIndex: index,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
