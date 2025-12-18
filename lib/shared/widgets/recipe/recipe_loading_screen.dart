import 'dart:math' as math;
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecipeLoadingScreen extends StatefulWidget {
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
  State<RecipeLoadingScreen> createState() => _RecipeLoadingScreenState();
}

class _RecipeLoadingScreenState extends State<RecipeLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _pulseAnimation;

  final List<String> _loadingMessages = [
    'Analyzing your ingredients...',
    'Finding the perfect recipe...',
    'Calculating nutrition facts...',
    'Adding a pinch of magic...',
    'Almost ready...',
  ];
  int _currentMessageIndex = 0;

  @override
  void initState() {
    super.initState();

    // Main icon animation
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeInOut),
    );

    // Floating animation for decorative elements
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: -15, end: 15).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    // Pulse animation for glow effect
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _mainController.forward();

    // Cycle through loading messages
    _cycleMessages();
  }

  void _cycleMessages() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 2500));
      if (mounted) {
        setState(() {
          _currentMessageIndex =
              (_currentMessageIndex + 1) % _loadingMessages.length;
        });
      }
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surface,
            colorScheme.surfaceContainerHighest,
            colorScheme.surface,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Animated background elements
          ...List.generate(6, (index) => _buildFloatingElement(index)),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated icon with glow
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _scaleAnimation,
                    _pulseAnimation,
                  ]),
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (widget.iconColor ?? colorScheme.primary)
                                .withValues(alpha: 0.3 * _pulseAnimation.value),
                            blurRadius: 40 * _pulseAnimation.value,
                            spreadRadius: 10 * _pulseAnimation.value,
                          ),
                        ],
                      ),
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: _buildMainIcon(colorScheme),
                      ),
                    );
                  },
                ),

                SizedBox(height: AppSizes.spaceHeightXl),

                // Title with shimmer effect
                ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.secondary,
                        colorScheme.primary,
                      ],
                    ).createShader(bounds);
                  },
                  child: Text(
                    widget.title ?? 'Creating Your Recipe',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: AppSizes.spaceHeightLg),

                // Animated subtitle
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    widget.subtitle ?? _loadingMessages[_currentMessageIndex],
                    key: ValueKey<int>(_currentMessageIndex),
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                SizedBox(height: AppSizes.spaceHeightXxl),

                // Custom loading indicator
                _buildCustomLoadingIndicator(colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainIcon(ColorScheme colorScheme) {
    return Container(
      width: 120.w,
      height: 120.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.8),
            colorScheme.secondary,
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        widget.icon ?? Icons.auto_awesome,
        size: 56.sp,
        color: colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildFloatingElement(int index) {
    final colors = [
      Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
      Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
    ];

    final icons = [
      Icons.restaurant,
      Icons.local_fire_department,
      Icons.eco,
      Icons.favorite,
      Icons.star,
      Icons.local_dining,
    ];

    final positions = [
      Offset(30.w, 100.h),
      Offset(MediaQuery.of(context).size.width - 80.w, 150.h),
      Offset(50.w, MediaQuery.of(context).size.height - 200.h),
      Offset(
        MediaQuery.of(context).size.width - 100.w,
        MediaQuery.of(context).size.height - 250.h,
      ),
      Offset(MediaQuery.of(context).size.width * 0.5 - 20.w, 80.h),
      Offset(
        MediaQuery.of(context).size.width * 0.3,
        MediaQuery.of(context).size.height - 150.h,
      ),
    ];

    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        final offset =
            math.sin(
              (index * math.pi / 3) + _floatingController.value * math.pi * 2,
            ) *
            15;
        return Positioned(
          left: positions[index].dx,
          top: positions[index].dy + offset,
          child: Transform.rotate(
            angle: _floatingController.value * math.pi * 0.1,
            child: Container(
              width: 50.w + (index * 5).w,
              height: 50.h + (index * 5).h,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(
                icons[index],
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.3),
                size: 24.sp,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomLoadingIndicator(ColorScheme colorScheme) {
    return SizedBox(
      width: 200.w,
      child: Column(
        children: [
          // Progress dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final delay = index * 0.3;
                  final value = math
                      .sin((_pulseController.value + delay) * math.pi * 2)
                      .abs();
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 6.w),
                    width: 12.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(
                        alpha: 0.3 + value * 0.7,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(
                            alpha: value * 0.5,
                          ),
                          blurRadius: 10 * value,
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),

          SizedBox(height: AppSizes.spaceHeightMd),

          // Progress bar
          Container(
            height: 4.h,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(2),
            ),
            child: AnimatedBuilder(
              animation: _mainController,
              builder: (context, child) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          width:
                              constraints.maxWidth *
                              (0.2 +
                                  (_currentMessageIndex /
                                          _loadingMessages.length) *
                                      0.6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primary,
                                colorScheme.secondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
