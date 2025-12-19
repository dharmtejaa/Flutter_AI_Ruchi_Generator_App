import 'package:ai_ruchi/core/theme/app_shadows.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/core/utils/recipe_helper.dart';
import 'package:ai_ruchi/providers/recipe_provider.dart';
import 'package:ai_ruchi/providers/saved_recipes_provider.dart';
import 'package:ai_ruchi/shared/widgets/common/custom_snackbar.dart';
import 'package:ai_ruchi/shared/widgets/common/nutrition_summary_row.dart';
import 'package:ai_ruchi/shared/widgets/recipe/recipe_image_widget.dart';
import 'package:ai_ruchi/shared/widgets/recipe/recipe_ingredients_tab.dart';
import 'package:ai_ruchi/shared/widgets/recipe/recipe_instructions_tab.dart';
import 'package:ai_ruchi/shared/widgets/recipe/recipe_nutrition_tab.dart';
import 'package:ai_ruchi/shared/widgets/recipe/save_recipe_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class RecipeGeneratedScreen extends StatefulWidget {
  const RecipeGeneratedScreen({super.key});

  @override
  State<RecipeGeneratedScreen> createState() => _RecipeGeneratedScreenState();
}

class _RecipeGeneratedScreenState extends State<RecipeGeneratedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final recipe = context.watch<RecipeProvider>().recipe;

    if (recipe == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant_menu,
                size: 80.sp,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              SizedBox(height: AppSizes.spaceHeightMd),
              Text(
                'No Recipe Available',
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: AppSizes.spaceHeightSm),
              Text(
                'Generate a recipe from your ingredients',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            // App Bar with gradient
            SliverAppBar(
              expandedHeight: 0,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.onSurface,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: colorScheme.onSurface,
                  size: AppSizes.iconMd,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                Consumer<SavedRecipesProvider>(
                  builder: (context, savedProvider, child) {
                    final isSaved = savedProvider.isRecipeSaved(recipe.title);
                    return IconButton(
                      icon: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: isSaved
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                        size: AppSizes.iconMd,
                      ),
                      onPressed: () => _handleSave(context),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.share_outlined,
                    color: colorScheme.onSurface,
                    size: AppSizes.iconMd,
                  ),
                  onPressed: () {
                    CustomSnackBar.showInfo(
                      context,
                      'Share feature coming soon',
                    );
                  },
                ),
                SizedBox(width: AppSizes.spaceSm),
              ],
            ),

            // Recipe Image
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  top: AppSizes.spaceHeightSm,
                  bottom: AppSizes.spaceHeightMd,
                ),
                child: RecipeImageWidget(
                  height: 230.h,
                  imageUrl: recipe.imageUrl,
                  recipeName: recipe.title,
                ),
              ),
            ),

            // Recipe info badges
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recipe description
                    Text(
                      recipe.description,
                      style: textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppSizes.spaceHeightMd),
                    // Info badges
                    Wrap(
                      spacing: AppSizes.spaceSm,
                      runSpacing: AppSizes.spaceHeightSm,
                      children: [
                        _InfoBadge(
                          icon: Icons.timer_outlined,
                          label: recipe.prepTime,
                          subtitle: 'Prep',
                          color: const Color(0xFF4ECDC4),
                        ),
                        _InfoBadge(
                          icon: Icons.local_fire_department,
                          label: recipe.cookTime,
                          subtitle: 'Cook',
                          color: const Color(0xFFFF6B35),
                        ),
                        _InfoBadge(
                          icon: Icons.people_outline,
                          label: recipe.servings,
                          subtitle: 'Servings',
                          color: const Color(0xFF45B7D1),
                        ),
                        _InfoBadge(
                          icon: Icons.signal_cellular_alt,
                          label: recipe.difficulty,
                          subtitle: 'Level',
                          color: const Color(0xFF9B59B6),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: AppSizes.spaceHeightSm).toSliver(),

            // Nutrition Summary Row
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(bottom: AppSizes.spaceHeightSm),
                child: NutritionSummaryRow(
                  nutrition: recipe.nutrition.perServing,
                ),
              ),
            ),

            // Sticky Tab Bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: colorScheme.primary,
                  unselectedLabelColor: colorScheme.onSurfaceVariant,
                  indicatorColor: colorScheme.primary,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: textTheme.titleSmall,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_basket, size: AppSizes.iconSm),
                          SizedBox(width: 6.w),
                          const Text('Ingredients'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.menu_book, size: AppSizes.iconSm),
                          SizedBox(width: 6.w),
                          const Text('Steps'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.pie_chart_outline, size: AppSizes.iconSm),
                          SizedBox(width: 6.w),
                          const Text('Nutrition'),
                        ],
                      ),
                    ),
                  ],
                ),
                colorScheme.surface,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            RecipeIngredientsTab(
              recipe: recipe,
              onRegenerate: () => _handleRegenerate(context),
              onSave: () => _handleSave(context),
            ),
            RecipeInstructionsTab(
              recipe: recipe,
              onRegenerate: () => _handleRegenerate(context),
              onSave: () => _handleSave(context),
            ),
            RecipeNutritionTab(
              recipe: recipe,
              onRegenerate: () => _handleRegenerate(context),
              onSave: () => _handleSave(context),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _handleRegenerate(context),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Try Again'),
        elevation: 4,
      ),
    );
  }

  Future<void> _handleRegenerate(BuildContext context) async {
    await RecipeHelper.regenerateRecipe(context);
  }

  void _handleSave(BuildContext context) {
    final recipe = context.read<RecipeProvider>().recipe;
    if (recipe != null) {
      SaveRecipeDialog.show(context, recipe);
    }
  }
}

// Extension to convert SizedBox to Sliver
extension SliverExtension on SizedBox {
  Widget toSliver() => SliverToBoxAdapter(child: this);
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;

  const _InfoBadge({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingXs,
        vertical: AppSizes.vPaddingXs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30.w,
            height: 30.h,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(icon, color: color, size: AppSizes.iconSm),
          ),
          SizedBox(width: AppSizes.spaceXs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: textTheme.titleSmall?.copyWith(fontWeight: .bold),
              ),
              Text(
                subtitle,
                style: textTheme.labelSmall?.copyWith(fontWeight: .bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Delegate for sticky tab bar
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _StickyTabBarDelegate(this.tabBar, this.backgroundColor);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: overlapsContent ? AppShadows.cardShadow(context) : null,
      ),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
