import 'package:ai_ruchi/core/theme/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/core/theme/app_shadows.dart';

class CustomSnackBar {
  static void showSuccess(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 2),
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle_rounded,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 2),
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: AppColors.error,
      icon: Icons.error_rounded,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  static void showInfo(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 2),
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: AppColors.info,
      icon: Icons.info_rounded,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  static void showWarning(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 2),
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: AppColors.warning,
      icon: Icons.warning_rounded,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  static void _showSnackBar(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required IconData icon,
    String? actionLabel,
    VoidCallback? onAction,
    required Duration duration,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 10,
        margin: AppSizes.marginSymmetricMd,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        duration: duration,
        dismissDirection: DismissDirection.horizontal,
        content: Row(
          children: [
            // Enhanced Icon with background
            Container(
              padding: AppSizes.paddingAllSm,
              decoration: BoxDecoration(
                color: colorScheme.onPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(
                icon,
                color: colorScheme.onPrimary,
                size: AppSizes.iconSm,
              ),
            ),

            SizedBox(width: AppSizes.spaceMd),

            // Message
            Expanded(
              child: Text(
                message,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Enhanced Action Button (if provided)
            if (actionLabel != null && onAction != null) ...[
              SizedBox(width: AppSizes.spaceMd),
              GestureDetector(
                onTap: onAction,
                child: Container(
                  padding: AppSizes.paddingSymmetricSm,
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    boxShadow: AppShadows.elevatedShadow(context),
                  ),
                  child: Text(
                    actionLabel,
                    style: textTheme.bodyMedium?.copyWith(
                      color: backgroundColor,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
