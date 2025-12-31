import 'package:ai_ruchi/screens/entry/entry_screen.dart';
import 'package:ai_ruchi/screens/profile/profile_screen.dart';
import 'package:ai_ruchi/screens/saved/saved_recipes_screen.dart';
import 'package:ai_ruchi/screens/scan/scan_screen.dart';
import 'package:ai_ruchi/shared/widgets/common/double_back_to_exit.dart';
import 'package:ai_ruchi/shared/widgets/navigation/app_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;
  bool _isTapNavigation = false;
  late PageController _pageController;

  final List<Widget> _screens = [
    const EntryScreen(),
    const ScanScreen(),
    const SavedRecipesScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    _isTapNavigation = true;
    setState(() {
      _currentIndex = index;
    });
    // Use jumpToPage for instant navigation without animation lag
    _pageController.jumpToPage(index);
  }

  void _onPageChanged(int index) {
    if (_isTapNavigation) {
      _isTapNavigation = false;
    } else {
      HapticFeedback.lightImpact();
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    // Use surface color for entry screen, transparent for others
    final isEntryScreen = _currentIndex == 0;
    final statusBarColor = isEntryScreen
        ? colorScheme.surface
        : Colors.transparent;

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: statusBarColor,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: colorScheme.surface,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    return DoubleBackToExit(
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          physics: const BouncingScrollPhysics(),
          children: _screens,
        ),
        bottomNavigationBar: AppBottomNavigationBar(
          currentIndex: _currentIndex,
          pageController: _pageController, // Enables swipe-progress animations
          onTap: _onNavTap,
        ),
      ),
    );
  }
}
