import 'package:ai_ruchi/core/data/ingredient_categories.dart';
import 'package:ai_ruchi/core/theme/app_shadows.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/providers/ingredients_provider.dart';
import 'package:ai_ruchi/shared/widgets/common/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/// A widget that displays ingredient categories as horizontal scrollable items
/// with animated expand/collapse functionality to show ingredient chips
class CategorizedIngredientSuggestions extends StatefulWidget {
  const CategorizedIngredientSuggestions({super.key});

  @override
  State<CategorizedIngredientSuggestions> createState() =>
      _CategorizedIngredientSuggestionsState();
}

class _CategorizedIngredientSuggestionsState
    extends State<CategorizedIngredientSuggestions>
    with TickerProviderStateMixin {
  final Set<String> _expandedCategories = {};
  late AnimationController _arrowAnimationController;
  late Animation<double> _arrowAnimation;

  @override
  void initState() {
    super.initState();
    _arrowAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _arrowAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(
        parent: _arrowAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _arrowAnimationController.dispose();
    super.dispose();
  }

  void _toggleCategory(String categoryId) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_expandedCategories.contains(categoryId)) {
        _expandedCategories.remove(categoryId);
      } else {
        _expandedCategories.add(categoryId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingXs),
          child: Row(
            children: [
              Text(
                'Quick Add by Category',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(width: AppSizes.spaceXs),
              // Animated arrow hint
              AnimatedBuilder(
                animation: _arrowAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _arrowAnimation.value),
                    child: Icon(
                      Icons.keyboard_double_arrow_down_rounded,
                      color: colorScheme.primary.withValues(alpha: 0.7),
                      size: AppSizes.iconSm,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        SizedBox(height: AppSizes.spaceHeightSm),

        // Horizontal Scrollable Categories
        SizedBox(
          height: 95.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingXs),
            itemCount: IngredientCategories.all.length,
            itemBuilder: (context, index) {
              final category = IngredientCategories.all[index];
              final isExpanded = _expandedCategories.contains(category.id);
              return _CategoryChip(
                category: category,
                isExpanded: isExpanded,
                onTap: () => _toggleCategory(category.id),
              );
            },
          ),
        ),

        // Expanded Categories with Ingredients
        if (_expandedCategories.isNotEmpty) ...[
          SizedBox(height: AppSizes.spaceHeightMd),
          ..._expandedCategories.map((categoryId) {
            final category = IngredientCategories.getById(categoryId);
            if (category == null) return const SizedBox.shrink();
            return _ExpandedCategorySection(
              category: category,
              onClose: () => _toggleCategory(categoryId),
            );
          }),
        ],
      ],
    );
  }
}

/// Individual category chip with animated selection state
class _CategoryChip extends StatelessWidget {
  final IngredientCategory category;
  final bool isExpanded;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(right: AppSizes.spaceSm),
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMd,
          vertical: AppSizes.vPaddingSm,
        ),
        decoration: BoxDecoration(
          color: isExpanded
              ? category.color.withValues(alpha: 0.15)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: isExpanded
                ? category.color
                : colorScheme.outline.withValues(alpha: 0.2),
            width: isExpanded ? 2 : 1,
          ),
          boxShadow: isExpanded
              ? [
                  BoxShadow(
                    color: category.color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : AppShadows.cardShadow(context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji with animated scale
            AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: isExpanded ? 1.1 : 1.0,
              child: Text(category.emoji, style: TextStyle(fontSize: 24.sp)),
            ),
            SizedBox(height: 4.h),
            // Category name
            Text(
              category.name,
              style: textTheme.labelSmall?.copyWith(
                fontWeight: isExpanded ? FontWeight.w700 : FontWeight.w500,
                color: isExpanded ? category.color : colorScheme.onSurface,
                fontSize: 10.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            // Animated indicator arrow
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: isExpanded
                  ? Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: category.color,
                      size: 14.sp,
                    )
                  : SizedBox(height: 0.h),
            ),
          ],
        ),
      ),
    );
  }
}

/// Expanded section showing category name and ingredient chips
class _ExpandedCategorySection extends StatefulWidget {
  final IngredientCategory category;
  final VoidCallback onClose;

  const _ExpandedCategorySection({
    required this.category,
    required this.onClose,
  });

  @override
  State<_ExpandedCategorySection> createState() =>
      _ExpandedCategorySectionState();
}

class _ExpandedCategorySectionState extends State<_ExpandedCategorySection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final provider = context.read<IngredientsProvider>();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: EdgeInsets.only(
            bottom: AppSizes.vMarginMd,
            left: AppSizes.marginXs,
            right: AppSizes.marginXs,
          ),
          padding: AppSizes.paddingAllMd,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: widget.category.color.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: AppShadows.cardShadow(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with category name and close button
              Row(
                children: [
                  Text(
                    widget.category.emoji,
                    style: TextStyle(fontSize: 20.sp),
                  ),
                  SizedBox(width: AppSizes.spaceXs),
                  Expanded(
                    child: Text(
                      widget.category.name,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: widget.category.color,
                      ),
                    ),
                  ),
                  // Close button
                  GestureDetector(
                    onTap: widget.onClose,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: AppSizes.iconXs,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.spaceHeightSm),
              // Ingredient chips wrap
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: widget.category.ingredients.map((ingredient) {
                  return _IngredientChip(
                    label: ingredient,
                    categoryColor: widget.category.color,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      provider.addCustomIngredient(ingredient, 1, 'unit');
                      CustomSnackBar.showSuccess(context, '$ingredient added');
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual ingredient chip with add icon
class _IngredientChip extends StatelessWidget {
  final String label;
  final Color categoryColor;
  final VoidCallback onTap;

  const _IngredientChip({
    required this.label,
    required this.categoryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        splashColor: categoryColor.withValues(alpha: 0.2),
        highlightColor: categoryColor.withValues(alpha: 0.1),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: categoryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: categoryColor.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_rounded,
                color: categoryColor,
                size: AppSizes.iconXs,
              ),
              SizedBox(width: 4.w),
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
