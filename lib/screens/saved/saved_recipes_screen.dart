import 'package:ai_ruchi/core/theme/app_shadows.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/models/saved_recipe.dart';
import 'package:ai_ruchi/providers/recipe_provider.dart';
import 'package:ai_ruchi/providers/saved_recipes_provider.dart';
import 'package:ai_ruchi/shared/widgets/common/custom_snackbar.dart';
import 'package:ai_ruchi/shared/widgets/recipe/recipe_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SavedRecipesScreen extends StatelessWidget {
  const SavedRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Consumer<SavedRecipesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(AppSizes.paddingLg),
                child: Text(
                  'Saved Recipes',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),

              // Content
              Expanded(
                child: provider.isEmpty
                    ? _buildEmptyState(context, colorScheme, textTheme)
                    : _buildRecipesList(context, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100.w,
              height: 100.h,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bookmark_outline,
                size: 48.sp,
                color: colorScheme.primary.withValues(alpha: 0.8),
              ),
            ),
            SizedBox(height: AppSizes.spaceHeightLg),
            Text(
              'No Saved Recipes',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: AppSizes.spaceHeightSm),
            Text(
              'Generate a recipe and save it to access it anytime, even offline!',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipesList(
    BuildContext context,
    SavedRecipesProvider provider,
  ) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingLg),
      itemCount: provider.savedRecipes.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final savedRecipe = provider.savedRecipes[index];
        return _SavedRecipeCard(
          savedRecipe: savedRecipe,
          onDelete: () => _showDeleteDialog(context, savedRecipe),
          onTap: () => _viewRecipeDetails(context, savedRecipe),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, SavedRecipe savedRecipe) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        ),
        title: Text(
          'Delete Recipe?',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to delete "${savedRecipe.recipe.title}"? This action cannot be undone.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            // Action Buttons
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: BorderSide(color: colorScheme.outline),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // Delete Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      context.read<SavedRecipesProvider>().deleteRecipe(
                        savedRecipe.id,
                      );
                      CustomSnackBar.showSuccess(context, 'Recipe deleted');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                    ),
                    child: Text(
                      'Yes, Delete',
                      style: textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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
  }

  void _viewRecipeDetails(BuildContext context, SavedRecipe savedRecipe) {
    // Set the recipe in the provider so it's displayed in RecipeGeneratedScreen
    context.read<RecipeProvider>().setRecipe(savedRecipe.recipe);

    // Navigate to recipe details
    context.push('/recipe');
  }
}

class _SavedRecipeCard extends StatelessWidget {
  final SavedRecipe savedRecipe;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _SavedRecipeCard({
    required this.savedRecipe,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final recipe = savedRecipe.recipe;
    final nutrition = recipe.nutrition.perServing;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSizes.paddingSm),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          boxShadow: AppShadows.cardShadow(context),
        ),
        child: Row(
          children: [
            // Recipe Image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              child: SizedBox(
                width: 70.w,
                height: 70.h,
                child: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                    ? RecipeImageWidget(
                        imageUrl: recipe.imageUrl,
                        recipeName: recipe.title,
                        height: 70.h,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      )
                    : Container(
                        color: colorScheme.primaryContainer,
                        child: Center(
                          child: Text(
                            savedRecipe.recipeEmoji,
                            style: TextStyle(fontSize: 32.sp),
                          ),
                        ),
                      ),
              ),
            ),
            SizedBox(width: 12.w),

            // Recipe Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    recipe.title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),

                  // Nutrition Info Row
                  Row(
                    children: [
                      // Calories
                      Text(
                        '🔥 ${nutrition.calories.value.toInt()} Kcal',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        ' • ',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                      // Health Score
                      Text(
                        savedRecipe.healthScore,
                        style: textTheme.bodySmall?.copyWith(
                          color: _getHealthScoreColor(savedRecipe.healthScore),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Delete Button
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.close,
                size: 20.sp,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
            ),
          ],
        ),
      ),
    );
  }

  Color _getHealthScoreColor(String score) {
    if (score.startsWith('A+')) return const Color(0xFF4CAF50);
    if (score.startsWith('A')) return const Color(0xFF8BC34A);
    if (score.startsWith('B+')) return const Color(0xFFFFEB3B);
    if (score.startsWith('B')) return const Color(0xFFFF9800);
    return const Color(0xFFFF5722);
  }
}
