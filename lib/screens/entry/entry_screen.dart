import 'package:ai_ruchi/core/theme/app_shadows.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/core/utils/ingredient_helper.dart';
import 'package:ai_ruchi/providers/ingredients_provider.dart';
import 'package:ai_ruchi/providers/recipe_provider.dart';
import 'package:ai_ruchi/shared/widgets/navigation/app_bottom_navigation_bar.dart';
import 'package:ai_ruchi/shared/widgets/ingredient/current_ingredients_section.dart';
import 'package:ai_ruchi/shared/widgets/ingredient/ingredient_action_bar.dart';
import 'package:ai_ruchi/shared/widgets/ingredient/ingredient_header_widget.dart';
import 'package:ai_ruchi/shared/widgets/ingredient/ingredient_input_widget.dart';
import 'package:ai_ruchi/shared/widgets/ingredient/suggested_additions_section.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

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
    // Navigate to loading screen which handles generation
    context.push('/loading');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer2<IngredientsProvider, RecipeProvider>(
      builder: (context, ingredientsProvider, recipeProvider, child) {
        return SafeArea(
          child: Scaffold(
            body: Column(
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
                      const IngredientHeaderWidget(
                        title: 'What do you have?',
                      ),
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

                        // Suggested Additions Section
                        if (ingredientsProvider
                            .currentIngredients
                            .isNotEmpty)
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
            ),
            bottomNavigationBar: const AppBottomNavigationBar(
              currentIndex: 0,
            ),
          ),
        );
      },
    );
  }
}
