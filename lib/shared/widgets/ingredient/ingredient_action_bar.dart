import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/shared/widgets/common/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IngredientActionBar extends StatelessWidget {
  final String primaryActionText;
  final IconData primaryActionIcon;
  final VoidCallback onPrimaryAction;
  final Color? primaryBackgroundColor;
  final Color? primaryTextColor;

  final String? secondaryActionText;
  final IconData? secondaryActionIcon;
  final VoidCallback? onSecondaryAction;
  final Color? secondaryBackgroundColor;
  final Color? secondaryTextColor;

  final bool isBottomBar;

  const IngredientActionBar({
    super.key,
    required this.primaryActionText,
    required this.primaryActionIcon,
    required this.onPrimaryAction,
    this.primaryBackgroundColor,
    this.primaryTextColor,
    this.secondaryActionText,
    this.secondaryActionIcon,
    this.onSecondaryAction,
    this.secondaryBackgroundColor,
    this.secondaryTextColor,
    this.isBottomBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final primaryBg = primaryBackgroundColor ?? colorScheme.primary;
    final primaryText = primaryTextColor ?? colorScheme.onPrimary;
    final secondaryBg = secondaryBackgroundColor ?? colorScheme.surface;
    final secondaryText = secondaryTextColor ?? colorScheme.primary;

    final content = Row(
      spacing: AppSizes.spaceSm,
      children: [
        if (secondaryActionText != null && onSecondaryAction != null)
          Expanded(
            child: CustomButton(
              height: 45.h,
              text: secondaryActionText!,
              backgroundColor: secondaryBg,
              textColor: secondaryText,
              ontap: onSecondaryAction!,
              icon: secondaryActionIcon,
            ),
          ),
        Expanded(
          child: CustomButton(
            height: 45.h,
            text: primaryActionText,
            backgroundColor: primaryBg,
            textColor: primaryText,
            ontap: onPrimaryAction,
            icon: primaryActionIcon,
          ),
        ),
      ],
    );

    if (isBottomBar) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingXs,
          vertical: AppSizes.vPaddingXs,
        ),
        child: content,
      );
    } else {
      return content;
    }
  }
}
