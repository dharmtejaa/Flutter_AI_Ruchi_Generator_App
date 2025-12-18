import 'package:ai_ruchi/screens/entry/entry_screen.dart';
import 'package:ai_ruchi/screens/main/placeholder_screen.dart';
import 'package:ai_ruchi/shared/widgets/common/double_back_to_exit_wrapper.dart';
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

  final List<Widget> _screens = [
    const EntryScreen(),
    const PlaceholderScreen(
      title: 'Scan',
      icon: Icons.qr_code_scanner,
      description: 'Scan ingredients or recipes using your camera',
    ),
    const PlaceholderScreen(
      title: 'Saved Recipes',
      icon: Icons.bookmark,
      description: 'Your saved recipes will appear here',
    ),
    const PlaceholderScreen(
      title: 'Profile',
      icon: Icons.person,
      description: 'Manage your profile and preferences',
    ),
  ];

  void _onNavTap(int index) {
    HapticFeedback.selectionClick();
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

    return DoubleBackToExitWrapper(
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _screens),
        bottomNavigationBar: AppBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onNavTap,
        ),
      ),
    );
  }
}
