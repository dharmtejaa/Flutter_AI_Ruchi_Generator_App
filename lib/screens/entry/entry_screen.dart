import 'package:ai_ruchi/core/theme/app_shadows.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/shared/widgets/ingredient/categorized_ingredient_suggestions.dart';
import 'package:ai_ruchi/core/utils/ingredient_helper.dart';
import 'package:ai_ruchi/providers/ingredients_provider.dart';
import 'package:ai_ruchi/providers/recipe_provider.dart';
import 'package:ai_ruchi/shared/widgets/common/dismiss_keyboard.dart';
import 'package:ai_ruchi/shared/widgets/recipe/recipe_preferences_bottom_sheet.dart';
import 'package:ai_ruchi/shared/widgets/ingredient/current_ingredients_section.dart';
import 'package:ai_ruchi/shared/widgets/ingredient/ingredient_header_widget.dart';
import 'package:ai_ruchi/shared/widgets/ingredient/ingredient_input_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen>
    with TickerProviderStateMixin {
  final TextEditingController _ingredientController = TextEditingController();
  final FocusNode _ingredientFocusNode = FocusNode();
  late AnimationController _headerAnimationController;
  late Animation<double> _headerAnimation;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabRotationAnimation;
  late Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();

    // FAB animation setup
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabRotationAnimation = Tween<double>(begin: 0.0, end: 0.125).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
    _fabScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOut,
    );
    _headerAnimationController.forward();
  }

  @override
  void dispose() {
    _ingredientController.dispose();
    _ingredientFocusNode.dispose();
    _headerAnimationController.dispose();
    _fabAnimationController.dispose();
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
    context.push('/loading');
  }

  void _showRecipePreferencesSheet(BuildContext context) {
    _fabAnimationController.forward();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) =>
          RecipePreferencesBottomSheet(onGenerateRecipe: _handleGenerateRecipe),
    ).whenComplete(() {
      _fabAnimationController.reverse();
    });
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
          backgroundColor: Colors.transparent,
          floatingActionButton: hasIngredients
              ? AnimatedBuilder(
                  animation: _fabAnimationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _fabScaleAnimation.value,
                      child: Transform.rotate(
                        angle: _fabRotationAnimation.value * 2 * 3.14159,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [colorScheme.primary, colorScheme.secondary],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: FloatingActionButton(
                      onPressed: () => _showRecipePreferencesSheet(context),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      highlightElevation: 0,
                      child: Icon(
                        Icons.auto_awesome,
                        color: colorScheme.onPrimary,
                        size: AppSizes.iconMd,
                      ),
                    ),
                  ),
                )
              : null,
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
                            const IngredientHeaderWidget(
                              title: 'What\'s in your kitchen?',
                            ),
                            SizedBox(height: AppSizes.spaceHeightXs),

                            // Add Ingredient Input
                            IngredientInputWidget(
                              controller: _ingredientController,
                              onAdd: _handleAddIngredient,
                              focusNode: _ingredientFocusNode,
                              hintText: 'e.g., 2 eggs, chicken',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Content Section
                  Expanded(
                    child: hasIngredients
                        ? _buildIngredientsContent(
                            ingredientsProvider,
                            colorScheme,
                            textTheme,
                          )
                        : _buildEmptyState(colorScheme, textTheme),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIngredientsContent(
    IngredientsProvider ingredientsProvider,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSm,
        vertical: AppSizes.vPaddingSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Ingredients Section
          const CurrentIngredientsSection(),

          SizedBox(height: AppSizes.spaceHeightLg),

          // Categorized Ingredient Suggestions (always visible)
          const CategorizedIngredientSuggestions(),

          SizedBox(height: AppSizes.spaceHeightLg),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: AppSizes.vPaddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Empty State Message (on top)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingXl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70.w,
                    height: 70.h,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.3,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_shopping_cart_outlined,
                      size: 30.sp,
                      color: colorScheme.primary.withValues(alpha: 0.7),
                    ),
                  ),
                  SizedBox(height: AppSizes.spaceHeightLg),
                  Text(
                    'No Ingredients Yet',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: AppSizes.spaceHeightSm),
                  Text(
                    'Start by adding ingredients you have in your kitchen. Our AI will suggest delicious recipes!',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: AppSizes.spaceHeightXl),

          // Categorized Ingredient Suggestions (on bottom)
          const CategorizedIngredientSuggestions(),

          SizedBox(height: AppSizes.spaceHeightXl),
        ],
      ),
    );
  }
}
