import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/providers/recipe_provider.dart';
import 'package:ai_ruchi/shared/widgets/common/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RecipePreferencesBottomSheet extends StatelessWidget {
  final VoidCallback onGenerateRecipe;

  const RecipePreferencesBottomSheet({
    super.key,
    required this.onGenerateRecipe,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Consumer<RecipeProvider>(
      builder: (context, recipeProvider, child) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppSizes.radiusXxxl),
              topRight: Radius.circular(AppSizes.radiusXxxl),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 50.w,
                height: 4.h,
                margin: EdgeInsets.only(
                  top: AppSizes.vPaddingSm,
                  bottom: AppSizes.vPaddingXs,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.outline,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
              ),
              SizedBox(height: AppSizes.spaceHeightXs),

              // Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
                child: Text(
                  'Recipe Preferences',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),

              SizedBox(height: AppSizes.spaceHeightMd),

              // Scrollable preferences content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AI Model Selection
                      _buildSectionHeader(
                        context,
                        'AI Model',
                        Icons.psychology_rounded,
                      ),
                      SizedBox(height: AppSizes.spaceHeightXs),
                      Wrap(
                        spacing: 6.w,
                        runSpacing: 6.h,
                        children: RecipeProvider.providers.map((provider) {
                          final isSelected =
                              recipeProvider.selectedProvider == provider;
                          return _PreferenceChip(
                            label: provider.toUpperCase(),
                            isSelected: isSelected,
                            onTap: () => recipeProvider.setProvider(provider),
                            icon: provider == 'openai'
                                ? Icons.auto_awesome
                                : Icons.diamond_outlined,
                          );
                        }).toList(),
                      ),

                      SizedBox(height: AppSizes.spaceHeightMd),

                      // Cuisine Type Selection
                      _buildSectionHeader(
                        context,
                        'Cuisine Type',
                        Icons.restaurant_menu_rounded,
                      ),
                      SizedBox(height: AppSizes.spaceHeightXs),
                      _buildCuisineChips(context, recipeProvider),

                      SizedBox(height: AppSizes.spaceHeightMd),

                      // Dietary Preference Selection
                      _buildSectionHeader(
                        context,
                        'Dietary Preference',
                        Icons.eco_rounded,
                      ),
                      SizedBox(height: AppSizes.spaceHeightXs),
                      _buildDietaryChips(context, recipeProvider),

                      SizedBox(height: AppSizes.spaceHeightMd),
                    ],
                  ),
                ),
              ),

              // Bottom Action Buttons
              Container(
                padding: EdgeInsets.all(AppSizes.paddingSm),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        height: 45.h,
                        text: 'Nutrition Info',
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        textColor: colorScheme.primary,
                        icon: Icons.health_and_safety_outlined,
                        ontap: () {
                          Navigator.pop(context);
                          context.push('/nutrition-info');
                        },
                      ),
                    ),
                    SizedBox(width: AppSizes.spaceSm),
                    Expanded(
                      child: CustomButton(
                        height: 45.h,
                        text: 'Generate Recipe',
                        backgroundColor: colorScheme.primary,
                        textColor: colorScheme.onPrimary,
                        icon: Icons.auto_awesome,
                        ontap: () {
                          Navigator.pop(context);
                          onGenerateRecipe();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: 4.h, top: 4.h),
      child: Row(
        children: [
          Icon(icon, size: AppSizes.iconSm, color: colorScheme.primary),
          SizedBox(width: AppSizes.spaceXs),
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildCuisineChips(
    BuildContext context,
    RecipeProvider recipeProvider,
  ) {
    final cuisineIcons = {
      'none': Icons.public,
      'Italian': Icons.local_pizza,
      'Indian': Icons.restaurant,
      'Chinese': Icons.ramen_dining,
      'Mexican': Icons.local_fire_department,
      'Japanese': Icons.set_meal,
      'Thai': Icons.spa,
      'French': Icons.wine_bar,
      'Mediterranean': Icons.wb_sunny,
      'American': Icons.fastfood,
    };

    return Wrap(
      spacing: 8.w,
      runSpacing: 10.h,
      children: RecipeProvider.cuisines.map((cuisine) {
        final isSelected = recipeProvider.selectedCuisine == cuisine;
        return _PreferenceChip(
          label: cuisine == 'none' ? 'Any' : cuisine,
          isSelected: isSelected,
          onTap: () => recipeProvider.setCuisine(cuisine),
          icon: cuisineIcons[cuisine] ?? Icons.restaurant,
        );
      }).toList(),
    );
  }

  Widget _buildDietaryChips(
    BuildContext context,
    RecipeProvider recipeProvider,
  ) {
    final dietaryIcons = {
      'none': Icons.check_circle_outline,
      'vegetarian': Icons.eco,
      'vegan': Icons.spa,
      'gluten-free': Icons.grain,
      'dairy-free': Icons.no_food,
      'keto': Icons.local_fire_department,
      'paleo': Icons.nature,
      'low-carb': Icons.trending_down,
      'high-protein': Icons.fitness_center,
    };

    return Wrap(
      spacing: 8.w,
      runSpacing: 10.h,
      children: RecipeProvider.dietaryOptions.map((dietary) {
        final isSelected = recipeProvider.selectedDietary == dietary;
        return _PreferenceChip(
          label: dietary == 'none' ? 'None' : dietary.replaceAll('-', ' '),
          isSelected: isSelected,
          onTap: () => recipeProvider.setDietary(dietary),
          icon: dietaryIcons[dietary] ?? Icons.restaurant,
        );
      }).toList(),
    );
  }
}

class _PreferenceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const _PreferenceChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.15),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16.sp,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: 4.w),
            ],
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
