import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/providers/ingredients_provider.dart';
import 'package:ai_ruchi/shared/widgets/ingredient/ingredient_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CurrentIngredientsSection extends StatelessWidget {
  final String? title;
  final String? emptyMessage;

  const CurrentIngredientsSection({super.key, this.title, this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.watch<IngredientsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title ?? 'Current Ingredients', style: textTheme.headlineSmall),
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
