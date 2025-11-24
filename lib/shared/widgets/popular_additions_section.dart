import 'package:ai_ruchi/core/theme/app_shadows.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/core/utils/ingredient_utils.dart';
import 'package:ai_ruchi/providers/ingredients_provider.dart';
import 'package:ai_ruchi/shared/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class PopularAdditionsSection extends StatelessWidget {
  final String? title;
  final List<PopularIngredient>? popularIngredients;

  const PopularAdditionsSection({
    super.key,
    this.title,
    this.popularIngredients,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.read<IngredientsProvider>();

    final items = popularIngredients ?? _defaultPopularIngredients;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title ?? 'Popular Additions',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: AppSizes.spaceHeightMd),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: items.map((item) {
              return _PopularIngredientButton(
                ingredient: item,
                onTap: () {
                  provider.addCustomIngredient(
                    item.name,
                    item.defaultQuantity,
                    item.defaultUnit,
                  );
                  CustomSnackBar.showSuccess(context, '${item.name} added');
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class PopularIngredient {
  final String name;
  final IconData icon;
  final double defaultQuantity;
  final String defaultUnit;

  PopularIngredient({
    required this.name,
    required this.icon,
    this.defaultQuantity = 1,
    this.defaultUnit = 'unit',
  });
}

final List<PopularIngredient> _defaultPopularIngredients = [
  PopularIngredient(
    name: 'Carrot',
    icon: IngredientUtils.getIngredientIcon('carrot'),
  ),
  PopularIngredient(
    name: 'Beef',
    icon: Icons.set_meal,
  ),
  PopularIngredient(
    name: 'Cheese',
    icon: IngredientUtils.getIngredientIcon('cheese'),
  ),
  PopularIngredient(
    name: 'Bread',
    icon: IngredientUtils.getIngredientIcon('bread'),
  ),
  PopularIngredient(
    name: 'Garlic',
    icon: IngredientUtils.getIngredientIcon('garlic'),
  ),
  PopularIngredient(
    name: 'Cheese',
    icon: IngredientUtils.getIngredientIcon('cheese'),
  ),
];

class _PopularIngredientButton extends StatelessWidget {
  final PopularIngredient ingredient;
  final VoidCallback onTap;

  const _PopularIngredientButton({
    required this.ingredient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: AppSizes.spaceSm),
        width: 60.w,
        height: 60.h,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: AppShadows.cardShadow(context),
        ),
        child: Icon(
          ingredient.icon,
          color: colorScheme.primary,
          size: AppSizes.iconMd,
        ),
      ),
    );
  }
}


