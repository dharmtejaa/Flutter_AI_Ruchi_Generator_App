import 'package:ai_ruchi/core/services/tts_service.dart';
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

          // Check if there's a next step to auto-play
          final nextIndex = playingIndex + 1;
          if (nextIndex < widget.recipe.instructions.length) {
            // Auto-play next instruction
            recipeProvider.setCurrentlyPlayingIndex(nextIndex);
            _ttsService.speak(widget.recipe.instructions[nextIndex]);
          } else {
            // No more steps, clear playing index
            recipeProvider.setCurrentlyPlayingIndex(null);
          }
        }
      }
    };
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
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

    // Check if step is already completed - don't allow replay
    if (completedSteps.contains(index)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This step is already completed'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
                                // Timer widget for instructions with time (only for unlocked steps)
                                if (hasTimer && !isLocked)
                                  InstructionTimerWidget(duration: duration),
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
