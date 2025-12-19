import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/models/recipe.dart';
import 'package:ai_ruchi/providers/saved_recipes_provider.dart';
import 'package:ai_ruchi/shared/widgets/common/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SaveRecipeDialog {
  static Future<void> show(BuildContext context, Recipe recipe) async {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final provider = context.read<SavedRecipesProvider>();

    // Check if already saved
    if (provider.isRecipeSaved(recipe.title)) {
      CustomSnackBar.showInfo(context, 'This recipe is already saved!');
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        ),
        contentPadding: EdgeInsets.all(AppSizes.paddingLg),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bookmark_add_rounded,
                size: 32.sp,
                color: colorScheme.primary,
              ),
            ),
            SizedBox(height: 16.h),

            // Title
            Text(
              'Save Recipe?',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),

            // Subtitle
            Text(
              'Save "${recipe.title}" to access it anytime, even offline!',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),

            // Nutrition Preview Card
            Container(
              padding: EdgeInsets.all(AppSizes.paddingSm),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NutritionMini(
                    icon: Icons.local_fire_department,
                    color: const Color(0xFFFF6B35),
                    value:
                        '${recipe.nutrition.perServing.calories.value.toInt()}',
                    label: 'kcal',
                  ),
                  _NutritionMini(
                    icon: Icons.fitness_center,
                    color: const Color(0xFF4ECDC4),
                    value:
                        '${recipe.nutrition.perServing.macros.protein.value.toInt()}g',
                    label: 'Protein',
                  ),
                  _NutritionMini(
                    icon: Icons.grain,
                    color: const Color(0xFF45B7D1),
                    value:
                        '${recipe.nutrition.perServing.macros.carbohydrates.value.toInt()}g',
                    label: 'Carbs',
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: BorderSide(color: colorScheme.outline),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                    ),
                    child: Text(
                      'Not Now',
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark, size: 18.sp),
                        SizedBox(width: 6.w),
                        Text(
                          'Save',
                          style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final saved = await provider.saveRecipe(recipe);
      if (saved && context.mounted) {
        CustomSnackBar.showSuccess(context, 'Recipe saved successfully!');
      }
    }
  }
}

class _NutritionMini extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _NutritionMini({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20.sp),
        SizedBox(height: 4.h),
        Text(
          value,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
