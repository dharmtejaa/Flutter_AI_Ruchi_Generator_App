import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:flutter/material.dart';

class RecipeLoadingScreen extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;

  const RecipeLoadingScreen({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      color: colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (value * 0.2),
                  child: Opacity(
                    opacity: value,
                    child: Icon(
                      icon ?? Icons.auto_awesome,
                      size: AppSizes.iconXl * 2,
                      color: iconColor ?? colorScheme.primary,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: AppSizes.spaceHeightXl),
            // Loading text
            Text(
              title ?? 'Generating Your Recipe...',
              style: textTheme.displaySmall,
            ),
            SizedBox(height: AppSizes.spaceHeightMd),
            // Subtitle text
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingXl),
              child: Text(
                subtitle ?? 'Our AI chef is crafting the perfect recipe for you',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppSizes.fontMd,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
            SizedBox(height: AppSizes.spaceHeightXxl),
            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              strokeWidth: 3.0,
            ),
          ],
        ),
      ),
    );
  }
}

