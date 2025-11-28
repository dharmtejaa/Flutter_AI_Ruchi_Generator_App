import 'package:ai_ruchi/core/theme/app_shadows.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/models/recipe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NutritionSummaryRow extends StatelessWidget {
  final PerServingNutrition nutrition;

  const NutritionSummaryRow({
    super.key,
    required this.nutrition,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSizes.paddingLg),
      padding: EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: AppShadows.cardShadow(context),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NutritionItem(
            label: 'Calories',
            value: '${nutrition.calories.value.toInt()}',
            unit: nutrition.calories.unit,
            icon: Icons.local_fire_department,
            color: Colors.orange,
          ),
          _Divider(),
          _NutritionItem(
            label: 'Protein',
            value: '${nutrition.macros.protein.value.toInt()}',
            unit: nutrition.macros.protein.unit,
            icon: Icons.fitness_center,
            color: Colors.blue,
          ),
          _Divider(),
          _NutritionItem(
            label: 'Carbs',
            value: '${nutrition.macros.carbohydrates.value.toInt()}',
            unit: nutrition.macros.carbohydrates.unit,
            icon: Icons.grain,
            color: Colors.green,
          ),
          _Divider(),
          _NutritionItem(
            label: 'Fat',
            value: '${nutrition.macros.fat.value.toInt()}',
            unit: nutrition.macros.fat.unit,
            icon: Icons.water_drop,
            color: Colors.purple,
          ),
        ],
      ),
    );
  }
}

class _NutritionItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _NutritionItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: AppSizes.iconMd),
          SizedBox(height: AppSizes.spaceHeightXs),
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            unit,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSizes.spaceHeightXs),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 1,
      height: 40.h,
      color: colorScheme.outline.withValues(alpha: 0.2),
    );
  }
}


