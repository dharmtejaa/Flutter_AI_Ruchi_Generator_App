import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/providers/ingredients_provider.dart';
import 'package:ai_ruchi/shared/widgets/ingredient/ingredient_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row with title and count
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title ?? 'Current Ingredients',
              style: textTheme.headlineSmall,
            ),
            if (showCount && count > 0)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingSm,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shopping_basket,
                      size: AppSizes.iconsUxs,
                      color: colorScheme.primary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '$count items',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        SizedBox(height: AppSizes.spaceHeightMd),
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
    );
  }
}
