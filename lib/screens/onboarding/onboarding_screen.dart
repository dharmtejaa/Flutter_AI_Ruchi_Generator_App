import 'package:ai_ruchi/core/utils/app_router.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final List<OnboardingData> _onboardingPages = [
    OnboardingData(
      icon: Icons.camera_alt_rounded,
      title: 'Scan Your Ingredients',
      description:
          'Simply take a photo of your ingredients and our AI will instantly recognize them. No more manual typing!',
      gradient: [Color(0xFFFF7043), Color(0xFFFF5722)],
    ),
    OnboardingData(
      icon: Icons.auto_awesome_rounded,
      title: 'AI-Powered Recipes',
      description:
          'Our intelligent AI analyzes your ingredients and creates personalized, delicious recipes tailored just for you.',
      gradient: [Color(0xFF7C4DFF), Color(0xFF651FFF)],
    ),
    OnboardingData(
      icon: Icons.restaurant_menu_rounded,
      title: 'Customize & Save',
      description:
          'Adjust serving sizes, dietary preferences, and save your favorite recipes for quick access anytime.',
      gradient: [Color(0xFF00BCD4), Color(0xFF00ACC1)],
    ),
    OnboardingData(
      icon: Icons.favorite_rounded,
      title: 'Cook with Confidence',
      description:
          'Get step-by-step instructions, nutritional information, and become a better cook every day!',
      gradient: [Color(0xFFE91E63), Color(0xFFD81B60)],
    ),
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });

    // Reset and replay animations
    _fadeController.reset();
    _scaleController.reset();
    _fadeController.forward();
    _scaleController.forward();
  }

  Future<void> _completeOnboarding() async {
    // Save onboarding completion status
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    // Update the static variable so the router doesn't redirect back
    AppRouter.isOnboardingCompleted = true;

    if (mounted) {
      // Use go to navigate to root and clear stack
      context.go('/');
    }
  }

  void _nextPage() {
    if (_currentPage < _onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [colorScheme.surface, colorScheme.surfaceContainerHighest]
                : [
                    colorScheme.surface,
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip Button
              _buildSkipButton(colorScheme, textTheme),

              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _onboardingPages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(
                      context,
                      _onboardingPages[index],
                      colorScheme,
                      textTheme,
                    );
                  },
                ),
              ),

              // Bottom Section with Indicators and Button
              _buildBottomSection(colorScheme, textTheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton(ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMd,
        vertical: AppSizes.vPaddingSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _skipOnboarding,
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.onSurfaceVariant,
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMd,
                vertical: AppSizes.vPaddingXs,
              ),
            ),
            child: Text(
              'Skip',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(
    BuildContext context,
    OnboardingData data,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Icon Container
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 160.w,
                height: 160.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: data.gradient,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: data.gradient[0].withValues(alpha: 0.4),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: data.gradient[1].withValues(alpha: 0.2),
                      blurRadius: 60,
                      offset: const Offset(0, 30),
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer ring
                    Container(
                      width: 140.w,
                      height: 140.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 2,
                        ),
                      ),
                    ),
                    // Inner icon
                    Icon(data.icon, size: 70.sp, color: Colors.white),
                    // Decorative dots
                    Positioned(
                      top: 20.h,
                      right: 25.w,
                      child: Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 30.h,
                      left: 20.w,
                      child: Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: AppSizes.spaceHeightXxl),

            // Title
            Text(
              data.title,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: AppSizes.spaceHeightMd),

            // Description
            Container(
              constraints: BoxConstraints(maxWidth: 300.w),
              child: Text(
                data.description,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.6,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection(ColorScheme colorScheme, TextTheme textTheme) {
    final bool isLastPage = _currentPage == _onboardingPages.length - 1;

    return Container(
      padding: EdgeInsets.only(
        left: AppSizes.paddingXl,
        right: AppSizes.paddingXl,
        bottom: AppSizes.vPaddingXl,
        top: AppSizes.vPaddingMd,
      ),
      child: Column(
        children: [
          // Page Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _onboardingPages.length,
              (index) => _buildIndicator(index, colorScheme),
            ),
          ),

          SizedBox(height: AppSizes.spaceHeightXl),

          // Action Button
          Container(
            width: double.infinity,
            height: 56.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLastPage ? 'Get Started' : 'Next',
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (!isLastPage) ...[
                    SizedBox(width: AppSizes.spaceSm),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: AppSizes.iconSm,
                      color: Colors.white,
                    ),
                  ] else ...[
                    SizedBox(width: AppSizes.spaceSm),
                    Icon(
                      Icons.restaurant_rounded,
                      size: AppSizes.iconSm,
                      color: Colors.white,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(int index, ColorScheme colorScheme) {
    final bool isActive = index == _currentPage;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      width: isActive ? 32.w : 10.w,
      height: 10.h,
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.7),
                ],
              )
            : null,
        color: isActive ? null : colorScheme.outline.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
    );
  }
}

/// Data model for onboarding pages
class OnboardingData {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;

  OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });
}
