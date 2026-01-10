import 'package:ai_ruchi/core/services/poison_ingredient_service.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Dialog to warn users about potentially dangerous ingredients
class PoisonWarningDialog extends StatelessWidget {
  final List<DetectedPoisonItem> detectedItems;
  final VoidCallback onRemoveAndContinue;
  final VoidCallback onCancel;

  const PoisonWarningDialog({
    super.key,
    required this.detectedItems,
    required this.onRemoveAndContinue,
    required this.onCancel,
  });

  /// Show the dialog
  static Future<bool?> show(
    BuildContext context,
    List<DetectedPoisonItem> detectedItems,
  ) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PoisonWarningDialog(
        detectedItems: detectedItems,
        onRemoveAndContinue: () => Navigator.pop(dialogContext, true),
        onCancel: () => Navigator.pop(dialogContext, false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(AppSizes.paddingLg),
        constraints: BoxConstraints(maxWidth: 340.w),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning Icon
            Container(
              width: 64.w,
              height: 64.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.red.withValues(alpha: 0.2),
                    Colors.orange.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 36.sp,
              ),
            ),
            SizedBox(height: AppSizes.spaceHeightMd),

            // Title
            Text(
              'Dangerous Items Detected!',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.spaceHeightXs),

            // Subtitle
            Text(
              'The following items are not safe for consumption:',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.spaceHeightMd),

            // Detected items list
            Container(
              constraints: BoxConstraints(maxHeight: 200.h),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.all(AppSizes.paddingSm),
                itemCount: detectedItems.length,
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  color: Colors.red.withValues(alpha: 0.1),
                ),
                itemBuilder: (context, index) {
                  final item = detectedItems[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.dangerous_rounded,
                              size: 16.sp,
                              color: Colors.red,
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                item.ingredientName,
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          item.warningMessage,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: AppSizes.spaceHeightLg),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44.h,
                    decoration: BoxDecoration(
                      border: Border.all(color: colorScheme.outline),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: TextButton(
                      onPressed: onCancel,
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.onSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMd,
                          ),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSizes.spaceSm),
                Expanded(
                  child: Container(
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: TextButton(
                      onPressed: onRemoveAndContinue,
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMd,
                          ),
                        ),
                      ),
                      child: Text(
                        'Remove & Continue',
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
