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

  const IngredientCardWidget({super.key, required this.ingredient});

  @override
  State<IngredientCardWidget> createState() => _IngredientCardWidgetState();
}

class _IngredientCardWidgetState extends State<IngredientCardWidget> {
  late TextEditingController _quantityController;
  String _previousQuantity = '';

  @override
  void initState() {
    super.initState();
    _previousQuantity = _formatQuantity(widget.ingredient.quantity);
    _quantityController = TextEditingController(text: _previousQuantity);
  }

  @override
  void didUpdateWidget(IngredientCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update controller if quantity actually changed
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
    super.dispose();
  }

  String _formatQuantity(double quantity) {
    return quantity.toStringAsFixed(
      quantity.truncateToDouble() == quantity ? 0 : 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.read<IngredientsProvider>();

    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.spaceHeightSm),
      padding: EdgeInsets.all(AppSizes.paddingSm),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: AppShadows.elevatedShadow(context),
      ),
      child: Row(
        children: [
          // Ingredient name
          Expanded(
            child: Text(widget.ingredient.name, style: textTheme.titleLarge),
          ),
          // Quantity input
          Container(
            height: 35.h,
            width: 140.w,
            padding: EdgeInsets.only(right: 1.w),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSizes.radiusXl),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 64.w,
                  height: 35.h,
                  child: CustomTextField(
                    hintText: 'Qnty',
                    textAlign: TextAlign.center,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingXs,
                    ),
                    fillColor: colorScheme.surfaceContainerHighest,
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
                        // Reset to previous value if invalid
                        _quantityController.text = _previousQuantity;
                      }
                    },
                  ),
                ),
                Container(
                  height: 20.h,
                  width: 1.w,
                  color: colorScheme.onSurfaceVariant,
                  margin: EdgeInsets.only(right: 10.w),
                ),

                // Unit dropdown
                Expanded(
                  child: DropdownButton<String>(
                    value: widget.ingredient.unit,
                    isDense: true,
                    alignment: Alignment.center,
                    underline: SizedBox(),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: colorScheme.onSurface,
                      size: AppSizes.iconSm,
                    ),
                    items: IngredientUtils.units.map((unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(unit, style: textTheme.bodyLarge),
                      );
                    }).toList(),
                    onChanged: (value) => provider.updateIngredientUnit(
                      widget.ingredient.id,
                      value ?? '',
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSizes.spaceXs),
          // Remove button
          GestureDetector(
            onTap: () {
              provider.removeIngredient(widget.ingredient.id);
              // CustomSnackBar.showSuccess(
              //   context,
              //   '${widget.ingredient.name} removed',
              // );
            },
            child: Icon(
              Icons.close,
              color: colorScheme.primary,
              size: AppSizes.iconMd,
            ),
          ),
        ],
      ),
    );
  }
}
