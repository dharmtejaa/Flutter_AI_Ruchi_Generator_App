// =============================================================================
// CenteredBottomNav - A reusable Flutter widget for centered bottom navigation
// =============================================================================
//
// USAGE:
// Place inside a Scaffold's bottomNavigationBar:
//
//   Scaffold(
//     body: PageView(
//       controller: _pageController,
//       onPageChanged: (index) => setState(() => _currentIndex = index),
//       children: pages,
//     ),
//     bottomNavigationBar: CenteredBottomNav(
//       items: [
//         CenteredNavItem(icon: Icons.home, label: 'Home'),
//         CenteredNavItem(icon: Icons.search, label: 'Search'),
//         CenteredNavItem(icon: Icons.person, label: 'Profile'),
//       ],
//       currentIndex: _currentIndex,
//       onChanged: (index) {
//         setState(() => _currentIndex = index);
//         _pageController.animateToPage(index, ...);
//       },
//     ),
//   )
//
// SYNC WITH PAGEVIEW:
// - When PageView changes, update currentIndex via setState
// - When nav item tapped, call pageController.animateToPage()
// - The widget handles centering animation automatically
//
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Model for each navigation item
class CenteredNavItem {
  /// The icon to display
  final IconData icon;

  /// Accessibility label for the item
  final String label;

  /// Optional custom widget to use instead of Icon
  final Widget? customIcon;

  const CenteredNavItem({
    required this.icon,
    required this.label,
    this.customIcon,
  });
}

/// A horizontally scrolling bottom navigation bar that centers the selected item.
///
/// Features:
/// - Smooth scroll animation to center selected item
/// - Selected item grows larger with elevated shadow
/// - Swipe/drag with snap-to-nearest behavior
/// - Full customization of sizes, colors, and animations
/// - Accessibility support with semantic labels
/// - Optional haptic feedback
class CenteredBottomNav extends StatefulWidget {
  /// List of navigation items
  final List<CenteredNavItem> items;

  /// Currently selected index
  final int currentIndex;

  /// Callback when selection changes
  final ValueChanged<int> onChanged;

  /// Diameter of inactive (unselected) items
  final double inactiveDiameter;

  /// Diameter of active (selected) item
  final double activeDiameter;

  /// Spacing between item centers
  final double spacing;

  /// Icon color for the active/selected item
  final Color? activeIconColor;

  /// Icon color for inactive/unselected items
  final Color? inactiveIconColor;

  /// Background color for the active/selected item
  final Color activeBgColor;

  /// Background color for inactive items
  final Color? inactiveBgColor;

  /// Duration of animations
  final Duration animationDuration;

  /// Whether to enable haptic feedback on selection
  final bool enableHaptics;

  /// Scale factor for non-centered items (subtle shrink effect)
  final double inactiveScale;

  /// Whether to show outer ring on active item (useful on dark backgrounds)
  final bool showActiveRing;

  /// Color of the active ring
  final Color? activeRingColor;

  /// Background color of the nav bar container
  final Color? backgroundColor;

  /// Height of the nav bar container
  final double height;

  const CenteredBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onChanged,
    this.inactiveDiameter = 56.0,
    this.activeDiameter = 88.0,
    this.spacing = 28.0,
    this.activeIconColor,
    this.inactiveIconColor,
    this.activeBgColor = Colors.white,
    this.inactiveBgColor,
    this.animationDuration = const Duration(milliseconds: 280),
    this.enableHaptics = true,
    this.inactiveScale = 0.92,
    this.showActiveRing = true,
    this.activeRingColor,
    this.backgroundColor,
    this.height = 120.0,
  });

  @override
  State<CenteredBottomNav> createState() => _CenteredBottomNavState();
}

class _CenteredBottomNavState extends State<CenteredBottomNav> {
  late ScrollController _scrollController;
  bool _isScrolling = false;
  int _pendingIndex = -1;

  // Calculate the extent (width) of each item slot including spacing
  double get _itemExtent => widget.activeDiameter + widget.spacing;

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
  void didUpdateWidget(CenteredBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If currentIndex changed programmatically, scroll to new position instantly
    if (oldWidget.currentIndex != widget.currentIndex && !_isScrolling) {
      _scrollToIndex(widget.currentIndex);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Calculate the scroll offset to center an item at given index
  ///
  /// Formula: offset = index * itemExtent - (viewportWidth - activeDiameter) / 2
  /// This ensures the center of the item aligns with the center of the viewport
  double _calculateScrollOffset(int index) {
    if (!_scrollController.hasClients) return 0.0;

    // Each item occupies activeDiameter width with spacing between
    // The scroll offset to center item[index]:
    final targetOffset = index * _itemExtent;

    return targetOffset;
  }

  /// Scroll to center the item at given index - instant movement
  void _scrollToIndex(int index) {
    if (!_scrollController.hasClients) return;

    final targetOffset = _calculateScrollOffset(index);
    final maxScroll = _scrollController.position.maxScrollExtent;
    final clampedOffset = targetOffset.clamp(0.0, maxScroll);

    // Use jumpTo for instant movement without animation
    _scrollController.jumpTo(clampedOffset);
  }

  /// Find the nearest item index based on current scroll position
  int _findNearestIndex() {
    if (!_scrollController.hasClients) return widget.currentIndex;

    final currentOffset = _scrollController.offset;
    final index = (currentOffset / _itemExtent).round();
    return index.clamp(0, widget.items.length - 1);
  }

  /// Handle tap on an item
  void _onItemTap(int index) {
    if (widget.enableHaptics) {
      HapticFeedback.selectionClick();
    }

    _isScrolling = true;
    _scrollToIndex(index);
    widget.onChanged(index);

    // Reset scrolling flag after animation completes
    Future.delayed(widget.animationDuration, () {
      _isScrolling = false;
    });
  }

  /// Handle scroll end - snap to nearest item
  void _onScrollEnd() {
    if (_pendingIndex >= 0) {
      _pendingIndex = -1;
      return;
    }

    final nearestIndex = _findNearestIndex();
    if (nearestIndex != widget.currentIndex) {
      if (widget.enableHaptics) {
        HapticFeedback.selectionClick();
      }
      widget.onChanged(nearestIndex);
    }
    _scrollToIndex(nearestIndex);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Default colors
    final activeIconColor = widget.activeIconColor ?? colorScheme.primary;
    final inactiveIconColor =
        widget.inactiveIconColor ?? Colors.grey.withValues(alpha: 0.6);
    final inactiveBgColor =
        widget.inactiveBgColor ?? Colors.black.withValues(alpha: 0.06);
    final activeRingColor = widget.activeRingColor ?? Colors.white;
    final bgColor = widget.backgroundColor ?? Colors.transparent;

    // Calculate content padding so first and last items can be centered
    final viewportWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = (viewportWidth - widget.activeDiameter) / 2;

    return Container(
      height: widget.height,
      color: bgColor,
      child: SafeArea(
        top: false,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollEndNotification) {
              _onScrollEnd();
            }
            return false;
          },
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            itemCount: widget.items.length,
            itemExtent: _itemExtent,
            itemBuilder: (context, index) {
              final item = widget.items[index];
              final isActive = index == widget.currentIndex;

              return _CenteredNavItemWidget(
                item: item,
                isActive: isActive,
                activeDiameter: widget.activeDiameter,
                inactiveDiameter: widget.inactiveDiameter,
                activeIconColor: activeIconColor,
                inactiveIconColor: inactiveIconColor,
                activeBgColor: widget.activeBgColor,
                inactiveBgColor: inactiveBgColor,
                showActiveRing: widget.showActiveRing,
                activeRingColor: activeRingColor,
                onTap: () => _onItemTap(index),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Individual navigation item widget - simplified for performance
class _CenteredNavItemWidget extends StatelessWidget {
  final CenteredNavItem item;
  final bool isActive;
  final double activeDiameter;
  final double inactiveDiameter;
  final Color activeIconColor;
  final Color inactiveIconColor;
  final Color activeBgColor;
  final Color inactiveBgColor;
  final bool showActiveRing;
  final Color activeRingColor;
  final VoidCallback onTap;

  const _CenteredNavItemWidget({
    required this.item,
    required this.isActive,
    required this.activeDiameter,
    required this.inactiveDiameter,
    required this.activeIconColor,
    required this.inactiveIconColor,
    required this.activeBgColor,
    required this.inactiveBgColor,
    required this.showActiveRing,
    required this.activeRingColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate sizes and colors based on active state
    final diameter = isActive ? activeDiameter : inactiveDiameter;
    final iconSize = isActive ? 32.0 : 24.0;
    final iconColor = isActive ? activeIconColor : inactiveIconColor;
    final bgColor = isActive ? activeBgColor : inactiveBgColor;

    // Shadow for active item - soft elevated effect
    final shadow = isActive
        ? [
            BoxShadow(
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 4),
              color: Colors.black.withValues(alpha: 0.1),
            ),
          ]
        : null;

    // Border for active item (useful on colored backgrounds)
    final border = isActive && showActiveRing
        ? Border.all(color: activeRingColor.withValues(alpha: 0.8), width: 3)
        : null;

    return Center(
      child: Semantics(
        label: item.label,
        button: true,
        selected: isActive,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          // Simple container without complex animations
          child: Container(
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor,
              boxShadow: shadow,
              border: border,
            ),
            child: Center(
              child:
                  item.customIcon ??
                  Icon(item.icon, size: iconSize, color: iconColor),
            ),
          ),
        ),
      ),
    );
  }
}
