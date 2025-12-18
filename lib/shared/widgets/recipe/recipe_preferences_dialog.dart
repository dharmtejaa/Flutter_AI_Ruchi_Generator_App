import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/providers/recipe_provider.dart';
import 'package:ai_ruchi/shared/widgets/common/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class RecipePreferencesDialog extends StatelessWidget {
  const RecipePreferencesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final recipeProvider = context.watch<RecipeProvider>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: Text(
          'Recipe Preferences',
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMd,
                  vertical: AppSizes.vPaddingSm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Provider Selection
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
                        return _CompactPreferenceChip(
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

                    // Cuisine Selection
                    _buildSectionHeader(
                      context,
                      'Cuisine Type',
                      Icons.restaurant_menu_rounded,
                    ),
                    SizedBox(height: AppSizes.spaceHeightXs),
                    _buildCuisineGrid(context, recipeProvider),

                    SizedBox(height: AppSizes.spaceHeightMd),

                    // Dietary Selection
                    _buildSectionHeader(
                      context,
                      'Dietary Preference',
                      Icons.eco_rounded,
                    ),
                    SizedBox(height: AppSizes.spaceHeightXs),
                    _buildDietaryGrid(context, recipeProvider),

                    SizedBox(height: AppSizes.spaceHeightMd),
                  ],
                ),
              ),
            ),

            // Bottom action buttons
            Padding(
              padding: EdgeInsets.all(AppSizes.paddingSm),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      height: 45.h,
                      text: 'Cancel',
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      textColor: colorScheme.onSurface,
                      ontap: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  SizedBox(width: AppSizes.spaceSm),
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      height: 45.h,
                      text: 'Generate Recipe',
                      icon: Icons.auto_awesome,
                      backgroundColor: colorScheme.primary,
                      textColor: colorScheme.onPrimary,
                      useGradient: true,
                      ontap: () {
                        HapticFeedback.mediumImpact();
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildCuisineGrid(
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
        return _CompactPreferenceChip(
          label: cuisine == 'none' ? 'Any' : cuisine,
          isSelected: isSelected,
          onTap: () => recipeProvider.setCuisine(cuisine),
          icon: cuisineIcons[cuisine] ?? Icons.restaurant,
        );
      }).toList(),
    );
  }

  Widget _buildDietaryGrid(
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
        return _CompactPreferenceChip(
          label: dietary == 'none' ? 'None' : dietary.replaceAll('-', ' '),
          isSelected: isSelected,
          onTap: () => recipeProvider.setDietary(dietary),
          icon: dietaryIcons[dietary] ?? Icons.restaurant,
        );
      }).toList(),
    );
  }
}

class _CompactPreferenceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const _CompactPreferenceChip({
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
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
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
