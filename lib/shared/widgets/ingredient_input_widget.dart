import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/shared/widgets/custom_snackbar.dart';
import 'package:ai_ruchi/shared/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';

class IngredientInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAdd;
  final VoidCallback? onScan;
  final String? hintText;

  const IngredientInputWidget({
    super.key,
    required this.controller,
    required this.onAdd,
    this.onScan,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            hintText: hintText ?? 'Add ingredient (e.g., 2 eggs)...',
            controller: controller,
            onTap: () {},
            suffixIcon: IconButton(
              icon: Icon(
                Icons.qr_code_scanner,
                color: colorScheme.onSurfaceVariant,
                size: AppSizes.iconMd,
              ),
              onPressed: onScan ??
                  () {
                    CustomSnackBar.showInfo(
                      context,
                      'Scanner feature coming soon',
                    );
                  },
            ),
          ),
        ),
        SizedBox(width: AppSizes.spaceSm),
        IconButton(
          onPressed: onAdd,
          icon: Icon(
            Icons.add_circle,
            color: colorScheme.primary,
            size: AppSizes.iconLg,
          ),
        ),
      ],
    );
  }
}

