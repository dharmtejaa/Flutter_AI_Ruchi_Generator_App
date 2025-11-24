import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/providers/ingredients_provider.dart';
import 'package:ai_ruchi/providers/recipe_provider.dart';
import 'package:ai_ruchi/shared/widgets/app_bottom_navigation_bar.dart';
import 'package:ai_ruchi/shared/widgets/custom_button.dart';
import 'package:ai_ruchi/shared/widgets/custom_snackbar.dart';
import 'package:ai_ruchi/shared/widgets/current_ingredients_section.dart';
import 'package:ai_ruchi/shared/widgets/ingredient_header_widget.dart';
import 'package:ai_ruchi/shared/widgets/ingredient_input_widget.dart';
import 'package:ai_ruchi/shared/widgets/popular_additions_section.dart';
import 'package:ai_ruchi/shared/widgets/recipe_preferences_dialog.dart';
import 'package:ai_ruchi/shared/widgets/suggested_additions_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
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

  Future<void> _handleGenerateRecipe() async {
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
      CustomSnackBar.showInfo(context, 'Generating recipe...');

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
            CustomSnackBar.showError(context, 'Navigation error: $e');
          }
        }
      } else {
        CustomSnackBar.showError(
          context,
          recipeProvider.error ?? 'Failed to generate recipe',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<IngredientsProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                // Header Section
                const IngredientHeaderWidget(title: 'What do you have?'),

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
                        // Add Ingredient Input
                        IngredientInputWidget(
                          controller: _ingredientController,
                          onAdd: _handleAddIngredient,
                        ),

                        SizedBox(height: AppSizes.spaceHeightLg),

                        // Current Ingredients Section
                        const CurrentIngredientsSection(),

                        SizedBox(height: AppSizes.spaceHeightLg),

                        // Popular Additions Section
                        const PopularAdditionsSection(),

                        SizedBox(height: AppSizes.spaceHeightLg),

                        // Suggested Additions Section
                        const SuggestedAdditionsSection(),

                        SizedBox(height: AppSizes.spaceHeightXl),
                      ],
                    ),
                  ),
                ),

                // Bottom Action Bar
                _buildBottomActionBar(context, provider),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 0),
    );
  }

  Widget _buildBottomActionBar(
    BuildContext context,
    IngredientsProvider provider,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final count = provider.currentIngredients.length;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingLg,
        vertical: AppSizes.vPaddingMd,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Flexible(
            child: Text(
              '$count ${count == 1 ? 'Ingredient' : 'Ingredients'} Selected',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: AppSizes.spaceSm),
          Flexible(
            flex: 0,
            child: SizedBox(
              width: 110.0.w,
              child: CustomButton(
                text: 'View Score',
                backgroundColor: colorScheme.surface,
                textColor: colorScheme.primary,
                ontap: () {
                  CustomSnackBar.showInfo(context, 'Score feature coming soon');
                },
                icon: Icons.local_fire_department,
              ),
            ),
          ),
          SizedBox(width: AppSizes.spaceSm),
          Flexible(
            flex: 0,
            child: SizedBox(
              width: 140.0.w,
              child: CustomButton(
                text: 'Generate Recipe',
                backgroundColor: colorScheme.primary,
                textColor: colorScheme.onPrimary,
                ontap: _handleGenerateRecipe,
                icon: Icons.auto_awesome,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
