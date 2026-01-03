import 'package:ai_ruchi/providers/ingredients_provider.dart';
import 'package:ai_ruchi/screens/entry/entry_screen.dart';
import 'package:ai_ruchi/screens/profile/profile_screen.dart';
import 'package:ai_ruchi/screens/saved/saved_recipes_screen.dart';
import 'package:ai_ruchi/screens/scan/scan_screen.dart';
import 'package:ai_ruchi/core/services/haptic_service.dart';
import 'package:ai_ruchi/shared/widgets/navigation/app_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;
  bool _isTapNavigation = false;
  late PageController _pageController;
  DateTime? _lastBackPressTime;

  /// GlobalKey for EntryScreen to call showPreferencesSheet() method
  final GlobalKey<EntryScreenState> _entryScreenKey =
      GlobalKey<EntryScreenState>();

  /// GlobalKey for ScanScreen to call openCamera() method
  final GlobalKey<ScanScreenState> _scanScreenKey =
      GlobalKey<ScanScreenState>();

  // ============================================================================
  // BOTTOM NAVIGATION GLOBAL KEYS (for tutorial targeting)
  // ============================================================================
  final GlobalKey _recipesNavKey = GlobalKey();
  final GlobalKey _scanNavKey = GlobalKey();

  /// Screens list - using keys for Entry and Scan screens
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);

    // Initialize screens with GlobalKeys for Entry and Scan screens
    // Also pass nav keys for tutorial targeting
    _screens = [
      EntryScreen(key: _entryScreenKey, recipesNavKey: _recipesNavKey),
      ScanScreen(key: _scanScreenKey, scanNavKey: _scanNavKey),
      const SavedRecipesScreen(),
      const ProfileScreen(),
    ];
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
    // Use jumpToPage for instant page switch
    // The bottom navigation bar handles its own smooth animation
    // Using animateToPage here causes double animation effect
    _pageController.jumpToPage(index);
  }

  /// Handle re-tap on the same tab
  void _onNavReTap(int index) {
    switch (index) {
      case 0:
        // Re-tap on Recipes tab -> Show preferences bottom sheet
        _entryScreenKey.currentState?.showPreferencesSheet();
        break;
      case 1:
        // Re-tap on Scan tab -> Open camera
        _scanScreenKey.currentState?.openCamera();
        break;
    }
  }

  void _onPageChanged(int index) {
    if (_isTapNavigation) {
      _isTapNavigation = false;
    } else {
      HapticService.lightImpact();
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // If not on Home tab, go to Home tab
        if (_currentIndex != 0) {
          _onNavTap(0);
          return;
        }

        // Double back logic
        final now = DateTime.now();
        if (_lastBackPressTime == null ||
            now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
          // First back press
          _lastBackPressTime = now;
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Press back again to exit',
                style: TextStyle(color: colorScheme.onInverseSurface),
              ),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              backgroundColor: colorScheme.inverseSurface,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else {
          // Second back press within duration
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        extendBody: true,
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          physics: const BouncingScrollPhysics(),
          children: _screens,
        ),
        bottomNavigationBar: Consumer<IngredientsProvider>(
          builder: (context, ingredientsProvider, child) {
            final hasIngredients =
                ingredientsProvider.currentIngredients.isNotEmpty;

            return AppBottomNavigationBar(
              currentIndex: _currentIndex,
              pageController: _pageController,
              onTap: _onNavTap,
              onReTap: _onNavReTap,
              hasIngredients: hasIngredients,
              recipesNavKey: _recipesNavKey,
              scanNavKey: _scanNavKey,
            );
          },
        ),
      ),
    );
  }
}
