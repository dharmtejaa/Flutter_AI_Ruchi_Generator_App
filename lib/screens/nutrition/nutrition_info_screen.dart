import 'dart:math' as math;
import 'dart:async';
import 'package:ai_ruchi/core/services/ad_service.dart';
import 'package:ai_ruchi/core/services/recipe_api_service.dart';
import 'package:ai_ruchi/core/theme/app_shadows.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/models/ingredient.dart';
import 'package:ai_ruchi/models/recipe.dart';
import 'package:ai_ruchi/providers/ingredients_provider.dart';
import 'package:ai_ruchi/providers/recipe_provider.dart';
import 'package:ai_ruchi/shared/widgets/common/nutrition_summary_row.dart';
import 'package:ai_ruchi/shared/widgets/recipe/recipe_loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/// A screen that shows nutrition info from API based on added ingredients
class NutritionInfoScreen extends StatefulWidget {
  const NutritionInfoScreen({super.key});

  @override
  State<NutritionInfoScreen> createState() => _NutritionInfoScreenState();
}

class _NutritionInfoScreenState extends State<NutritionInfoScreen> {
  bool _isLoading = false;
  Recipe? _nutritionRecipe;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchNutritionData();
    });
  }

  Future<void> _fetchNutritionData() async {
    final ingredients = context.read<IngredientsProvider>().currentIngredients;
    if (ingredients.isEmpty) return;

    final recipeProvider = context.read<RecipeProvider>();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Start Ad and API fetch concurrently
      // This covers the loading time with the ad
      final adFuture = AdService().showInterstitialAd();
      final recipeFuture = RecipeApiService.generateRecipe(
        ingredients: ingredients,
        provider: recipeProvider.selectedProvider,
        cuisine: recipeProvider.selectedCuisine,
        dietary: recipeProvider.selectedDietary,
      );

      // Wait for both results
      final results = await Future.wait([adFuture, recipeFuture]);
      final recipe = results[1] as Recipe; // Get recipe from 2nd future

      if (mounted) {
        setState(() {
          _nutritionRecipe = recipe;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        while (errorMessage.contains('Exception: ')) {
          errorMessage = errorMessage.replaceAll('Exception: ', '');
        }
        setState(() {
          _errorMessage = errorMessage.trim();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Consumer<IngredientsProvider>(
        builder: (context, provider, child) {
          final ingredients = provider.currentIngredients;

          if (ingredients.isEmpty) {
            return _buildEmptyState(context, colorScheme, textTheme);
          }

          if (_isLoading) {
            return _buildLoadingState(colorScheme, textTheme);
          }

          if (_errorMessage != null) {
            return _buildErrorState(colorScheme, textTheme);
          }

          if (_nutritionRecipe == null) {
            return _buildLoadingState(colorScheme, textTheme);
          }

          return _buildSliverContent(
            context,
            colorScheme,
            textTheme,
            ingredients,
            _nutritionRecipe!,
          );
        },
      ),
    );
  }

  Widget _buildSliverContent(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    List<Ingredient> ingredients,
    Recipe recipe,
  ) {
    final nutrition = recipe.nutrition.perServing;
    final macros = nutrition.macros;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
            size: 20.sp,
          ),
        ),
        title: Text(
          'Nutrition Info',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nutrition Summary Row at top
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.paddingSm,
                vertical: AppSizes.vPaddingSm,
              ),
              child: NutritionSummaryRow(nutrition: nutrition, isCompact: true),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(AppSizes.paddingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ingredients Section
                  _SectionHeader(
                    title: 'Your Ingredients',
                    icon: Icons.shopping_basket_outlined,
                    count: ingredients.length,
                  ),
                  SizedBox(height: AppSizes.spaceHeightSm),
                  _IngredientsCard(ingredients: ingredients),

                  SizedBox(height: AppSizes.spaceHeightLg),

                  // Macronutrients with Pie Chart
                  _SectionHeader(
                    title: 'Macronutrients',
                    icon: Icons.pie_chart_outline,
                  ),
                  SizedBox(height: AppSizes.spaceHeightSm),
                  _MacroChartCard(macros: macros),

                  SizedBox(height: AppSizes.spaceHeightMd),

                  // Macro Details (Fiber, Sugar)
                  _MacroDetailsGrid(macros: macros),

                  // Vitamins Section
                  if (nutrition.micros.vitamins.isNotEmpty) ...[
                    SizedBox(height: AppSizes.spaceHeightLg),
                    _SectionHeader(
                      title: 'Vitamins',
                      icon: Icons.local_pharmacy_outlined,
                    ),
                    SizedBox(height: AppSizes.spaceHeightSm),
                    _NutrientsList(
                      nutrients: nutrition.micros.vitamins,
                      accentColor: const Color(0xFF4CAF50),
                    ),
                  ],

                  // Minerals Section
                  if (nutrition.micros.minerals.isNotEmpty) ...[
                    SizedBox(height: AppSizes.spaceHeightLg),
                    _SectionHeader(
                      title: 'Minerals',
                      icon: Icons.science_outlined,
                    ),
                    SizedBox(height: AppSizes.spaceHeightSm),
                    _NutrientsList(
                      nutrients: nutrition.micros.minerals,
                      accentColor: const Color(0xFF2196F3),
                    ),
                  ],

                  // Health Benefits
                  if (recipe.healthBenefits.isNotEmpty) ...[
                    SizedBox(height: AppSizes.spaceHeightLg),
                    _SectionHeader(
                      title: 'Health Benefits',
                      icon: Icons.favorite_outline,
                    ),
                    SizedBox(height: AppSizes.spaceHeightSm),
                    _HealthBenefitsCard(benefits: recipe.healthBenefits),
                  ],

                  // Tips Section
                  if (recipe.tips != null && recipe.tips!.isNotEmpty) ...[
                    SizedBox(height: AppSizes.spaceHeightLg),
                    _SimpleInfoCard(
                      icon: Icons.lightbulb_outline,
                      iconColor: const Color(0xFFFFA726),
                      title: "Chef's Tip",
                      content: recipe.tips!,
                    ),
                  ],

                  // Target Audience Section
                  if (recipe.targetAudience.isNotEmpty) ...[
                    SizedBox(height: AppSizes.spaceHeightLg),
                    _SimpleChipsCard(
                      icon: Icons.groups_outlined,
                      title: 'Suitable For',
                      items: recipe.targetAudience,
                    ),
                  ],

                  // Disclaimer
                  if (recipe.disclaimer.isNotEmpty) ...[
                    SizedBox(height: AppSizes.spaceHeightLg),
                    _DisclaimerText(disclaimer: recipe.disclaimer),
                  ],

                  SizedBox(height: AppSizes.spaceHeightXl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(ColorScheme colorScheme, TextTheme textTheme) {
    return const RecipeLoadingScreen(
      title: 'Analyzing Nutrition',
      icon: Icons.health_and_safety_rounded,
    );
  }

  Widget _buildErrorState(ColorScheme colorScheme, TextTheme textTheme) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(AppSizes.paddingSm),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Nutrition Info',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.paddingXl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80.w,
                      height: 80.h,
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer.withValues(
                          alpha: 0.4,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline,
                        size: 40.sp,
                        color: colorScheme.error,
                      ),
                    ),
                    SizedBox(height: AppSizes.spaceHeightLg),
                    Text(
                      'Failed to load nutrition',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: AppSizes.spaceHeightSm),
                    Text(
                      _errorMessage ?? 'Unknown error occurred',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: AppSizes.spaceHeightLg),
                    ElevatedButton.icon(
                      onPressed: _fetchNutritionData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(AppSizes.paddingSm),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Nutrition Info',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.paddingXl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100.w,
                      height: 100.h,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withValues(
                          alpha: 0.4,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.health_and_safety_outlined,
                        size: 48.sp,
                        color: colorScheme.primary.withValues(alpha: 0.8),
                      ),
                    ),
                    SizedBox(height: AppSizes.spaceHeightLg),
                    Text(
                      'No Ingredients',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: AppSizes.spaceHeightSm),
                    Text(
                      'Add some ingredients to see their nutrition information.',
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
          ),
        ],
      ),
    );
  }
}

// Section Header
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final int? count;

  const _SectionHeader({required this.title, required this.icon, this.count});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 20.sp, color: colorScheme.primary),
        SizedBox(width: 8.w),
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        if (count != null) ...[
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Text(
              '$count',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// Ingredients Card
class _IngredientsCard extends StatelessWidget {
  final List<Ingredient> ingredients;

  const _IngredientsCard({required this.ingredients});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: AppShadows.cardShadow(context),
      ),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: ingredients.map((ingredient) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Text(
              '${ingredient.quantity.toStringAsFixed(ingredient.quantity.truncateToDouble() == ingredient.quantity ? 0 : 1)} ${ingredient.unit} ${ingredient.name}',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Macro Chart Card with Pie Chart
class _MacroChartCard extends StatelessWidget {
  final Macros macros;

  const _MacroChartCard({required this.macros});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: AppShadows.cardShadow(context),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100.w,
            height: 100.h,
            child: CustomPaint(
              painter: _MacroPieChartPainter(
                carbs: macros.carbohydrates.percentage,
                protein: macros.protein.percentage,
                fat: macros.fat.percentage,
              ),
            ),
          ),
          SizedBox(width: AppSizes.spaceLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MacroLegendItem(
                  color: const Color(0xFF4CAF50),
                  label: 'Carbs',
                  value: macros.carbohydrates.value,
                  unit: macros.carbohydrates.unit,
                  percentage: macros.carbohydrates.percentage,
                ),
                SizedBox(height: 8.h),
                _MacroLegendItem(
                  color: const Color(0xFF2196F3),
                  label: 'Protein',
                  value: macros.protein.value,
                  unit: macros.protein.unit,
                  percentage: macros.protein.percentage,
                ),
                SizedBox(height: 8.h),
                _MacroLegendItem(
                  color: const Color(0xFF9C27B0),
                  label: 'Fat',
                  value: macros.fat.value,
                  unit: macros.fat.unit,
                  percentage: macros.fat.percentage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Macro Legend Item
class _MacroLegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final double value;
  final String unit;
  final double percentage;

  const _MacroLegendItem({
    required this.color,
    required this.label,
    required this.value,
    required this.unit,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 10.w,
          height: 10.h,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          '${value.toInt()}$unit',
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            '${percentage.toInt()}%',
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

// Macro Details Grid (Fiber, Sugar)
class _MacroDetailsGrid extends StatelessWidget {
  final Macros macros;

  const _MacroDetailsGrid({required this.macros});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final otherMacros = macros.otherMacros;

    if (otherMacros.isEmpty) return const SizedBox.shrink();

    return Row(
      children: otherMacros.asMap().entries.map((entry) {
        final index = entry.key;
        final macro = entry.value;
        final isLast = index == otherMacros.length - 1;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 8.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    macro.name,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      '${macro.value % 1 == 0 ? macro.value.toInt() : macro.value.toStringAsFixed(1)} ${macro.unit}',
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// Nutrients List (Expandable)
class _NutrientsList extends StatefulWidget {
  final List<MicroNutrientInfo> nutrients;
  final Color accentColor;

  const _NutrientsList({required this.nutrients, required this.accentColor});

  @override
  State<_NutrientsList> createState() => _NutrientsListState();
}

class _NutrientsListState extends State<_NutrientsList> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final hasMore = widget.nutrients.length > 3;
    final visibleNutrients = _isExpanded
        ? widget.nutrients
        : widget.nutrients.take(3).toList();
    final remainingCount = widget.nutrients.length - 3;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: Column(
              children: visibleNutrients.asMap().entries.map((entry) {
                final index = entry.key;
                final nutrient = entry.value;
                final isLast = index == visibleNutrients.length - 1 && !hasMore;

                return _NutrientRow(
                  name: nutrient.name,
                  value: nutrient.value,
                  unit: nutrient.unit,
                  accentColor: widget.accentColor,
                  showDivider: !isLast,
                );
              }).toList(),
            ),
          ),
          if (hasMore)
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppSizes.radiusMd),
                bottomRight: Radius.circular(AppSizes.radiusMd),
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(AppSizes.radiusMd),
                    bottomRight: Radius.circular(AppSizes.radiusMd),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isExpanded ? 'Show less' : 'Show $remainingCount more',
                      style: textTheme.labelMedium?.copyWith(
                        color: widget.accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 18.sp,
                        color: widget.accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Nutrient Row
class _NutrientRow extends StatelessWidget {
  final String name;
  final double value;
  final String unit;
  final Color accentColor;
  final bool showDivider;

  const _NutrientRow({
    required this.name,
    required this.value,
    required this.unit,
    required this.accentColor,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMd,
            vertical: 12.h,
          ),
          child: Row(
            children: [
              Container(
                width: 6.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  name,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value % 1 == 0
                          ? value.toInt().toString()
                          : value.toStringAsFixed(1),
                      style: textTheme.bodyMedium?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      unit,
                      style: textTheme.bodySmall?.copyWith(
                        color: accentColor.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: AppSizes.paddingMd + 18.w,
            endIndent: AppSizes.paddingMd,
            color: colorScheme.outline.withValues(alpha: 0.08),
          ),
      ],
    );
  }
}

// Health Benefits Card
class _HealthBenefitsCard extends StatelessWidget {
  final List<String> benefits;

  const _HealthBenefitsCard({required this.benefits});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: AppShadows.cardShadow(context),
      ),
      child: Column(
        children: benefits.map((benefit) {
          final isLast = benefit == benefits.last;
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: const Color(0xFF66BB6A),
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        benefit,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  color: colorScheme.outline.withValues(alpha: 0.15),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// Pie Chart Painter
class _MacroPieChartPainter extends CustomPainter {
  final double carbs;
  final double protein;
  final double fat;

  _MacroPieChartPainter({
    required this.carbs,
    required this.protein,
    required this.fat,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 5;
    final innerRadius = radius * 0.6;
    final total = carbs + protein + fat;
    if (total == 0) return;

    double startAngle = -math.pi / 2;
    _drawArc(
      canvas,
      center,
      radius,
      innerRadius,
      startAngle,
      (carbs / total) * 2 * math.pi,
      const Color(0xFF4CAF50),
    );
    startAngle += (carbs / total) * 2 * math.pi;
    _drawArc(
      canvas,
      center,
      radius,
      innerRadius,
      startAngle,
      (protein / total) * 2 * math.pi,
      const Color(0xFF2196F3),
    );
    startAngle += (protein / total) * 2 * math.pi;
    _drawArc(
      canvas,
      center,
      radius,
      innerRadius,
      startAngle,
      (fat / total) * 2 * math.pi,
      const Color(0xFF9C27B0),
    );
  }

  void _drawArc(
    Canvas canvas,
    Offset center,
    double outerRadius,
    double innerRadius,
    double startAngle,
    double sweepAngle,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(
        center.dx + innerRadius * math.cos(startAngle),
        center.dy + innerRadius * math.sin(startAngle),
      )
      ..lineTo(
        center.dx + outerRadius * math.cos(startAngle),
        center.dy + outerRadius * math.sin(startAngle),
      )
      ..arcTo(
        Rect.fromCircle(center: center, radius: outerRadius),
        startAngle,
        sweepAngle,
        false,
      )
      ..lineTo(
        center.dx + innerRadius * math.cos(startAngle + sweepAngle),
        center.dy + innerRadius * math.sin(startAngle + sweepAngle),
      )
      ..arcTo(
        Rect.fromCircle(center: center, radius: innerRadius),
        startAngle + sweepAngle,
        -sweepAngle,
        false,
      )
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Simple Info Card (Tips)
class _SimpleInfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String content;

  const _SimpleInfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: AppShadows.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            content,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// Simple Chips Card (Target Audience)
class _SimpleChipsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> items;

  const _SimpleChipsCard({
    required this.icon,
    required this.title,
    required this.items,
  });

  IconData _getAudienceIcon(String audience) {
    final lower = audience.toLowerCase();
    if (lower.contains('family') || lower.contains('families')) {
      return Icons.family_restroom;
    } else if (lower.contains('kid') || lower.contains('children')) {
      return Icons.child_care;
    } else if (lower.contains('adult')) {
      return Icons.person;
    } else if (lower.contains('athlete') || lower.contains('fitness')) {
      return Icons.fitness_center;
    } else if (lower.contains('senior') || lower.contains('elderly')) {
      return Icons.elderly;
    } else if (lower.contains('vegetarian') || lower.contains('vegan')) {
      return Icons.eco;
    } else if (lower.contains('busy') || lower.contains('professional')) {
      return Icons.work;
    } else if (lower.contains('student')) {
      return Icons.school;
    } else if (lower.contains('health') || lower.contains('diet')) {
      return Icons.favorite;
    }
    return Icons.person_outline;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: AppShadows.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colorScheme.primary, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: items.map((item) {
              final audienceIcon = _getAudienceIcon(item);
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: AppSizes.paddingAllSm,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.1,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        audienceIcon,
                        size: AppSizes.iconSm,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(width: AppSizes.spaceSm),
                    Flexible(
                      child: Text(
                        item,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// Disclaimer Text
class _DisclaimerText extends StatelessWidget {
  final String disclaimer;
  const _DisclaimerText({required this.disclaimer});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.paddingSm),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: colorScheme.onSurfaceVariant,
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              disclaimer,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
