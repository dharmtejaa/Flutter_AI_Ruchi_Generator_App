import 'package:ai_ruchi/core/theme/app_shadows.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/models/recipe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NutritionSummaryRow extends StatelessWidget {
  final PerServingNutrition nutrition;
  final bool showLabels;
  final bool isCompact;

  const NutritionSummaryRow({
    super.key,
    required this.nutrition,
    this.showLabels = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSizes.paddingSm),
      padding: EdgeInsets.all(AppSizes.paddingXs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        color: colorScheme.surface,
        boxShadow: AppShadows.cardShadow(context),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _NutritionItem(
                label: 'Calories',
                value: '${nutrition.calories.value.toInt()}',
                unit: nutrition.calories.unit,
                icon: Icons.local_fire_department_rounded,
                color: _NutritionColors.calories,
                isCompact: isCompact,
                showLabel: showLabels,
              ),
            ),
            _GradientDivider(),
            Expanded(
              child: _NutritionItem(
                label: 'Protein',
                value: '${nutrition.macros.protein.value.toInt()}',
                unit: nutrition.macros.protein.unit,
                icon: Icons.fitness_center_rounded,
                color: _NutritionColors.protein,
                isCompact: isCompact,
                showLabel: showLabels,
              ),
            ),
            _GradientDivider(),
            Expanded(
              child: _NutritionItem(
                label: 'Carbs',
                value: '${nutrition.macros.carbohydrates.value.toInt()}',
                unit: nutrition.macros.carbohydrates.unit,
                icon: Icons.grain_rounded,
                color: _NutritionColors.carbs,
                isCompact: isCompact,
                showLabel: showLabels,
              ),
            ),
            _GradientDivider(),
            Expanded(
              child: _NutritionItem(
                label: 'Fat',
                value: '${nutrition.macros.fat.value.toInt()}',
                unit: nutrition.macros.fat.unit,
                icon: Icons.water_drop_rounded,
                color: _NutritionColors.fat,
                isCompact: isCompact,
                showLabel: showLabels,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NutritionColors {
  static const Color calories = Color(0xFFFF6B35);
  static const Color protein = Color(0xFF4ECDC4);
  static const Color carbs = Color(0xFF45B7D1);
  static const Color fat = Color(0xFF9B59B6);
}

class _NutritionItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final bool isCompact;
  final bool showLabel;

  const _NutritionItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.isCompact,
    required this.showLabel,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon with gradient background
        Container(
          width: isCompact ? 32.w : 40.w,
          height: isCompact ? 32.h : 40.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: isCompact ? AppSizes.iconSm : AppSizes.iconMd,
          ),
        ),

        SizedBox(
          height: isCompact ? AppSizes.spaceHeightXs : AppSizes.spaceHeightSm,
        ),

        // Value with animated appearance
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: (isCompact ? textTheme.titleMedium : textTheme.titleLarge)
                  ?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
            ),
            SizedBox(width: 2.w),
            Text(
              unit,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        if (showLabel) ...[
          SizedBox(height: AppSizes.spaceHeightXs),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ],
    );
  }
}

class _GradientDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 1.w,
      margin: EdgeInsets.symmetric(vertical: AppSizes.vPaddingSm),
      decoration: BoxDecoration(
        color: colorScheme.outline.withValues(alpha: 0.1),
      ),
    );
  }
}
