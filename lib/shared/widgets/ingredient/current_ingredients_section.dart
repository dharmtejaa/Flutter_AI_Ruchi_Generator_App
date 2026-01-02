import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/providers/ingredients_provider.dart';
import 'package:ai_ruchi/shared/widgets/ingredient/ingredient_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CurrentIngredientsSection extends StatelessWidget {
  final String? title;
  final String? emptyMessage;
  final bool showCount;

  const CurrentIngredientsSection({
    super.key,
    this.title,
    this.emptyMessage,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.watch<IngredientsProvider>();
    final count = provider.currentIngredients.length;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSm,
        vertical: AppSizes.vPaddingSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with title, clear all, and count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    title ?? 'Current Ingredients',
                    style: textTheme.headlineSmall,
                  ),
                  SizedBox(width: AppSizes.spaceSm),
                  // Count badge
                  if (showCount && count > 0) ...[
                    Text(
                      '$count items',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: AppSizes.spaceSm),
                  ],
                ],
              ),
              // Clear All button
              if (count > 0)
                GestureDetector(
                  onTap: () => provider.clearAllIngredients(),
                  child: Text(
                    'Clear All',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSizes.spaceHeightSm),
          if (provider.currentIngredients.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.paddingXl),
                child: Text(
                  emptyMessage ?? 'No ingredients added yet',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            ...provider.currentIngredients.map(
              (ingredient) => IngredientCardWidget(
                key: ValueKey(ingredient.id),
                ingredient: ingredient,
              ),
            ),
        ],
      ),
    );
  }
}
