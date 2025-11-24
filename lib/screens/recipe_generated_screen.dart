import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/providers/ingredients_provider.dart';
import 'package:ai_ruchi/providers/recipe_provider.dart';
import 'package:ai_ruchi/shared/widgets/custom_snackbar.dart';
import 'package:ai_ruchi/shared/widgets/nutrition_summary_row.dart';
import 'package:ai_ruchi/shared/widgets/recipe_image_widget.dart';
import 'package:ai_ruchi/shared/widgets/recipe_ingredients_tab.dart';
import 'package:ai_ruchi/shared/widgets/recipe_instructions_tab.dart';
import 'package:ai_ruchi/shared/widgets/recipe_nutrition_tab.dart';
import 'package:ai_ruchi/shared/widgets/recipe_preferences_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecipeGeneratedScreen extends StatefulWidget {
  const RecipeGeneratedScreen({super.key});

  @override
  State<RecipeGeneratedScreen> createState() => _RecipeGeneratedScreenState();
}

class _RecipeGeneratedScreenState extends State<RecipeGeneratedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final recipeProvider = context.watch<RecipeProvider>();

    if (recipeProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Generating Recipe...'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (recipeProvider.error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              SizedBox(height: AppSizes.spaceHeightLg),
              Text(
                recipeProvider.error!,
                style: textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSizes.spaceHeightLg),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final recipe = recipeProvider.recipe;
    if (recipe == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('No Recipe'),
        ),
        body: Center(
          child: Text('No recipe available'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          recipe.title,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Recipe Image
          SizedBox(height: AppSizes.spaceHeightMd),
          RecipeImageWidget(
            imageUrl: recipe.imageUrl,
            recipeName: recipe.title,
          ),

          SizedBox(height: AppSizes.spaceHeightMd),

          // Nutrition Summary Row
          NutritionSummaryRow(nutrition: recipe.nutrition.perServing),

          SizedBox(height: AppSizes.spaceHeightMd),

          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            indicatorColor: colorScheme.primary,
            tabs: [
              Tab(text: 'Ingredients'),
              Tab(text: 'Instructions'),
              Tab(text: 'Nutrition'),
            ],
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                RecipeIngredientsTab(
                  recipe: recipe,
                  onRegenerate: () => _handleRegenerate(context, recipeProvider),
                  onSave: () => _handleSave(context),
                ),
                RecipeInstructionsTab(
                  recipe: recipe,
                  onRegenerate: () => _handleRegenerate(context, recipeProvider),
                  onSave: () => _handleSave(context),
                ),
                RecipeNutritionTab(
                  nutrition: recipe.nutrition.perServing,
                  onRegenerate: () => _handleRegenerate(context, recipeProvider),
                  onSave: () => _handleSave(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegenerate(BuildContext context, RecipeProvider recipeProvider) async {
    final ingredientsProvider = context.read<IngredientsProvider>();
    
    if (ingredientsProvider.currentIngredients.isEmpty) {
      CustomSnackBar.showWarning(context, 'Please add at least one ingredient');
      return;
    }

    // Show preferences dialog
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const RecipePreferencesDialog(),
    );

    if (result == true) {
      // Show loading
      CustomSnackBar.showInfo(context, 'Regenerating recipe...');

      // Generate recipe
      await recipeProvider.generateRecipe(ingredientsProvider.currentIngredients);

      if (recipeProvider.error == null && recipeProvider.recipe != null) {
        // Recipe will automatically update via provider
        if (context.mounted) {
          CustomSnackBar.showSuccess(context, 'Recipe regenerated successfully!');
        }
      } else {
        if (context.mounted) {
          CustomSnackBar.showError(context, recipeProvider.error ?? 'Failed to regenerate recipe');
        }
      }
    }
  }

  void _handleSave(BuildContext context) {
    CustomSnackBar.showSuccess(context, 'Recipe saved successfully!');
    // TODO: Implement save functionality
  }
}

