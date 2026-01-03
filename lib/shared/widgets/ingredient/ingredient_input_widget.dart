import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/shared/widgets/common/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IngredientInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAdd;
  final String? hintText;

  final FocusNode? focusNode;

  const IngredientInputWidget({
    super.key,
    required this.controller,
    required this.onAdd,
    this.hintText,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            borderRadius: AppSizes.radiusXxxl,
            fillColor: colorScheme.surfaceContainerHighest,
            hintText: hintText ?? 'e.g., 2 eggs',
            controller: controller,
            onFieldSubmittedCallback: (_) => onAdd(),
            focusNode: focusNode,
          ),
        ),
        SizedBox(width: AppSizes.spaceXs),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            height: 45.h,
            width: 45.w,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(AppSizes.radiusXxxl),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.add,
              color: colorScheme.onPrimary,
              size: AppSizes.iconLg,
            ),
          ),
        ),
      ],
    );
  }
}
