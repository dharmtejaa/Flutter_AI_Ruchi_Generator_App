import 'package:ai_ruchi/providers/ingredients_provider.dart';
import 'package:ai_ruchi/providers/recipe_provider.dart';
import 'package:ai_ruchi/shared/widgets/common/custom_snackbar.dart';
import 'package:ai_ruchi/shared/widgets/recipe/recipe_preferences_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RecipeHelper {
  /// Generate recipe with preferences dialog
  /// Returns true if recipe was generated successfully
  static Future<bool> generateRecipeWithPreferences(
    BuildContext context, {
    bool showLoadingMessage = false,
    String? loadingMessage,
    bool navigateOnSuccess = false,
    String? navigationRoute,
  }) async {
    final ingredientsProvider = context.read<IngredientsProvider>();
    
    if (ingredientsProvider.currentIngredients.isEmpty) {
      CustomSnackBar.showWarning(
        context,
        'Please add at least one ingredient',
      );
      return false;
    }

    // Show preferences dialog
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const RecipePreferencesDialog(),
    );

    if (result != true) return false;

    final recipeProvider = context.read<RecipeProvider>();

    if (showLoadingMessage) {
      CustomSnackBar.showInfo(
        context,
        loadingMessage ?? 'Generating recipe...',
      );
    }

    // Generate recipe
    await recipeProvider.generateRecipe(
      ingredientsProvider.currentIngredients,
    );

    if (!context.mounted) return false;

    if (recipeProvider.error == null && recipeProvider.recipe != null) {
      if (navigateOnSuccess && navigationRoute != null) {
        // Small delay to ensure loading screen stays visible during transition
        await Future.delayed(const Duration(milliseconds: 150));
        if (!context.mounted) return true;

        try {
          // Navigate and wait for it to complete
          await context.push(navigationRoute);
          // Navigation completed successfully - flag will be reset when screen rebuilds
        } catch (e) {
          if (context.mounted) {
            CustomSnackBar.showError(context, 'Navigation error: $e');
          }
          return false;
        }
      }
      return true;
    } else {
      CustomSnackBar.showError(
        context,
        recipeProvider.error ?? 'Failed to generate recipe',
      );
      return false;
    }
  }

  /// Regenerate recipe (used in recipe screen)
  static Future<void> regenerateRecipe(BuildContext context) async {
    final result = await generateRecipeWithPreferences(
      context,
      showLoadingMessage: true,
      loadingMessage: 'Regenerating recipe...',
    );

    if (result && context.mounted) {
      final recipeProvider = context.read<RecipeProvider>();
      if (recipeProvider.error == null && recipeProvider.recipe != null) {
        CustomSnackBar.showSuccess(
          context,
          'Recipe regenerated successfully!',
        );
      }
    }
  }
}

