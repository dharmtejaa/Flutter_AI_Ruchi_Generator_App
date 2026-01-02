import 'package:ai_ruchi/core/data/ingredient_categories.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/providers/ingredients_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/// Expanded section showing category name and ingredient chips
class ExpandedCategorySection extends StatefulWidget {
  final IngredientCategory category;
  final VoidCallback onClose;

  const ExpandedCategorySection({
    super.key,
    required this.category,
    required this.onClose,
  });

  @override
  State<ExpandedCategorySection> createState() =>
      _ExpandedCategorySectionState();
}

class _ExpandedCategorySectionState extends State<ExpandedCategorySection>
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
                  Text(widget.category.emoji, style: textTheme.headlineSmall),
                  SizedBox(width: AppSizes.spaceSm),
                  Expanded(
                    child: Text(
                      widget.category.name,
                      style: textTheme.titleLarge?.copyWith(
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
                        size: AppSizes.iconMd,
                        color: widget.category.color,
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
        borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
        splashColor: categoryColor.withValues(alpha: 0.2),
        highlightColor: categoryColor.withValues(alpha: 0.1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: isSelected
                ? categoryColor.withValues(alpha: 0.2)
                : categoryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
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
