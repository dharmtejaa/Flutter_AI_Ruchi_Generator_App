import 'package:ai_ruchi/core/utils/recipe_helper.dart';
import 'package:ai_ruchi/shared/widgets/common/custom_snackbar.dart';
import 'package:ai_ruchi/shared/widgets/recipe/recipe_loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RecipeGenerationLoadingScreen extends StatefulWidget {
  const RecipeGenerationLoadingScreen({super.key});

  @override
  State<RecipeGenerationLoadingScreen> createState() =>
      _RecipeGenerationLoadingScreenState();
}

class _RecipeGenerationLoadingScreenState
    extends State<RecipeGenerationLoadingScreen> {
  @override
  void initState() {
    super.initState();
    // Start generation after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateRecipe();
    });
  }

  Future<void> _generateRecipe() async {
    try {
      // We don't show the dialog here because it should be shown BEFORE navigation
      // But RecipeHelper.generateRecipeWithPreferences shows the dialog.
      // So we need to handle this carefully.

      // Actually, the best UX is:
      // 1. Entry Screen -> Show Dialog
      // 2. If confirmed -> Navigate to this Loading Screen
      // 3. This Loading Screen -> Calls generateRecipe (without dialog)

      // However, RecipeHelper combines them.
      // For now, let's just call generateRecipeWithPreferences but we need to handle the dialog issue.
      // If we are already on this screen, showing a dialog on top is fine.

      final success = await RecipeHelper.generateRecipeWithPreferences(
        context,
        navigateOnSuccess: false, // We handle navigation
      );

      if (!mounted) return;

      if (success) {
        // Navigate to recipe result
        context.pushReplacement('/recipe');
      } else {
        // Go back to entry screen if cancelled or failed
        if (context.canPop()) {
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Error generating recipe: $e');
        if (context.canPop()) {
          context.pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: RecipeLoadingScreen());
  }
}
