import 'package:ai_ruchi/core/theme/app_shadows.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/models/recipe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  final Set<int> _completedSteps = {};

  void _toggleStep(int index) {
    setState(() {
      if (_completedSteps.contains(index)) {
        _completedSteps.remove(index);
      } else {
        _completedSteps.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

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
                  '${_completedSteps.length}/${widget.recipe.instructions.length}',
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
                          : _completedSteps.length /
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
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.paddingLg,
              vertical: AppSizes.vPaddingSm,
            ),
            itemCount: widget.recipe.instructions.length,
            itemBuilder: (context, index) {
              final instruction = widget.recipe.instructions[index];
              final isCompleted = _completedSteps.contains(index);
              final isLastStep = index == widget.recipe.instructions.length - 1;

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
                          GestureDetector(
                            onTap: () => _toggleStep(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 40.w,
                              height: 40.h,
                              decoration: BoxDecoration(
                                gradient: isCompleted
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
                                color: isCompleted
                                    ? null
                                    : colorScheme.surfaceContainer,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isCompleted
                                      ? colorScheme.primary
                                      : colorScheme.outline,
                                  width: 2,
                                ),
                                boxShadow: isCompleted
                                    ? [
                                        BoxShadow(
                                          color: colorScheme.primary.withValues(
                                            alpha: 0.3,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: isCompleted
                                      ? Icon(
                                          Icons.check,
                                          key: const ValueKey('check'),
                                          color: colorScheme.onPrimary,
                                          size: AppSizes.iconSm,
                                        )
                                      : Text(
                                          '${index + 1}',
                                          key: ValueKey('num_$index'),
                                          style: textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
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
                                      _completedSteps.contains(index + 1)
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
                              color: isCompleted
                                  ? colorScheme.primary.withValues(alpha: 0.05)
                                  : colorScheme.surface,
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusLg,
                              ),
                              border: Border.all(
                                color: isCompleted
                                    ? colorScheme.primary.withValues(alpha: 0.3)
                                    : colorScheme.outline.withValues(
                                        alpha: 0.15,
                                      ),
                              ),
                              boxShadow: AppShadows.cardShadow(context),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: textTheme.bodyMedium!.copyWith(
                                    color: isCompleted
                                        ? colorScheme.onSurface.withValues(
                                            alpha: 0.6,
                                          )
                                        : colorScheme.onSurface,
                                    height: 1.5,
                                    decoration: isCompleted
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                  child: Text(instruction),
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
