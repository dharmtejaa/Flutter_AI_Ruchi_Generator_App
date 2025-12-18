import 'package:ai_ruchi/core/theme/app_shadows.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecipeImageWidget extends StatefulWidget {
  final String? imageUrl;
  final String recipeName;
  final double? height;
  final BorderRadius? borderRadius;

  const RecipeImageWidget({
    super.key,
    this.imageUrl,
    required this.recipeName,
    this.height,
    this.borderRadius,
  });

  @override
  State<RecipeImageWidget> createState() => _RecipeImageWidgetState();
}

class _RecipeImageWidgetState extends State<RecipeImageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final borderRadius =
        widget.borderRadius ?? BorderRadius.circular(AppSizes.radiusXl);

    return Container(
      width: double.infinity,
      height: widget.height ?? 270.h,
      margin: EdgeInsets.symmetric(horizontal: AppSizes.paddingSm),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: AppShadows.elevatedShadow(context),
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image or placeholder
            widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: widget.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        _buildShimmerPlaceholder(colorScheme),
                    errorWidget: (context, url, error) =>
                        _buildFancyPlaceholder(colorScheme, textTheme),
                  )
                : _buildFancyPlaceholder(colorScheme, textTheme),

            // Recipe name overlay
            Positioned(
              left: AppSizes.paddingSm,
              right: AppSizes.paddingSm,
              bottom: AppSizes.paddingSm,
              child: Text(
                widget.recipeName,
                style: textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Decorative corner badge
            Positioned(
              top: AppSizes.paddingSm,
              right: AppSizes.paddingSm,
              child: Container(
                padding: AppSizes.paddingAllXs,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: AppSizes.iconXs,
                      color: colorScheme.onPrimary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'AI Generated',
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerPlaceholder(ColorScheme colorScheme) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 + _shimmerController.value * 2, 0),
              end: Alignment(1 + _shimmerController.value * 2, 0),
              colors: [
                colorScheme.surfaceContainerHighest,
                colorScheme.surfaceContainerHigh,
                colorScheme.surfaceContainerHighest,
              ],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.restaurant_menu,
              size: 60.sp,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFancyPlaceholder(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
            colorScheme.tertiaryContainer,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _PatternPainter(
                color: colorScheme.onPrimaryContainer.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Center content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.restaurant_menu,
                    size: 40.sp,
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(height: AppSizes.spaceHeightMd),
                Text(
                  'Delicious Recipe',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSizes.spaceHeightXs),
                Text(
                  'Image coming soon',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  final Color color;

  _PatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 30.0;

    // Draw diagonal lines pattern
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
