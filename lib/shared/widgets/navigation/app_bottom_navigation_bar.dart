import 'package:ai_ruchi/core/theme/app_shadows.dart';
import 'package:ai_ruchi/core/theme/light_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// =============================================================================
// AppBottomNavigationBar - Premium Animated Bottom Navigation
// =============================================================================

/// Animation configuration constants - easily adjustable
class _NavConstants {
  // Sizes
  static double get selectedSize => 62.w;
  static double get unselectedSize => 48.w;
  static double get spacing => 16.w;
  static double get containerHeight => 76.h;

  // Icon sizes
  static double get activeIconSize => 30.sp;
  static double get inactiveIconSize => 24.sp;

  // Animation
  static const Duration scrollDuration = Duration(milliseconds: 350);
  static const Curve scrollCurve = Curves.easeOutCubic;
  static const double inactiveScale = 0.92;
  static const double inactiveOpacity = 0.55;
  static const double activeOpacity = 1.0;
}

/// Bottom navigation bar with swipe-progress-driven animations
class AppBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int)? onTap;

  /// PageController from the main PageView for swipe sync
  /// This is CRITICAL for smooth swipe-driven animations
  final PageController? pageController;

  const AppBottomNavigationBar({
    super.key,
    this.currentIndex = 0,
    this.onTap,
    this.pageController,
  });

  @override
  State<AppBottomNavigationBar> createState() => _AppBottomNavigationBarState();
}

class _AppBottomNavigationBarState extends State<AppBottomNavigationBar> {
  late ScrollController _scrollController;

  /// ValueNotifier for current page value (continuous during swipe)
  /// Replaces setState for performant animations
  late final ValueNotifier<double> _pageNotifier;

  /// Flag to prevent scroll conflicts during programmatic scrolling
  bool _isProgrammaticScroll = false;

  /// Flag to indicate user is manually scrolling the bottom bar
  bool _isInteracting = false;

  /// Tracks the last index that triggered haptic feedback
  int _lastHapticIndex = 0;

  // Navigation items
  final List<_NavItem> _items = [
    _NavItem(
      icon: Icons.restaurant_menu_outlined,
      activeIcon: Icons.restaurant_menu,
      label: 'Recipes',
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
      label: 'Profile',
    ),
  ];

  // Calculate item extent for layout
  double get _itemExtent => _NavConstants.selectedSize + _NavConstants.spacing;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _pageNotifier = ValueNotifier(widget.currentIndex.toDouble());
    _lastHapticIndex = widget.currentIndex;

    // Listen to PageController for continuous swipe progress
    widget.pageController?.addListener(_onPageControllerUpdate);

    // Scroll to initial position after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animateScrollToPage(_pageNotifier.value, animate: false);
    });
  }

  @override
  void didUpdateWidget(AppBottomNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle PageController changes
    if (oldWidget.pageController != widget.pageController) {
      oldWidget.pageController?.removeListener(_onPageControllerUpdate);
      widget.pageController?.addListener(_onPageControllerUpdate);
    }

    // If currentIndex changed programmatically (not from swipe), update
    if (oldWidget.currentIndex != widget.currentIndex &&
        _pageNotifier.value.round() != widget.currentIndex) {
      _pageNotifier.value = widget.currentIndex.toDouble();
      _animateScrollToPage(_pageNotifier.value, animate: true);
    }
  }

  @override
  void dispose() {
    widget.pageController?.removeListener(_onPageControllerUpdate);
    _scrollController.dispose();
    _pageNotifier.dispose();
    super.dispose();
  }

  /// Called continuously during PageView swiping
  void _onPageControllerUpdate() {
    // Ignore PageView updates if user is manually dragging the bottom bar
    if (_isInteracting) return;

    if (widget.pageController?.hasClients != true) return;

    final newPageValue = widget.pageController!.page ?? 0.0;

    // Only update if value actually changed
    if ((newPageValue - _pageNotifier.value).abs() > 0.001) {
      _pageNotifier.value = newPageValue;
      _checkSelectionHaptic(newPageValue);

      // Smoothly scroll the bottom bar to follow the swipe
      _syncScrollWithPageValue(newPageValue);
    }
  }

  /// Sync the bottom bar scroll position with the current page value
  void _syncScrollWithPageValue(double pageValue) {
    if (!_scrollController.hasClients || _isProgrammaticScroll) return;

    final targetOffset = _calculateScrollOffset(pageValue);
    final maxScroll = _scrollController.position.maxScrollExtent;
    final clampedOffset = targetOffset.clamp(0.0, maxScroll);

    // Use jumpTo for continuous sync during swipe (no animation delay)
    _scrollController.jumpTo(clampedOffset);
  }

  /// Calculate the scroll offset to center an item at given (continuous) page value
  double _calculateScrollOffset(double pageValue) {
    return pageValue * _itemExtent;
  }

  /// Animate scroll to center a specific page
  void _animateScrollToPage(double pageValue, {bool animate = true}) {
    if (!_scrollController.hasClients) return;

    final targetOffset = _calculateScrollOffset(pageValue);
    final maxScroll = _scrollController.position.maxScrollExtent;
    final clampedOffset = targetOffset.clamp(0.0, maxScroll);

    _isProgrammaticScroll = true;

    if (animate) {
      _scrollController
          .animateTo(
            clampedOffset,
            duration: _NavConstants.scrollDuration,
            curve: _NavConstants.scrollCurve,
          )
          .then((_) {
            _isProgrammaticScroll = false;
          });
    } else {
      _scrollController.jumpTo(clampedOffset);
      _isProgrammaticScroll = false;
    }
  }

  void _onItemTap(int index) {
    // Light haptic feedback
    HapticFeedback.lightImpact();

    // Update local page value
    _pageNotifier.value = index.toDouble();
    _lastHapticIndex = index;

    // Animate scroll
    _animateScrollToPage(index.toDouble(), animate: true);

    // Notify parent
    widget.onTap?.call(index);
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    // Ignore programmatic scrolls to prevent feedback loops
    if (_isProgrammaticScroll) return false;

    if (notification is ScrollStartNotification) {
      if (notification.dragDetails != null) {
        _isInteracting = true;
      }
    }

    if (notification is ScrollUpdateNotification) {
      if (_isInteracting) {
        final val = _scrollController.offset / _itemExtent;
        _pageNotifier.value = val;
        _checkSelectionHaptic(val);
      }
    }

    if (notification is ScrollEndNotification) {
      if (_isInteracting) {
        _isInteracting = false;
        _snapToNearest();
      }
    }
    return false;
  }

  void _snapToNearest() {
    final nearest = (_pageNotifier.value + 0.5).floor().clamp(
      0,
      _items.length - 1,
    );

    if (nearest != widget.currentIndex) {
      _onItemTap(nearest);
    } else {
      _animateScrollToPage(nearest.toDouble());
    }
  }

  void _checkSelectionHaptic(double value) {
    final newIndex = value.round();
    if (newIndex != _lastHapticIndex) {
      _lastHapticIndex = newIndex;
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Calculate horizontal padding to allow first/last items to center
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = (screenWidth - _NavConstants.selectedSize) / 2;

    return SafeArea(
      top: false,
      child: SizedBox(
        height: _NavConstants.containerHeight,
        child: NotificationListener<ScrollNotification>(
          onNotification: _handleScrollNotification,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            itemCount: _items.length,
            itemExtent: _itemExtent,
            itemBuilder: (context, index) {
              final item = _items[index];

              return Center(
                child: _AnimatedNavItemWidget(
                  item: item,
                  index: index,
                  pageNotifier: _pageNotifier,
                  colorScheme: colorScheme,
                  onTap: () => _onItemTap(index),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  _NavItem({required this.icon, required this.activeIcon, required this.label});
}

/// Individual navigation item with swipe-progress-driven animations using ValueNotifier
class _AnimatedNavItemWidget extends StatelessWidget {
  final _NavItem item;
  final int index;
  final ValueNotifier<double> pageNotifier;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _AnimatedNavItemWidget({
    required this.item,
    required this.index,
    required this.pageNotifier,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: pageNotifier,
      builder: (context, pageValue, child) {
        final activeness = _calculateActiveness(pageValue);

        // ========================================================================
        // INTERPOLATION CALCULATIONS
        // ========================================================================

        // Size interpolation
        final circleSize = _lerpDouble(
          _NavConstants.unselectedSize,
          _NavConstants.selectedSize,
          activeness,
        );

        // Icon size interpolation
        final iconSize = _lerpDouble(
          _NavConstants.inactiveIconSize,
          _NavConstants.activeIconSize,
          activeness,
        );

        // Scale factor
        final scale = _lerpDouble(_NavConstants.inactiveScale, 1.0, activeness);

        // Opacity interpolation
        final opacity = _lerpDouble(
          _NavConstants.inactiveOpacity,
          _NavConstants.activeOpacity,
          activeness,
        );

        // Colors
        final activeColor = colorScheme.surface;
        final inactiveColor = colorScheme.onSurfaceVariant.withValues(
          alpha: 0.4,
        );

        final Color bgColor = Color.lerp(
          inactiveColor,
          activeColor,
          activeness,
        )!;

        final activeIconColor = colorScheme.primary;
        final inactiveIconColor = LightThemeColors.mediumGray;
        final iconColor = Color.lerp(
          inactiveIconColor,
          activeIconColor,
          activeness,
        )!;

        // Shadow
        final shadows = activeness > 0.3
            ? AppShadows.floatingShadow(context)
            : null;

        // Icon
        final icon = activeness > 0.5 ? item.activeIcon : item.icon;

        return GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: bgColor,
                  boxShadow: shadows,
                ),
                child: Center(
                  child: Icon(icon, color: iconColor, size: iconSize),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double _calculateActiveness(double pageValue) {
    final distance = (pageValue - index).abs();
    if (distance >= 1.0) return 0.0;
    return 1.0 - distance;
  }

  /// Linear interpolation helper
  double _lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }
}
