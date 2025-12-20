import 'package:ai_ruchi/core/theme/app_shadows.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/shared/widgets/ingredient/categorized_ingredient_suggestions.dart';
import 'package:ai_ruchi/core/utils/ingredient_helper.dart';
import 'package:ai_ruchi/providers/ingredients_provider.dart';
import 'package:ai_ruchi/providers/recipe_provider.dart';
import 'package:ai_ruchi/shared/widgets/common/dismiss_keyboard.dart';
import 'package:ai_ruchi/shared/widgets/ingredient/current_ingredients_section.dart';
import 'package:ai_ruchi/shared/widgets/ingredient/ingredient_action_bar.dart';
import 'package:ai_ruchi/shared/widgets/ingredient/ingredient_header_widget.dart';
import 'package:ai_ruchi/shared/widgets/ingredient/ingredient_input_widget.dart';
import 'package:ai_ruchi/shared/widgets/ingredient/suggested_additions_section.dart';
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
  }

  @override
  void dispose() {
    _ingredientController.dispose();
    _ingredientFocusNode.dispose();
    _headerAnimationController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Consumer2<IngredientsProvider, RecipeProvider>(
      builder: (context, ingredientsProvider, recipeProvider, child) {
        final hasIngredients =
            ingredientsProvider.currentIngredients.isNotEmpty;

        return DismissKeyboard(
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
                        vertical: AppSizes.vPaddingMd,
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
                          SizedBox(height: AppSizes.spaceHeightSm),

                          // Add Ingredient Input
                          IngredientInputWidget(
                            controller: _ingredientController,
                            onAdd: _handleAddIngredient,
                            focusNode: _ingredientFocusNode,
                            hintText:
                                'Type an ingredient (e.g., 2 eggs, chicken...)',
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

                // Bottom Action Bar
                if (hasIngredients)
                  IngredientActionBar(
                    primaryActionText: 'Generate Recipe',
                    primaryActionIcon: Icons.auto_awesome,
                    onPrimaryAction: _handleGenerateRecipe,
                    secondaryActionText: 'Nutrition Info',
                    secondaryActionIcon: Icons.health_and_safety_outlined,
                    onSecondaryAction: () {
                      context.push('/nutrition-info');
                    },
                  ),
              ],
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

          SizedBox(height: AppSizes.spaceHeightSm),

          // Suggested Additions Section
          const SuggestedAdditionsSection(),

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
          // Categorized Ingredient Suggestions
          const CategorizedIngredientSuggestions(),
          SizedBox(height: AppSizes.spaceHeightXl),

          // Empty State Message
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
                  SizedBox(height: AppSizes.spaceHeightXl),
                  // Quick add suggestions
                  Wrap(
                    spacing: AppSizes.spaceSm,
                    runSpacing: AppSizes.spaceHeightSm,
                    alignment: WrapAlignment.center,
                    children: [
                      _QuickAddChip(
                        label: '🥚 Eggs',
                        onTap: () => _quickAdd('eggs'),
                      ),
                      _QuickAddChip(
                        label: '🍗 Chicken',
                        onTap: () => _quickAdd('chicken'),
                      ),
                      _QuickAddChip(
                        label: '🍅 Tomatoes',
                        onTap: () => _quickAdd('tomatoes'),
                      ),
                      _QuickAddChip(
                        label: '🧅 Onions',
                        onTap: () => _quickAdd('onions'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSizes.spaceHeightXl),
        ],
      ),
    );
  }

  void _quickAdd(String ingredient) {
    _ingredientController.text = ingredient;
    _handleAddIngredient();
  }
}

class _QuickAddChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickAddChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMd,
          vertical: AppSizes.vPaddingSm,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
          boxShadow: AppShadows.cardShadow(context),
        ),
        child: Text(
          label,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
