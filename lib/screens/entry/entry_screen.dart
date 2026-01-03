import 'package:ai_ruchi/core/services/haptic_service.dart';
import 'package:ai_ruchi/core/services/tutorial_service.dart';
import 'package:ai_ruchi/core/theme/app_shadows.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/shared/widgets/common/custom_snackbar.dart';
import 'package:ai_ruchi/shared/widgets/ingredient/categorized_ingredient_suggestions.dart';
import 'package:ai_ruchi/core/utils/ingredient_helper.dart';
import 'package:ai_ruchi/providers/ingredients_provider.dart';
import 'package:ai_ruchi/providers/recipe_provider.dart';
import 'package:ai_ruchi/shared/widgets/common/dismiss_keyboard.dart';
import 'package:ai_ruchi/shared/widgets/recipe/recipe_preferences_bottom_sheet.dart';
import 'package:ai_ruchi/shared/widgets/ingredient/current_ingredients_section.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EntryScreen extends StatefulWidget {
  /// GlobalKey for the Recipes nav item (for generate tutorial)
  final GlobalKey? recipesNavKey;

  const EntryScreen({super.key, this.recipesNavKey});

  @override
  State<EntryScreen> createState() => EntryScreenState();
}

/// State class with public name so it can be accessed via GlobalKey
class EntryScreenState extends State<EntryScreen>
    with TickerProviderStateMixin {
  final TextEditingController _ingredientController = TextEditingController();
  final FocusNode _ingredientFocusNode = FocusNode();
  late AnimationController _headerAnimationController;
  late Animation<double> _headerAnimation;

  // ============================================================================
  // TUTORIAL GLOBAL KEYS
  // ============================================================================
  final GlobalKey _inputFieldKey = GlobalKey();
  final GlobalKey _addButtonKey = GlobalKey();
  final GlobalKey _categorySuggestionsKey = GlobalKey();

  // Track if generate tutorial was shown
  bool _hasShownGenerateTutorial = false;
  late IngredientsProvider _ingredientsProvider;

  @override
  void initState() {
    super.initState();

    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOut,
    );
    _headerAnimationController.forward();

    // Listen to ingredient changes to trigger tutorial
    _ingredientsProvider = context.read<IngredientsProvider>();
    _ingredientsProvider.addListener(_onIngredientsChanged);

    // Check and show tutorial after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowTutorial();
    });
  }

  @override
  void dispose() {
    _ingredientsProvider.removeListener(_onIngredientsChanged);
    _ingredientController.dispose();
    _ingredientFocusNode.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  void _onIngredientsChanged() {
    if (_ingredientsProvider.currentIngredients.isNotEmpty) {
      _checkAndShowGenerateNavTutorial();
    }
  }

  /// Check if tutorial should be shown
  Future<void> _checkAndShowTutorial() async {
    final isShown = await TutorialService.isEntryTutorialShown();
    if (!isShown && mounted) {
      // Small delay for smooth transition after screen load
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        TutorialService.showEntryTutorial(
          context: context,
          inputKey: _inputFieldKey,
          addButtonKey: _addButtonKey,
          categorySuggestionsKey: _categorySuggestionsKey,
          generateButtonKey: null,
        );
      }
    }
  }

  /// Show generate nav tutorial after adding first ingredient
  /// Hides keyboard first so the bottom nav is visible
  Future<void> _checkAndShowGenerateNavTutorial() async {
    if (_hasShownGenerateTutorial || widget.recipesNavKey == null) return;

    final isShown = await TutorialService.isGenerateNavTutorialShown();
    if (!isShown && mounted) {
      _hasShownGenerateTutorial = true;

      // Unfocus and hide keyboard first
      _ingredientFocusNode.unfocus();
      FocusScope.of(context).unfocus();

      // Wait for keyboard to dismiss before showing tutorial
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        TutorialService.showGenerateNavTutorial(
          context: context,
          recipesNavKey: widget.recipesNavKey!,
        );
      }
    }
  }

  void _handleAddIngredient() {
    HapticService.lightImpact();
    final text = _ingredientController.text;
    IngredientHelper.addIngredientFromText(
      context,
      text,
      onSuccess: () {
        _ingredientController.clear();
        // Listener will handle tutorial trigger
      },
    );
  }

  /// Handle recipe generation - goes directly to loading screen
  /// (preferences already set in bottom sheet)
  Future<void> _handleGenerateRecipe() async {
    context.push('/loading');
  }

  /// Public method to show preferences bottom sheet
  /// Called from MainShellScreen when user re-taps the Recipes tab
  void showPreferencesSheet() {
    final ingredientsProvider = context.read<IngredientsProvider>();

    if (ingredientsProvider.currentIngredients.isEmpty) {
      CustomSnackBar.showWarning(context, 'Please add at least one ingredient');
      return;
    }

    _showRecipePreferencesSheet(context);
  }

  void _showRecipePreferencesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) =>
          RecipePreferencesBottomSheet(onGenerateRecipe: _handleGenerateRecipe),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Consumer2<IngredientsProvider, RecipeProvider>(
      builder: (context, ingredientsProvider, recipeProvider, child) {
        final hasIngredients =
            ingredientsProvider.currentIngredients.isNotEmpty;

        return Scaffold(
          body: DismissKeyboard(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Animated Header Section
                  FadeTransition(
                    opacity: _headerAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -0.2),
                        end: Offset.zero,
                      ).animate(_headerAnimation),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingMd,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              'What\'s in your kitchen?',
                              style: textTheme.headlineMedium,
                            ),
                            SizedBox(height: AppSizes.spaceHeightSm),

                            // Add Ingredient Input with Tutorial Keys
                            _buildInputWithTutorialKeys(colorScheme),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Content Section
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Column(
                              mainAxisAlignment: hasIngredients
                                  ? MainAxisAlignment.start
                                  : MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Show empty state or ingredients list
                                if (hasIngredients)
                                  const CurrentIngredientsSection()
                                else
                                  _buildEmptyState(colorScheme, textTheme),

                                SizedBox(height: AppSizes.spaceHeightMd),

                                // Categorized Ingredient Suggestions with Tutorial Key
                                Container(
                                  key: _categorySuggestionsKey,
                                  child:
                                      const CategorizedIngredientSuggestions(),
                                ),

                                SizedBox(height: AppSizes.spaceHeightXl),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build the input row with tutorial keys
  Widget _buildInputWithTutorialKeys(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: Container(
            key: _inputFieldKey,
            child: TextField(
              controller: _ingredientController,
              focusNode: _ingredientFocusNode,
              onSubmitted: (_) => _handleAddIngredient(),
              decoration: InputDecoration(
                hintText: 'e.g., 2 eggs, chicken',
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusXxxl),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusXxxl),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusXxxl),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 1.5,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMd,
                  vertical: AppSizes.vPaddingSm,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: AppSizes.spaceXs),
        GestureDetector(
          key: _addButtonKey,
          onTap: _handleAddIngredient,
          child: Container(
            height: 45.h,
            width: 45.w,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(AppSizes.radiusXxxl),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.add,
              color: colorScheme.onPrimary,
              size: AppSizes.iconLg,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppSizes.vPaddingMd,
        horizontal: AppSizes.paddingXl,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: AppSizes.spaceHeightLg),
          Icon(
            Icons.playlist_add,
            size: AppSizes.iconXl,
            color: colorScheme.primary,
          ),
          SizedBox(height: AppSizes.spaceHeightXs),
          Text('No Ingredients Yet', style: textTheme.headlineSmall),
          SizedBox(height: AppSizes.spaceHeightSm),
          Text(
            'Start by adding ingredients you have in your kitchen. Our AI will suggest delicious recipes!',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
