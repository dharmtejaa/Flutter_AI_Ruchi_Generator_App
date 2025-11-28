import 'package:ai_ruchi/core/theme/app_shadows.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/core/utils/ingredient_helper.dart';
import 'package:ai_ruchi/core/utils/recipe_helper.dart';
import 'package:ai_ruchi/providers/ingredients_provider.dart';
import 'package:ai_ruchi/providers/recipe_provider.dart';
import 'package:ai_ruchi/shared/widgets/navigation/app_bottom_navigation_bar.dart';
import 'package:ai_ruchi/shared/widgets/ingredient/current_ingredients_section.dart';
import 'package:ai_ruchi/shared/widgets/ingredient/ingredient_action_bar.dart';
import 'package:ai_ruchi/shared/widgets/ingredient/ingredient_header_widget.dart';
import 'package:ai_ruchi/shared/widgets/ingredient/ingredient_input_widget.dart';
import 'package:ai_ruchi/shared/widgets/recipe/recipe_loading_screen.dart';
import 'package:ai_ruchi/shared/widgets/ingredient/suggested_additions_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

// Static variable to track navigation without setState
bool _isNavigatingToRecipe = false;

class _EntryScreenState extends State<EntryScreen> {
  final TextEditingController _ingredientController = TextEditingController();
  final FocusNode _ingredientFocusNode = FocusNode();

  @override
  void dispose() {
    _ingredientController.dispose();
    _ingredientFocusNode.dispose();
    super.dispose();
  }

  void _handleAddIngredient() {
    final text = _ingredientController.text;
    IngredientHelper.addIngredientFromText(
      context,
      text,
      onSuccess: () {
        _ingredientController.clear();
        _ingredientFocusNode.requestFocus();
      },
    );
  }

  Future<void> _handleGenerateRecipe() async {
    // Set navigation flag before generation to keep loading screen visible
    _isNavigatingToRecipe = true;

    await RecipeHelper.generateRecipeWithPreferences(
      context,
      navigateOnSuccess: true,
      navigationRoute: '/recipe',
    );

    // Reset flag when navigation completes (user came back) or if it failed
    // context.push returns when the route is popped, so we're back on this screen
    if (mounted) {
      _isNavigatingToRecipe = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Scaffold(
        body: Consumer2<IngredientsProvider, RecipeProvider>(
          builder: (context, ingredientsProvider, recipeProvider, child) {
            // Reset flag immediately if we're back on screen (not loading, recipe exists, flag is set)
            // This handles the case when user navigates back from recipe screen
            // Do this BEFORE checking if we should show loading screen
            // Check: if not loading, recipe exists, and flag is still true, we're back from navigation
            if (!recipeProvider.isLoading &&
                recipeProvider.recipe != null &&
                _isNavigatingToRecipe) {
              // Reset synchronously - this is safe since it's a static variable
              // The next build will see the flag as false
              _isNavigatingToRecipe = false;
            }

            // Show loading screen when generating recipe or navigating
            // Keep showing if recipe is ready and we're navigating (during transition)
            final isGenerating = recipeProvider.isLoading;
            final hasRecipeAndNavigating =
                _isNavigatingToRecipe && recipeProvider.recipe != null;

            if (isGenerating || hasRecipeAndNavigating) {
              return const RecipeLoadingScreen();
            }

            return Column(
              crossAxisAlignment: .start,
              children: [
                // Header Section
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingSm,
                    vertical: AppSizes.vPaddingSm,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    boxShadow: AppShadows.elevatedShadow(context),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(AppSizes.radiusXxxl),
                      bottomRight: Radius.circular(AppSizes.radiusXxxl),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      const IngredientHeaderWidget(title: 'What do you have?'),
                      // Add Ingredient Input
                      IngredientInputWidget(
                        controller: _ingredientController,
                        onAdd: _handleAddIngredient,
                        focusNode: _ingredientFocusNode,
                      ),
                    ],
                  ),
                ),
                // Content Section
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingMd,
                      vertical: AppSizes.vPaddingMd,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Current Ingredients Section
                        const CurrentIngredientsSection(),

                        SizedBox(height: AppSizes.spaceHeightSm),

                        // Popular Additions Section
                        //const PopularAdditionsSection(),
                        //SizedBox(height: AppSizes.spaceHeightSm),

                        // Suggested Additions Section
                        if (ingredientsProvider.currentIngredients.isNotEmpty)
                          const SuggestedAdditionsSection(),
                        SizedBox(height: AppSizes.spaceHeightSm),
                      ],
                    ),
                  ),
                ),

                // Bottom Action Bar
                if (ingredientsProvider.currentIngredients.isNotEmpty)
                  IngredientActionBar(
                    primaryActionText: 'Generate Recipe',
                    primaryActionIcon: Icons.auto_awesome,
                    onPrimaryAction: _handleGenerateRecipe,
                    secondaryActionText: 'Nutrition Info',
                    secondaryActionIcon: Icons.health_and_safety_outlined,
                    onSecondaryAction: () {
                      // TODO: Implement nutrition info
                    },
                  ),
              ],
            );
          },
        ),
        bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 0),
      ),
    );
  }
}
