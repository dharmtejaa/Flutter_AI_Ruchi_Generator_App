import 'package:ai_ruchi/core/theme/app_shadows.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Bottom navigation bar with auto-scroll to center selected item
class AppBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const AppBottomNavigationBar({super.key, this.currentIndex = 0, this.onTap});

  @override
  State<AppBottomNavigationBar> createState() => _AppBottomNavigationBarState();
}

class _AppBottomNavigationBarState extends State<AppBottomNavigationBar> {
  late ScrollController _scrollController;

  // Navigation items
  final List<_NavItem> _items = [
    _NavItem(
      icon: Icons.restaurant_menu_outlined,
      activeIcon: Icons.restaurant_menu,
    ),
    _NavItem(
      icon: Icons.qr_code_scanner_outlined,
      activeIcon: Icons.qr_code_scanner,
    ),
    _NavItem(icon: Icons.bookmark_outline, activeIcon: Icons.bookmark),
    _NavItem(icon: Icons.person_outline, activeIcon: Icons.person),
  ];

  // Sizes
  double get _selectedSize => 64.w;
  double get _unselectedSize => 48.w;
  double get _spacing => 16.w;
  double get _itemExtent => _selectedSize + _spacing;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Scroll to initial position after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToIndex(widget.currentIndex);
    });
  }

  @override
  void didUpdateWidget(AppBottomNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Scroll when index changes externally (e.g., page swipe)
    if (oldWidget.currentIndex != widget.currentIndex) {
      _scrollToIndex(widget.currentIndex);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Scroll to center the item at given index with smooth animation
  void _scrollToIndex(int index) {
    if (!_scrollController.hasClients) return;

    // Calculate target scroll position
    final targetOffset = index * _itemExtent;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final clampedOffset = targetOffset.clamp(0.0, maxScroll);

    // Smooth animation - 400ms for visible, smooth movement
    _scrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onItemTap(int index) {
    // Light haptic feedback for subtle feel
    HapticFeedback.lightImpact();

    // Notify parent first
    if (widget.onTap != null) {
      widget.onTap!(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Calculate horizontal padding to allow first/last items to center
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = (screenWidth - _selectedSize) / 2;

    return SafeArea(
      top: false,
      child: SizedBox(
        height: 100.h,
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics:
              const NeverScrollableScrollPhysics(), // Disable manual scroll
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          itemCount: _items.length,
          itemExtent: _itemExtent,
          itemBuilder: (context, index) {
            final item = _items[index];
            final isActive = widget.currentIndex == index;

            return Center(
              child: _NavItemWidget(
                icon: isActive ? item.activeIcon : item.icon,
                isActive: isActive,
                selectedSize: _selectedSize,
                unselectedSize: _unselectedSize,
                colorScheme: colorScheme,
                onTap: () => _onItemTap(index),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;

  _NavItem({required this.icon, required this.activeIcon});
}

class _NavItemWidget extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final double selectedSize;
  final double unselectedSize;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _NavItemWidget({
    required this.icon,
    required this.isActive,
    required this.selectedSize,
    required this.unselectedSize,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double circleSize = isActive ? selectedSize : unselectedSize;
    final double iconSize = isActive ? 28.sp : 22.sp;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: circleSize,
        height: circleSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive
              ? colorScheme.surface
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          boxShadow: isActive ? AppShadows.cardShadow(context) : null,
        ),
        child: Center(
          child: Icon(
            icon,
            color: isActive
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            size: iconSize,
          ),
        ),
      ),
    );
  }
}
