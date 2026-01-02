import 'package:ai_ruchi/core/data/ingredient_categories.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/shared/widgets/ingredient/category_chip.dart';
import 'package:ai_ruchi/shared/widgets/ingredient/expanded_category_section.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
          padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingSm),
          child: Row(
            children: [
              Text('Quick Add by Category', style: textTheme.headlineSmall),
              SizedBox(width: AppSizes.spaceXs),

              Icon(
                Icons.keyboard_double_arrow_down_rounded,
                color: colorScheme.primary,
                size: AppSizes.iconMd,
              ),
            ],
          ),
        ),
        SizedBox(height: AppSizes.spaceHeightSm),

        // Horizontal Scrollable Categories
        SizedBox(
          height: 40.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,

            itemCount: IngredientCategories.all.length,
            itemBuilder: (context, index) {
              final category = IngredientCategories.all[index];
              final isExpanded = _expandedCategories.contains(category.id);
              return CategoryChip(
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
            return ExpandedCategorySection(
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
