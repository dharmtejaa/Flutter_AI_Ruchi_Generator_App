import 'package:ai_ruchi/models/recipe.dart';
import 'package:ai_ruchi/shared/widgets/recipe/recipe_nutrition_tab.dart';
import 'package:flutter/material.dart';

class NutritionDetailScreen extends StatelessWidget {
  final PerServingNutrition nutrition;

  const NutritionDetailScreen({super.key, required this.nutrition});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nutrition Details',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: RecipeNutritionTab(
        nutrition: nutrition,
        onRegenerate: () => Navigator.of(context).pop(),
        onSave: () => Navigator.of(context).pop(),
      ),
    );
  }
}
