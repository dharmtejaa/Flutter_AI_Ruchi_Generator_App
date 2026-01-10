import 'package:ai_ruchi/core/utils/recipe_helper.dart';
import 'package:ai_ruchi/shared/widgets/common/custom_snackbar.dart';
import 'package:ai_ruchi/shared/widgets/recipe/recipe_loading_screen.dart';
import 'package:ai_ruchi/core/services/ad_service.dart';
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
    // Load interstitial ad early
    AdService().loadInterstitialAd();

    // Start generation after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateRecipe();
    });
  }

  Future<void> _generateRecipe() async {
    try {
      // Use generateRecipeDirectly since preferences are already set
      // in the bottom sheet before navigating to this screen.
      // This prevents showing the preferences dialog twice.
      final success = await RecipeHelper.generateRecipeDirectly(
        context,
        navigateOnSuccess: false, // We handle navigation
      );

      if (!mounted) return;

      if (success) {
        // Show ad before navigating
        // Show ad before navigating
        await AdService().showInterstitialAd();
        if (mounted) {
          context.pushReplacement('/recipe');
        }
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
