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
  bool _isGenerating = true;
  bool _adComplete = false;
  bool? _generationSuccess;
  String? _errorMessage;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    // Start both ad and generation immediately in parallel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startParallelProcessing();
    });
  }

  Future<void> _startParallelProcessing() async {
    // Run ad and generation in parallel
    await Future.wait([_showAdImmediately(), _generateRecipeInBackground()]);

    // Both completed, navigate
    _tryNavigate();
  }

  Future<void> _showAdImmediately() async {
    try {
      // Load ad if not ready, then show immediately
      AdService().loadInterstitialAd();
      // Small delay to let ad load
      await Future.delayed(const Duration(milliseconds: 500));
      await AdService().showInterstitialAd();
    } catch (_) {
      // Ad failed, continue anyway
    } finally {
      if (mounted) {
        _adComplete = true;
        // Check if we can navigate now
        _tryNavigate();
      }
    }
  }

  Future<void> _generateRecipeInBackground() async {
    try {
      final success = await RecipeHelper.generateRecipeDirectly(
        context,
        navigateOnSuccess: false,
      );

      if (mounted) {
        _isGenerating = false;
        _generationSuccess = success;
        // Check if we can navigate now
        _tryNavigate();
      }
    } catch (e) {
      if (mounted) {
        _isGenerating = false;
        _generationSuccess = false;
        _errorMessage = e.toString();
        // Check if we can navigate now
        _tryNavigate();
      }
    }
  }

  void _tryNavigate() {
    // Only navigate if: mounted, ad done, generation done, and haven't navigated yet
    if (!mounted || !_adComplete || _isGenerating || _hasNavigated) return;

    _hasNavigated = true; // Prevent double navigation

    if (_generationSuccess == true) {
      context.pushReplacement('/recipe');
    } else {
      if (_errorMessage != null) {
        CustomSnackBar.showError(context, 'Error generating recipe');
      }
      if (context.canPop()) {
        context.pop();
      }
    }
  }

  Future<void> _showCancelConfirmationDialog() async {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final shouldCancel = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: colorScheme.surface,
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant_menu_rounded,
                color: Colors.orange,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Stop Generating?',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              'Your delicious recipe is almost ready! Are you sure you want to stop?',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Buttons - Keep Waiting (primary) first, then Stop
            Column(
              children: [
                // Primary action - Keep Waiting
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    icon: Icon(Icons.hourglass_top_rounded, size: 20),
                    label: Text(
                      'Keep Waiting',
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Secondary action - Stop
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.error,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Yes, Stop Generation',
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (shouldCancel == true && mounted) {
      if (context.canPop()) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showCancelConfirmationDialog();
      },
      child: const Scaffold(body: RecipeLoadingScreen()),
    );
  }
}
