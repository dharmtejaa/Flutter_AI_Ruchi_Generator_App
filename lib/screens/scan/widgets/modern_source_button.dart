import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:flutter/material.dart';

/// Modern source button with tap animation effect
class ModernSourceButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final bool isPrimary;

  const ModernSourceButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.colorScheme,
    required this.textTheme,
    required this.isPrimary,
  });

  @override
  State<ModernSourceButton> createState() => _ModernSourceButtonState();
}

class _ModernSourceButtonState extends State<ModernSourceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppSizes.vPaddingSm),
          decoration: BoxDecoration(
            gradient: widget.isPrimary
                ? LinearGradient(
                    colors: [
                      widget.colorScheme.primary,
                      widget.colorScheme.primary.withValues(alpha: 0.9),
                    ],
                  )
                : null,
            color: widget.isPrimary ? null : widget.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: widget.isPrimary
                ? null
                : Border.all(color: widget.colorScheme.primary),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color: widget.isPrimary
                    ? Colors.white
                    : widget.colorScheme.primary,
                size: AppSizes.iconSm,
              ),
              SizedBox(width: AppSizes.spaceSm),
              Text(
                widget.label,
                style: widget.textTheme.titleSmall?.copyWith(
                  color: widget.isPrimary
                      ? Colors.white
                      : widget.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
