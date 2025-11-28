import 'package:ai_ruchi/core/theme/app_shadows.dart';
import 'package:ai_ruchi/shared/widgets/common/custom_snackbar.dart';
import 'package:flutter/material.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const AppBottomNavigationBar({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: AppShadows.bottomNavShadow(context),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap ?? _defaultOnTap(context),
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        selectedLabelStyle: textTheme.labelSmall?.copyWith(
          color: colorScheme.primary,
        ),
        unselectedLabelStyle: textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Cook',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Me',
          ),
        ],
      ),
    );
  }

  Function(int) _defaultOnTap(BuildContext context) {
    return (index) {
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
    };
  }
}


