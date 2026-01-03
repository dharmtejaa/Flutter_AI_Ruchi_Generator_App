import 'package:ai_ruchi/core/services/haptic_service.dart';
import 'package:ai_ruchi/core/theme/app_shadows.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// =============================================================================
// AppBottomNavigationBar - Premium Animated Bottom Navigation
// =============================================================================

/// Animation configuration constants - easily adjustable
class _NavConstants {
  // Sizes
  static double get selectedSize => 60.w;
  static double get unselectedSize => 50.w;
  static double get spacing => 18.w;
  static double get containerHeight => 75.h;

  // Icon sizes
  static double get activeIconSize => 28.sp;
  static double get inactiveIconSize => 24.sp;

  // Animation
  static const Duration scrollDuration = Duration(milliseconds: 400);
  static const Curve scrollCurve = Curves.easeOutCubic;
  static const double inactiveScale = 0.92;
  static const double inactiveOpacity = 0.75;
  static const double activeOpacity = 1.0;
}

/// Bottom navigation bar with premium swipe-progress-driven animations
class AppBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int)? onTap;

  /// Callback when user taps on the ALREADY SELECTED tab
  final Function(int)? onReTap;

  /// PageController from the main PageView for swipe sync
  final PageController? pageController;

  /// Whether ingredients are present (affects Entry tab icon)
  final bool hasIngredients;

  /// GlobalKey for the Recipes/Generate nav item (for tutorial targeting)
  final GlobalKey? recipesNavKey;

  /// GlobalKey for the Scan nav item (for tutorial targeting)
  final GlobalKey? scanNavKey;

  const AppBottomNavigationBar({
    super.key,
    this.currentIndex = 0,
    this.onTap,
    this.onReTap,
    this.pageController,
    this.hasIngredients = false,
    this.recipesNavKey,
    this.scanNavKey,
  });

  @override
  State<AppBottomNavigationBar> createState() => _AppBottomNavigationBarState();
}

class _AppBottomNavigationBarState extends State<AppBottomNavigationBar> {
  late ScrollController _scrollController;

  /// ValueNotifier for current page value (continuous during swipe)
  late final ValueNotifier<double> _pageNotifier;

  /// Flag to prevent scroll conflicts during programmatic scrolling
  bool _isProgrammaticScroll = false;

  /// Flag to indicate user is manually scrolling the bottom bar
  bool _isInteracting = false;

  /// Tracks the last index that triggered haptic feedback
  int _lastHapticIndex = 0;

  // Navigation items - dynamically changes first item's icon based on hasIngredients
  List<_NavItem> get _items => [
    _NavItem(
      icon: widget.hasIngredients
          ? Icons.auto_awesome_outlined
          : Icons.restaurant_menu_outlined,
      activeIcon: widget.hasIngredients
          ? Icons.auto_awesome
          : Icons.restaurant_menu,
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

    // If currentIndex changed, update accordingly
    if (oldWidget.currentIndex != widget.currentIndex) {
      final isPageAnimating =
          widget.pageController?.hasClients == true &&
          widget.pageController!.position.isScrollingNotifier.value;

      if (!isPageAnimating) {
        _pageNotifier.value = widget.currentIndex.toDouble();
        _animateScrollToPage(_pageNotifier.value, animate: true);
      }
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
    if (_isInteracting) return;
    if (widget.pageController?.hasClients != true) return;

    final newPageValue = widget.pageController!.page ?? 0.0;

    if ((newPageValue - _pageNotifier.value).abs() > 0.001) {
      _pageNotifier.value = newPageValue;
      _checkSelectionHaptic(newPageValue);
      _syncScrollWithPageValue(newPageValue);
    }
  }

  /// Sync the bottom bar scroll position with the current page value
  void _syncScrollWithPageValue(double pageValue) {
    if (!_scrollController.hasClients || _isProgrammaticScroll) return;

    final targetOffset = _calculateScrollOffset(pageValue);
    final maxScroll = _scrollController.position.maxScrollExtent;
    final clampedOffset = targetOffset.clamp(0.0, maxScroll);

    _scrollController.jumpTo(clampedOffset);
  }

  /// Calculate the scroll offset to center an item at given page value
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
    HapticService.mediumImpact();

    if (index == widget.currentIndex) {
      widget.onReTap?.call(index);
      return;
    }

    _pageNotifier.value = index.toDouble();
    _lastHapticIndex = index;
    _animateScrollToPage(index.toDouble(), animate: true);
    widget.onTap?.call(index);
  }

  bool _handleScrollNotification(ScrollNotification notification) {
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
      HapticService.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = (screenWidth - _itemExtent) / 2;

    return SafeArea(
      top: false,

      child: SizedBox(
        height: _NavConstants.containerHeight,

        child: NotificationListener<ScrollNotification>(
          onNotification: _handleScrollNotification,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: _SnapScrollPhysics(
              itemExtent: _itemExtent,
              parent: const BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            itemCount: _items.length,
            itemExtent: _itemExtent,
            itemBuilder: (context, index) {
              final item = _items[index];

              GlobalKey? itemKey;
              if (index == 0) {
                itemKey = widget.recipesNavKey;
              } else if (index == 1) {
                itemKey = widget.scanNavKey;
              }

              final navWidget = _AnimatedNavItemWidget(
                item: item,
                index: index,
                pageNotifier: _pageNotifier,
                colorScheme: colorScheme,
                onTap: () => _onItemTap(index),
              );

              return Align(
                alignment: Alignment.center,
                child: itemKey != null
                    ? Container(key: itemKey, child: navWidget)
                    : navWidget,
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

/// Individual navigation item with gradient circle background
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

        // Apply easing for smoother visual transitions
        final easedActiveness = Curves.easeOutCubic.transform(activeness);

        // ========================================================================
        // INTERPOLATION CALCULATIONS
        // ========================================================================

        // Size interpolation with easing
        final circleSize = _lerpDouble(
          _NavConstants.unselectedSize,
          _NavConstants.selectedSize,
          easedActiveness,
        );

        // Icon size interpolation
        final iconSize = _lerpDouble(
          _NavConstants.inactiveIconSize,
          _NavConstants.activeIconSize,
          easedActiveness,
        );

        // Scale factor
        final scale = _lerpDouble(
          _NavConstants.inactiveScale,
          1,
          easedActiveness,
        );

        // Opacity interpolation
        final opacity = _lerpDouble(
          _NavConstants.inactiveOpacity,
          _NavConstants.activeOpacity,
          easedActiveness,
        );

        // Vertical offset for floating effect on active
        final verticalOffset = _lerpDouble(0, -6.h, easedActiveness);

        // ========================================================================
        // SOLID COLORS FOR CIRCLE
        // ========================================================================

        // Inactive and active background colors
        final inactiveBgColor = colorScheme.surfaceContainerHigh;
        final activeBgColor = colorScheme.primary;

        // Interpolate background color based on activeness
        final bgColor = Color.lerp(
          inactiveBgColor,
          activeBgColor,
          easedActiveness,
        )!;

        // ========================================================================
        // ICON COLORS
        // ========================================================================

        final inactiveIconColor = colorScheme.onSurfaceVariant;
        final activeIconColor = colorScheme.onPrimary;
        final iconColor = Color.lerp(
          inactiveIconColor,
          activeIconColor,
          easedActiveness,
        )!;

        // Icon selection
        final icon = easedActiveness > 0.5 ? item.activeIcon : item.icon;

        return GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Transform.translate(
            offset: Offset(0, verticalOffset),
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: circleSize,
                  height: circleSize,
                  margin: EdgeInsets.only(top: 10.h),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: bgColor,
                    boxShadow: AppShadows.fabShadow(context),
                  ),
                  child: Center(
                    child: Icon(icon, color: iconColor, size: iconSize),
                  ),
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

class _SnapScrollPhysics extends ScrollPhysics {
  final double itemExtent;

  const _SnapScrollPhysics({required this.itemExtent, super.parent});

  @override
  _SnapScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _SnapScrollPhysics(
      itemExtent: itemExtent,
      parent: buildParent(ancestor),
    );
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }

    final Tolerance tolerance = toleranceFor(position);
    final double target = _getTargetPixels(position, tolerance, velocity);

    if (target != position.pixels) {
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        target,
        velocity,
        tolerance: tolerance,
      );
    }
    return null;
  }

  double _getTargetPixels(
    ScrollMetrics position,
    Tolerance tolerance,
    double velocity,
  ) {
    double page = position.pixels / itemExtent;
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    return page.roundToDouble() * itemExtent;
  }
}
