import 'package:ai_ruchi/core/theme/app_shadows.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/core/utils/ingredient_utils.dart';
import 'package:ai_ruchi/models/ingredient.dart';
import 'package:ai_ruchi/providers/ingredients_provider.dart';
import 'package:ai_ruchi/shared/widgets/common/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class IngredientCardWidget extends StatefulWidget {
  final Ingredient ingredient;
  final int? index;

  const IngredientCardWidget({super.key, required this.ingredient, this.index});

  @override
  State<IngredientCardWidget> createState() => _IngredientCardWidgetState();
}

class _IngredientCardWidgetState extends State<IngredientCardWidget>
    with SingleTickerProviderStateMixin {
  late TextEditingController _quantityController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  String _previousQuantity = '';

  @override
  void initState() {
    super.initState();
    _previousQuantity = _formatQuantity(widget.ingredient.quantity);
    _quantityController = TextEditingController(text: _previousQuantity);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void didUpdateWidget(IngredientCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ingredient.quantity != widget.ingredient.quantity) {
      final newQuantity = _formatQuantity(widget.ingredient.quantity);
      if (_quantityController.text != newQuantity) {
        _quantityController.text = newQuantity;
        _previousQuantity = newQuantity;
      }
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String _formatQuantity(double quantity) {
    return quantity.toStringAsFixed(
      quantity.truncateToDouble() == quantity ? 0 : 1,
    );
  }

  IconData _getIngredientIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('egg')) return Icons.egg_alt;
    if (lowerName.contains('milk') || lowerName.contains('dairy')) {
      return Icons.local_drink;
    }
    if (lowerName.contains('chicken') ||
        lowerName.contains('meat') ||
        lowerName.contains('beef')) {
      return Icons.restaurant;
    }
    if (lowerName.contains('fish') || lowerName.contains('salmon')) {
      return Icons.set_meal;
    }
    if (lowerName.contains('fruit') ||
        lowerName.contains('apple') ||
        lowerName.contains('banana')) {
      return Icons.apple;
    }
    if (lowerName.contains('vegetable') ||
        lowerName.contains('carrot') ||
        lowerName.contains('spinach')) {
      return Icons.eco;
    }
    if (lowerName.contains('rice') ||
        lowerName.contains('grain') ||
        lowerName.contains('wheat')) {
      return Icons.grain;
    }
    if (lowerName.contains('oil') || lowerName.contains('butter')) {
      return Icons.water_drop;
    }
    if (lowerName.contains('salt') ||
        lowerName.contains('pepper') ||
        lowerName.contains('spice')) {
      return Icons.spa;
    }
    if (lowerName.contains('sugar') || lowerName.contains('honey')) {
      return Icons.cake;
    }
    if (lowerName.contains('tomato') ||
        lowerName.contains('onion') ||
        lowerName.contains('garlic')) {
      return Icons.local_florist;
    }
    return Icons.restaurant_menu;
  }

  Color _getIngredientColor(String name, ColorScheme colorScheme) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('meat') ||
        lowerName.contains('chicken') ||
        lowerName.contains('beef')) {
      return const Color(0xFFE57373);
    }
    if (lowerName.contains('vegetable') ||
        lowerName.contains('spinach') ||
        lowerName.contains('lettuce')) {
      return const Color(0xFF81C784);
    }
    if (lowerName.contains('fruit') ||
        lowerName.contains('apple') ||
        lowerName.contains('orange')) {
      return const Color(0xFFFFB74D);
    }
    if (lowerName.contains('dairy') ||
        lowerName.contains('milk') ||
        lowerName.contains('cheese')) {
      return const Color(0xFF64B5F6);
    }
    if (lowerName.contains('grain') ||
        lowerName.contains('rice') ||
        lowerName.contains('bread')) {
      return const Color(0xFFFFD54F);
    }
    return colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.read<IngredientsProvider>();
    final ingredientColor = _getIngredientColor(
      widget.ingredient.name,
      colorScheme,
    );

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSizes.spaceHeightXs),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          boxShadow: AppShadows.cardShadow(context),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {}, // For ripple effect
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            child: Padding(
              padding: AppSizes.paddingAllXs,
              child: Row(
                children: [
                  // Ingredient icon with solid background
                  Container(
                    width: 30.w,
                    height: 30.h,
                    decoration: BoxDecoration(
                      color: ingredientColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      border: Border.all(
                        color: ingredientColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      _getIngredientIcon(widget.ingredient.name),
                      color: ingredientColor,
                      size: AppSizes.iconSm,
                    ),
                  ),

                  SizedBox(width: AppSizes.spaceSm),

                  // Ingredient name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.ingredient.name,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.index != null)
                          Text(
                            'Ingredient ${widget.index! + 1}',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Quantity and unit controls
                  Container(
                    height: 34.h,
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Quantity input (supports up to 4 digits)
                        SizedBox(
                          width: 46.w,
                          child: CustomTextField(
                            hintText: 'Qty',
                            textAlign: TextAlign.center,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                            ),
                            fillColor: Colors.transparent,
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            onFieldSubmittedCallback: (value) {
                              final quantity = double.tryParse(value);
                              if (quantity != null && quantity > 0) {
                                provider.updateIngredientQuantity(
                                  widget.ingredient.id,
                                  quantity,
                                );
                              } else {
                                _quantityController.text = _previousQuantity;
                              }
                            },
                          ),
                        ),

                        // Divider with spacing
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 7.w),
                          child: Container(
                            height: 18.h,
                            width: 1.5,
                            color: colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                        ),

                        // Unit dropdown (compact)
                        SizedBox(
                          width: 52.w,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: widget.ingredient.unit,
                              isDense: true,
                              isExpanded: true,
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: colorScheme.onSurfaceVariant,
                                size: 16.sp,
                              ),
                              dropdownColor: colorScheme.surface,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                              items: IngredientUtils.units.map((unit) {
                                return DropdownMenuItem<String>(
                                  value: unit,
                                  child: Text(
                                    unit,
                                    style: textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) =>
                                  provider.updateIngredientUnit(
                                    widget.ingredient.id,
                                    value ?? '',
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: AppSizes.spaceSm),

                  // Remove button
                  GestureDetector(
                    onTap: () {
                      provider.removeIngredient(widget.ingredient.id);
                    },
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: colorScheme.primary,
                      size: AppSizes.iconMd,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
