import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/providers/ingredients_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_ruchi/providers/recipe_provider.dart';
import 'package:ai_ruchi/shared/widgets/app_bottom_navigation_bar.dart';
import 'package:ai_ruchi/shared/widgets/custom_button.dart';
import 'package:ai_ruchi/shared/widgets/custom_snackbar.dart';
import 'package:ai_ruchi/shared/widgets/current_ingredients_section.dart';
import 'package:ai_ruchi/shared/widgets/ingredient_header_widget.dart';
import 'package:ai_ruchi/shared/widgets/ingredient_input_widget.dart';
import 'package:ai_ruchi/shared/widgets/recipe_preferences_dialog.dart';
import 'package:ai_ruchi/shared/widgets/suggested_additions_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdjustIngredientsScreen extends StatefulWidget {
  const AdjustIngredientsScreen({super.key});

  @override
  State<AdjustIngredientsScreen> createState() =>
      _AdjustIngredientsScreenState();
}

class _AdjustIngredientsScreenState extends State<AdjustIngredientsScreen> {
  final TextEditingController _ingredientController = TextEditingController();

  @override
  void dispose() {
    _ingredientController.dispose();
    super.dispose();
  }

  void _handleAddIngredient() {
    final provider = context.read<IngredientsProvider>();
    final text = _ingredientController.text.trim();

    if (!provider.parseAndAddIngredient(text)) {
      CustomSnackBar.showWarning(context, 'Please enter an ingredient name');
      return;
    }

    _ingredientController.clear();
  }

  Future<void> _handleRegenerateRecipe() async {
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
      final recipeProvider = context.read<RecipeProvider>();

      // Show loading
      CustomSnackBar.showInfo(context, 'Regenerating recipe...');

      // Generate recipe
      await recipeProvider.generateRecipe(
        ingredientsProvider.currentIngredients,
      );

      if (!context.mounted) return;
      
      if (recipeProvider.error == null && recipeProvider.recipe != null) {
        // Small delay to ensure UI is ready
        await Future.delayed(Duration(milliseconds: 100));
        
        if (!context.mounted) return;
        
        // Navigate to recipe screen
        try {
          context.push('/recipe');
        } catch (e) {
          if (context.mounted) {
            CustomSnackBar.showError(
              context,
              'Navigation error: $e',
            );
          }
        }
      } else {
        CustomSnackBar.showError(
          context,
          recipeProvider.error ?? 'Failed to regenerate recipe',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Consumer<IngredientsProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                // Header Section
                const IngredientHeaderWidget(title: 'Adjust Ingredients'),

                // Content Section
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingLg,
                      vertical: AppSizes.vPaddingMd,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Add/Remove Ingredient Input
                        IngredientInputWidget(
                          controller: _ingredientController,
                          onAdd: _handleAddIngredient,
                          hintText: 'Add/Remove ingredient...',
                        ),

                        SizedBox(height: AppSizes.spaceHeightLg),

                        // Current Ingredients Section
                        const CurrentIngredientsSection(),

                        SizedBox(height: AppSizes.spaceHeightLg),

                        // Suggested Additions Section
                        const SuggestedAdditionsSection(),

                        SizedBox(height: AppSizes.spaceHeightXl),

                        // Regenerate Recipe Button
                        CustomButton(
                          text: 'Regenerate Recipe',
                          backgroundColor: colorScheme.primary,
                          textColor: colorScheme.onPrimary,
                          ontap: _handleRegenerateRecipe,
                          width: double.infinity,
                        ),

                        SizedBox(height: AppSizes.spaceHeightXl),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 0),
    );
  }
}
