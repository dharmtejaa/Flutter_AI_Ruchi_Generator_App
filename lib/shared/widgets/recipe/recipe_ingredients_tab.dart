import 'package:ai_ruchi/core/theme/app_shadows.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/models/recipe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecipeIngredientsTab extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onRegenerate;
  final VoidCallback onSave;

  const RecipeIngredientsTab({
    super.key,
    required this.recipe,
    required this.onRegenerate,
    required this.onSave,
  });

  IconData _getIngredientIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('egg')) return Icons.egg_alt;
    if (lowerName.contains('milk') ||
        lowerName.contains('cream') ||
        lowerName.contains('dairy')) {
      return Icons.local_drink;
    }
    if (lowerName.contains('chicken') ||
        lowerName.contains('meat') ||
        lowerName.contains('beef') ||
        lowerName.contains('pork')) {
      return Icons.restaurant;
    }
    if (lowerName.contains('fish') ||
        lowerName.contains('salmon') ||
        lowerName.contains('shrimp')) {
      return Icons.set_meal;
    }
    if (lowerName.contains('fruit') ||
        lowerName.contains('apple') ||
        lowerName.contains('banana') ||
        lowerName.contains('lemon')) {
      return Icons.apple;
    }
    if (lowerName.contains('vegetable') ||
        lowerName.contains('carrot') ||
        lowerName.contains('spinach') ||
        lowerName.contains('broccoli')) {
      return Icons.eco;
    }
    if (lowerName.contains('rice') ||
        lowerName.contains('grain') ||
        lowerName.contains('wheat') ||
        lowerName.contains('flour')) {
      return Icons.grain;
    }
    if (lowerName.contains('oil') || lowerName.contains('butter')) {
      return Icons.water_drop;
    }
    if (lowerName.contains('salt') ||
        lowerName.contains('pepper') ||
        lowerName.contains('spice') ||
        lowerName.contains('herb')) {
      return Icons.spa;
    }
    if (lowerName.contains('sugar') ||
        lowerName.contains('honey') ||
        lowerName.contains('syrup')) {
      return Icons.cake;
    }
    if (lowerName.contains('tomato') ||
        lowerName.contains('onion') ||
        lowerName.contains('garlic')) {
      return Icons.local_florist;
    }
    if (lowerName.contains('cheese')) {
      return Icons.lunch_dining;
    }
    return Icons.restaurant_menu;
  }

  Color _getIngredientColor(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('meat') ||
        lowerName.contains('chicken') ||
        lowerName.contains('beef') ||
        lowerName.contains('pork')) {
      return const Color(0xFFE57373);
    }
    if (lowerName.contains('vegetable') ||
        lowerName.contains('spinach') ||
        lowerName.contains('lettuce') ||
        lowerName.contains('broccoli')) {
      return const Color(0xFF81C784);
    }
    if (lowerName.contains('fruit') ||
        lowerName.contains('apple') ||
        lowerName.contains('orange') ||
        lowerName.contains('lemon')) {
      return const Color(0xFFFFB74D);
    }
    if (lowerName.contains('dairy') ||
        lowerName.contains('milk') ||
        lowerName.contains('cheese') ||
        lowerName.contains('cream')) {
      return const Color(0xFF64B5F6);
    }
    if (lowerName.contains('grain') ||
        lowerName.contains('rice') ||
        lowerName.contains('bread') ||
        lowerName.contains('flour')) {
      return const Color(0xFFFFD54F);
    }
    if (lowerName.contains('spice') ||
        lowerName.contains('herb') ||
        lowerName.contains('salt') ||
        lowerName.contains('pepper')) {
      return const Color(0xFFBA68C8);
    }
    if (lowerName.contains('fish') ||
        lowerName.contains('shrimp') ||
        lowerName.contains('salmon')) {
      return const Color(0xFF4DD0E1);
    }
    return const Color(0xFF90A4AE);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Header info
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMd,
            vertical: AppSizes.vPaddingXs,
          ),
          padding: EdgeInsets.all(AppSizes.paddingXs),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Row(
            children: [
              Icon(
                Icons.shopping_basket_rounded,
                color: colorScheme.primary,
                size: AppSizes.iconMd,
              ),
              SizedBox(width: AppSizes.spaceSm),
              Text(
                '${recipe.ingredients.length} Ingredients',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingSm,
                  vertical: AppSizes.vPaddingXs,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Text(
                  'Serves ${recipe.servings}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Ingredients list
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
            itemCount: recipe.ingredients.length,
            itemBuilder: (context, index) {
              final ingredient = recipe.ingredients[index];
              final ingredientColor = _getIngredientColor(ingredient.name);

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
                child: Container(
                  margin: EdgeInsets.only(bottom: AppSizes.spaceHeightSm),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    boxShadow: AppShadows.cardShadow(context),
                    border: Border.all(
                      color: ingredientColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      child: Padding(
                        padding: EdgeInsets.all(AppSizes.paddingXs),
                        child: Row(
                          children: [
                            // Ingredient icon
                            Container(
                              width: 45.w,
                              height: 45.h,
                              decoration: BoxDecoration(
                                color: ingredientColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusMd,
                                ),
                              ),
                              child: Icon(
                                _getIngredientIcon(ingredient.name),
                                color: ingredientColor,
                                size: AppSizes.iconMd,
                              ),
                            ),
                            SizedBox(width: AppSizes.spaceMd),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ingredient.name,
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                ],
                              ),
                            ),
                            Text(
                              '${ingredient.amount} ${ingredient.unit}',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: AppSizes.spaceSm),
                          ],
                        ),
                      ),
                    ),
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
