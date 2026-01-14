import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/core/utils/ingredient_helper.dart';
import 'package:ai_ruchi/core/utils/recipe_helper.dart';
import 'package:ai_ruchi/providers/ingredients_provider.dart';
import 'package:ai_ruchi/shared/widgets/common/dismiss_keyboard.dart';
import 'package:ai_ruchi/shared/widgets/ingredient/current_ingredients_section.dart';
import 'package:ai_ruchi/shared/widgets/ingredient/ingredient_action_bar.dart';
import 'package:ai_ruchi/shared/widgets/ingredient/ingredient_header_widget.dart';
import 'package:ai_ruchi/shared/widgets/ingredient/ingredient_input_widget.dart';
import 'package:ai_ruchi/shared/widgets/ingredient/categorized_ingredient_suggestions.dart';
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
    final text = _ingredientController.text;
    IngredientHelper.addIngredientFromText(
      context,
      text,
      onSuccess: () => _ingredientController.clear(),
    );
  }

  Future<void> _handleRegenerateRecipe() async {
    await RecipeHelper.generateRecipeWithPreferences(
      context,
      showLoadingMessage: true,
      loadingMessage: 'Regenerating recipe...',
      navigateOnSuccess: true,
      navigationRoute: '/recipe',
    );
  }

  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: Scaffold(
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

                          // Categorized Ingredient Suggestions
                          const CategorizedIngredientSuggestions(),

                          SizedBox(height: AppSizes.spaceHeightXl),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Action Bar
                  if (provider.currentIngredients.isNotEmpty)
                    IngredientActionBar(
                      primaryActionText: 'Regenerate Recipe',
                      primaryActionIcon: Icons.auto_awesome,
                      onPrimaryAction: _handleRegenerateRecipe,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
