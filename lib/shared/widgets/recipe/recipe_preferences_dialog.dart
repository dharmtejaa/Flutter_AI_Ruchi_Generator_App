import 'package:ai_ruchi/core/theme/app_shadows.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/providers/recipe_provider.dart';
import 'package:ai_ruchi/shared/widgets/common/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecipePreferencesDialog extends StatelessWidget {
  const RecipePreferencesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final recipeProvider = context.watch<RecipeProvider>();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Container(
        padding: EdgeInsets.all(AppSizes.paddingLg),
        constraints: BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recipe Preferences',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: AppSizes.spaceHeightLg),

              // Provider Selection
              Text(
                'Select Model',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: AppSizes.spaceHeightSm),
              Wrap(
                spacing: AppSizes.spaceSm,
                runSpacing: AppSizes.spaceHeightSm,
                children: RecipeProvider.providers.map((provider) {
                  final isSelected =
                      recipeProvider.selectedProvider == provider;
                  return _PreferenceChip(
                    label: provider.toUpperCase(),
                    isSelected: isSelected,
                    onTap: () => recipeProvider.setProvider(provider),
                  );
                }).toList(),
              ),

              SizedBox(height: AppSizes.spaceHeightLg),

              // Cuisine Selection
              Text(
                'Cuisine Type',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: AppSizes.spaceHeightSm),
              Wrap(
                spacing: AppSizes.spaceSm,
                runSpacing: AppSizes.spaceHeightSm,
                children: RecipeProvider.cuisines.map((cuisine) {
                  final isSelected = recipeProvider.selectedCuisine == cuisine;
                  return _PreferenceChip(
                    label: cuisine == 'none' ? 'Any' : cuisine,
                    isSelected: isSelected,
                    onTap: () => recipeProvider.setCuisine(cuisine),
                  );
                }).toList(),
              ),

              SizedBox(height: AppSizes.spaceHeightLg),

              // Dietary Selection
              Text(
                'Dietary Preference',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: AppSizes.spaceHeightSm),
              Wrap(
                spacing: AppSizes.spaceSm,
                runSpacing: AppSizes.spaceHeightSm,
                children: RecipeProvider.dietaryOptions.map((dietary) {
                  final isSelected = recipeProvider.selectedDietary == dietary;
                  return _PreferenceChip(
                    label: dietary == 'none' ? 'None' : dietary,
                    isSelected: isSelected,
                    onTap: () => recipeProvider.setDietary(dietary),
                  );
                }).toList(),
              ),

              SizedBox(height: AppSizes.spaceHeightXl),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel',
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      textColor: colorScheme.onSurface,
                      ontap: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  SizedBox(width: AppSizes.spaceMd),
                  Expanded(
                    child: CustomButton(
                      text: 'Generate',
                      backgroundColor: colorScheme.primary,
                      textColor: colorScheme.onPrimary,
                      ontap: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreferenceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PreferenceChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

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
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppShadows.cardShadow(context) : null,
        ),
        child: Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: isSelected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
