import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/core/services/my_custom_cache_manager.dart';

class CustomButton extends StatefulWidget {
  final String? text;
  final String? networkImage;
  final VoidCallback? ontap;
  final Color backgroundColor;
  final IconData? icon;
  final Color? textColor;
  final bool isLoading;
  final double? width;
  final double? height;
  final bool? isBorder;
  final bool useGradient;

  const CustomButton({
    super.key,
    this.text,
    this.networkImage,
    this.ontap,
    this.icon,
    required this.backgroundColor,
    this.textColor,
    this.isLoading = false,
    this.isBorder = false,
    this.width,
    this.height,
    this.useGradient = false,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTapDown: widget.isLoading ? null : (_) => _controller.forward(),
      onTapUp: widget.isLoading
          ? null
          : (_) {
              _controller.reverse();
              widget.ontap?.call();
            },
      onTapCancel: widget.isLoading ? null : () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width ?? double.infinity,
          height: widget.height ?? 52.h,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: widget.isBorder == true
                ? Border.all(color: colorScheme.outline.withValues(alpha: 0.2))
                : null,
            boxShadow:
                widget.backgroundColor != colorScheme.surfaceContainerHighest
                ? [
                    BoxShadow(
                      color: widget.backgroundColor.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: widget.isLoading
              ? Center(
                  child: SizedBox(
                    width: 24.w,
                    height: 24.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.textColor ?? colorScheme.onPrimary,
                      ),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.networkImage != null)
                      Padding(
                        padding: EdgeInsets.only(right: 10.w),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusSm,
                          ),
                          child: CachedNetworkImage(
                            imageUrl: widget.networkImage ?? '',
                            width: 24.w,
                            height: 24.h,
                            fit: BoxFit.cover,
                            cacheManager: MyCustomCacheManager.instance,
                          ),
                        ),
                      ),
                    if (widget.text != null)
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.icon != null) ...[
                              Container(
                                width: 28.w,
                                height: 28.h,
                                decoration: BoxDecoration(
                                  color:
                                      (widget.textColor ??
                                              colorScheme.onPrimary)
                                          .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusSm,
                                  ),
                                ),
                                child: Icon(
                                  widget.icon,
                                  size: AppSizes.iconSm,
                                  color:
                                      widget.textColor ?? colorScheme.onPrimary,
                                ),
                              ),
                              SizedBox(width: 10.w),
                            ],
                            Flexible(
                              child: Text(
                                widget.text ?? '',
                                style: textTheme.titleMedium?.copyWith(
                                  color:
                                      widget.textColor ?? colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
