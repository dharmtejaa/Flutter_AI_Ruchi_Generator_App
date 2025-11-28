import 'package:ai_ruchi/core/theme/app_shadows.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/models/recipe.dart';
import 'package:ai_ruchi/shared/widgets/recipe/recipe_action_buttons.dart';
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingLg),
            itemCount: recipe.ingredients.length,
            itemBuilder: (context, index) {
              final ingredient = recipe.ingredients[index];
              return Container(
                margin: EdgeInsets.only(bottom: AppSizes.spaceHeightMd),
                padding: EdgeInsets.all(AppSizes.paddingMd),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  boxShadow: AppShadows.cardShadow(context),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      child: Icon(
                        Icons.restaurant,
                        color: colorScheme.primary,
                        size: AppSizes.iconSm,
                      ),
                    ),
                    SizedBox(width: AppSizes.spaceMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ingredient.name,
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: AppSizes.spaceHeightXs),
                          Text(
                            '${ingredient.amount} ${ingredient.unit}',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        RecipeActionButtons(onRegenerate: onRegenerate, onSave: onSave),
      ],
    );
  }
}
