import 'package:ai_ruchi/core/data/ingredient_categories.dart';
import 'package:ai_ruchi/core/theme/app_shadows.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Individual category chip with animated selection state
class CategoryChip extends StatelessWidget {
  final IngredientCategory category;
  final bool isExpanded;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
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
        margin: EdgeInsets.only(left: AppSizes.spaceXs),
        padding: AppSizes.paddingSymmetricXs,
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
              child: Text(category.emoji, style: TextStyle(fontSize: 16.sp)),
            ),
            SizedBox(width: AppSizes.spaceXs),
            // Category name
            Text(
              category.name,
              style: textTheme.bodySmall?.copyWith(
                fontWeight: isExpanded ? FontWeight.w700 : FontWeight.w500,
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
                  : Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: category.color,
                      size: AppSizes.iconSm,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
