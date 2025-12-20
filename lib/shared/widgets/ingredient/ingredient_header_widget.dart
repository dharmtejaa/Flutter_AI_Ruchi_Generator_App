import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/providers/ingredients_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class IngredientHeaderWidget extends StatelessWidget {
  final String title;
  final String? recipeName;

  const IngredientHeaderWidget({
    super.key,
    required this.title,
    this.recipeName,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final provider = context.watch<IngredientsProvider>();

    return Container(
      padding: EdgeInsets.symmetric(
        //horizontal: AppSizes.paddingMd,
        vertical: AppSizes.vPaddingXs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.displaySmall),
          if (recipeName != null || provider.recipeName.isNotEmpty) ...[
            SizedBox(height: AppSizes.spaceHeightXs),
            Text(
              'for ${recipeName ?? provider.recipeName}',
              style: textTheme.labelLarge,
            ),
          ],
        ],
      ),
    );
  }
}
