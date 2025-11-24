import 'package:ai_ruchi/core/theme/app_shadows.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/core/utils/ingredient_utils.dart';
import 'package:ai_ruchi/models/ingredient.dart';
import 'package:ai_ruchi/providers/ingredients_provider.dart';
import 'package:ai_ruchi/shared/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class IngredientCardWidget extends StatelessWidget {
  final Ingredient ingredient;

  const IngredientCardWidget({
    super.key,
    required this.ingredient,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.read<IngredientsProvider>();

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
          // Icon
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(
              IngredientUtils.getIngredientIcon(ingredient.name),
              color: colorScheme.primary,
              size: AppSizes.iconSm,
            ),
          ),
          SizedBox(width: AppSizes.spaceMd),

          // Ingredient name
          Expanded(
            child: Text(
              ingredient.name,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          SizedBox(width: AppSizes.spaceSm),

          // Quantity input
          Container(
            width: 60.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: TextField(
              controller: TextEditingController(
                text: ingredient.quantity.toStringAsFixed(
                  ingredient.quantity.truncateToDouble() == ingredient.quantity
                      ? 0
                      : 1,
                ),
              ),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                final quantity = double.tryParse(value);
                if (quantity != null && quantity > 0) {
                  provider.updateIngredientQuantity(ingredient.id, quantity);
                }
              },
            ),
          ),

          SizedBox(width: AppSizes.spaceXs),

          // Unit dropdown
          Container(
            height: 36.h,
            padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingSm),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: DropdownButton<String>(
              value: ingredient.unit,
              isDense: true,
              underline: SizedBox(),
              icon: Icon(
                Icons.arrow_drop_down,
                color: colorScheme.onSurface,
                size: AppSizes.iconSm,
              ),
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              items: IngredientUtils.units.map((unit) {
                return DropdownMenuItem<String>(
                  value: unit,
                  child: Text(unit),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  provider.updateIngredientUnit(ingredient.id, value);
                }
              },
            ),
          ),

          SizedBox(width: AppSizes.spaceSm),

          // Remove button
          IconButton(
            onPressed: () {
              provider.removeIngredient(ingredient.id);
              CustomSnackBar.showSuccess(
                context,
                '${ingredient.name} removed',
              );
            },
            icon: Icon(
              Icons.close,
              color: colorScheme.error,
              size: AppSizes.iconSm,
            ),
          ),
        ],
      ),
    );
  }
}


