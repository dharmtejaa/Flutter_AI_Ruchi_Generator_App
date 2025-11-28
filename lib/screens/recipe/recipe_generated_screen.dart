import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/core/utils/recipe_helper.dart';
import 'package:ai_ruchi/providers/recipe_provider.dart';
import 'package:ai_ruchi/shared/widgets/common/custom_snackbar.dart';
import 'package:ai_ruchi/shared/widgets/common/nutrition_summary_row.dart';
import 'package:ai_ruchi/shared/widgets/recipe/recipe_image_widget.dart';
import 'package:ai_ruchi/shared/widgets/recipe/recipe_ingredients_tab.dart';
import 'package:ai_ruchi/shared/widgets/recipe/recipe_instructions_tab.dart';
import 'package:ai_ruchi/shared/widgets/recipe/recipe_nutrition_tab.dart';
import 'package:flutter/material.dart';
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
        appBar: AppBar(title: Text('No Recipe')),
        body: Center(child: Text('No recipe available')),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            // App Bar
            SliverAppBar(
              title: Text(
                recipe.title,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: false,
              pinned: true,
              floating: false,
            ),

            // Recipe Image
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  top: AppSizes.spaceHeightMd,
                  bottom: AppSizes.spaceHeightMd,
                ),
                child: RecipeImageWidget(
                  imageUrl: recipe.imageUrl,
                  recipeName: recipe.title,
                ),
              ),
            ),

            // Nutrition Summary Row
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(bottom: AppSizes.spaceHeightMd),
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
                  tabs: const [
                    Tab(text: 'Ingredients'),
                    Tab(text: 'Instructions'),
                    Tab(text: 'Nutrition'),
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
              nutrition: recipe.nutrition.perServing,
              onRegenerate: () => _handleRegenerate(context),
              onSave: () => _handleSave(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRegenerate(BuildContext context) async {
    await RecipeHelper.regenerateRecipe(context);
  }

  void _handleSave(BuildContext context) {
    CustomSnackBar.showSuccess(context, 'Recipe saved successfully!');
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
    return Container(color: backgroundColor, child: tabBar);
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
