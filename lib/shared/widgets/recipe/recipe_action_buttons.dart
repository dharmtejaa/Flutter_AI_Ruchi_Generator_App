import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/shared/widgets/common/custom_button.dart';
import 'package:flutter/material.dart';

class RecipeActionButtons extends StatelessWidget {
  final VoidCallback onRegenerate;
  final VoidCallback onSave;

  const RecipeActionButtons({
    super.key,
    required this.onRegenerate,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(AppSizes.paddingLg),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Regenerate Recipe',
              backgroundColor: colorScheme.surfaceContainerHighest,
              textColor: colorScheme.onSurface,
              ontap: onRegenerate,
            ),
          ),
          SizedBox(width: AppSizes.spaceMd),
          Expanded(
            child: CustomButton(
              text: 'Save Recipe',
              backgroundColor: colorScheme.primary,
              textColor: colorScheme.onPrimary,
              ontap: onSave,
            ),
          ),
        ],
      ),
    );
  }
}

