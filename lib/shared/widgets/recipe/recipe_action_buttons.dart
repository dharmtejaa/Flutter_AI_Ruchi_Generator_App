import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/shared/widgets/common/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

    return Padding(
      padding: EdgeInsets.all(AppSizes.paddingSm),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              height: 45.h,
              text: 'Try Again',
              icon: Icons.refresh,
              backgroundColor: colorScheme.onPrimary,
              textColor: colorScheme.onSurface,
              ontap: onRegenerate,
            ),
          ),
          SizedBox(width: AppSizes.spaceMd),
          Expanded(
            child: CustomButton(
              height: 45.h,
              text: 'Save Recipe',
              icon: Icons.bookmark_border_outlined,
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
