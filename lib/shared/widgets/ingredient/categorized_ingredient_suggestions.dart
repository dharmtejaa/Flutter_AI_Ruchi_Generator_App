import 'package:ai_ruchi/core/data/ingredient_categories.dart';
import 'package:ai_ruchi/core/theme/app_shadows.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/providers/ingredients_provider.dart';

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
  final List<String> _expandedCategories = []; // List to maintain order
  final Map<String, GlobalKey> _categoryKeys = {};
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

    // Initialize keys for all categories
    for (final category in IngredientCategories.all) {
      _categoryKeys[category.id] = GlobalKey();
    }
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
        // Insert at beginning so newest is first
        _expandedCategories.insert(0, categoryId);
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
              Icon(
                Icons.keyboard_double_arrow_down_rounded,
                color: colorScheme.primary.withValues(alpha: 0.7),
                size: AppSizes.iconSm,
              ),
            ],
          ),
        ),
        SizedBox(height: AppSizes.spaceHeightMd),

        // Horizontal Scrollable Categories
        SizedBox(
          height: 40.h,
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

        // Expanded Categories with Ingredients (newest first order)
        if (_expandedCategories.isNotEmpty) ...[
          SizedBox(height: AppSizes.spaceHeightSm),
          ..._expandedCategories.map((categoryId) {
            final category = IngredientCategories.getById(categoryId);
            if (category == null) return const SizedBox.shrink();
            return _ExpandedCategorySection(
              key: _categoryKeys[categoryId],
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
        padding: AppSizes.paddingAllXs,
        decoration: BoxDecoration(
          color: isExpanded
              ? category.color.withValues(alpha: 0.15)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          border: Border.all(
            color: isExpanded
                ? category.color
                : colorScheme.outline.withValues(alpha: 0.2),
            width: isExpanded ? 1 : 1,
          ),
          boxShadow: AppShadows.cardShadow(context),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji with animated scale
            AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: isExpanded ? 1.1 : 1.0,
              child: Text(category.emoji, style: TextStyle(fontSize: 18.sp)),
            ),
            SizedBox(width: AppSizes.spaceXs),
            // Category name
            Text(
              category.name,
              style: textTheme.labelSmall?.copyWith(
                fontWeight: isExpanded ? FontWeight.w700 : FontWeight.w500,
                color: colorScheme.onSurface,
                fontSize: 10.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(width: AppSizes.spaceXs),
            // Animated indicator arrow
            AnimatedSize(
              duration: const Duration(milliseconds: 100),
              child: isExpanded
                  ? Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: category.color,
                      size: AppSizes.iconSm,
                    )
                  : SizedBox(width: 0.w),
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
    super.key,
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
    final provider = context.watch<IngredientsProvider>();

    // Sort ingredients: selected ones first, in selection order
    final sortedIngredients = [...widget.category.ingredients];
    final ingredientNames = provider.currentIngredients
        .map((i) => i.name.toLowerCase())
        .toList();

    sortedIngredients.sort((a, b) {
      final aSelected = provider.hasIngredientByName(a);
      final bSelected = provider.hasIngredientByName(b);

      if (aSelected && bSelected) {
        // Both selected: sort by selection order (index in currentIngredients)
        final aIndex = ingredientNames.indexOf(a.toLowerCase());
        final bIndex = ingredientNames.indexOf(b.toLowerCase());
        return aIndex.compareTo(bIndex);
      }
      if (aSelected && !bSelected) return -1;
      if (!aSelected && bSelected) return 1;
      return 0;
    });

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingSm,
            vertical: AppSizes.vPaddingSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with category name and close button
              Row(
                children: [
                  Text(
                    widget.category.emoji,
                    style: TextStyle(fontSize: 18.sp),
                  ),
                  SizedBox(width: AppSizes.spaceXs),
                  Expanded(
                    child: Text(
                      widget.category.name,
                      style: textTheme.titleMedium?.copyWith(
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
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.spaceHeightSm),
              // Ingredient chips wrap
              Wrap(
                spacing: 6.w,
                runSpacing: 6.h,
                children: sortedIngredients.map((ingredient) {
                  final isSelected = provider.hasIngredientByName(ingredient);
                  return _IngredientChip(
                    label: ingredient,
                    categoryColor: widget.category.color,
                    isSelected: isSelected,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      if (isSelected) {
                        provider.removeIngredientByName(ingredient);
                      } else {
                        provider.addCustomIngredient(ingredient, 1, 'unit');
                      }
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

/// Individual ingredient chip with add/check icon
class _IngredientChip extends StatelessWidget {
  final String label;
  final Color categoryColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _IngredientChip({
    required this.label,
    required this.categoryColor,
    required this.onTap,
    this.isSelected = false,
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: isSelected
                ? categoryColor.withValues(alpha: 0.2)
                : categoryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: isSelected
                  ? categoryColor
                  : categoryColor.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? Icons.check_rounded : Icons.add_rounded,
                  key: ValueKey(isSelected),
                  color: categoryColor,
                  size: AppSizes.iconXs,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
