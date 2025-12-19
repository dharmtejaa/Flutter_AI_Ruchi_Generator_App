import 'package:ai_ruchi/core/theme/app_shadows.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/shared/widgets/common/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const AppBottomNavigationBar({super.key, this.currentIndex = 0, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final items = [
      _NavItem(
        icon: Icons.restaurant_menu_outlined,
        activeIcon: Icons.restaurant_menu,
        label: 'Cook',
      ),
      _NavItem(
        icon: Icons.qr_code_scanner_outlined,
        activeIcon: Icons.qr_code_scanner,
        label: 'Scan',
      ),
      _NavItem(
        icon: Icons.bookmark_outline,
        activeIcon: Icons.bookmark,
        label: 'Saved',
      ),
      _NavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Me',
      ),
    ];

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingLg,
          vertical: 8.h,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingSm,
            vertical: 8.h,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusXxxl),
            boxShadow: AppShadows.elevatedShadow(context),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isActive = currentIndex == index;

              return _FloatingNavItem(
                icon: isActive ? item.activeIcon : item.icon,
                label: item.label,
                isActive: isActive,
                onTap: () {
                  if (onTap != null) {
                    onTap!(index);
                  } else {
                    _defaultOnTap(context, index);
                  }
                },
              );
            }),
          ),
        ),
      ),
    );
  }

  void _defaultOnTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        // Already on Cook screen
        break;
      case 1:
        CustomSnackBar.showInfo(context, 'Scan feature coming soon');
        break;
      case 2:
        CustomSnackBar.showInfo(context, 'Saved recipes coming soon');
        break;
      case 3:
        CustomSnackBar.showInfo(context, 'Profile coming soon');
        break;
    }
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  _NavItem({required this.icon, required this.activeIcon, required this.label});
}

class _FloatingNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FloatingNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_FloatingNavItem> createState() => _FloatingNavItemState();
}

class _FloatingNavItemState extends State<_FloatingNavItem>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation for press effect
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // Bounce animation for active state
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    if (widget.isActive) {
      _bounceController.forward();
    }
  }

  @override
  void didUpdateWidget(_FloatingNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _bounceController.forward(from: 0);
      } else {
        _bounceController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        // Subtle haptic feedback
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedBuilder(
          animation: _bounceAnimation,
          builder: (context, child) {
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: widget.isActive ? 14.w : 10.w,
                vertical: 6.h,
              ),
              decoration: BoxDecoration(
                color: widget.isActive ? colorScheme.primary : null,
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated icon
                  Transform.scale(
                    scale: widget.isActive
                        ? 1.0 + (_bounceAnimation.value * 0.1)
                        : 1.0,
                    child: Icon(
                      widget.icon,
                      color: widget.isActive
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                      size: 22.sp,
                    ),
                  ),
                  // Animated label (only show when active)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: widget.isActive
                        ? Padding(
                            padding: EdgeInsets.only(left: 6.w),
                            child: Text(
                              widget.label,
                              style: textTheme.labelMedium?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.sp,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
