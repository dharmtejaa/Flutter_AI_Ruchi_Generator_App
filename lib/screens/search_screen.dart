import 'package:flutter/material.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';

/// Placeholder Search Screen
/// TODO: Implement search functionality
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: AppSizes.iconXl,
              color: colorScheme.primary,
            ),
            SizedBox(height: AppSizes.spaceHeightMd),
            Text(
              'Search Screen',
              style: textTheme.headlineMedium,
            ),
            SizedBox(height: AppSizes.spaceHeightSm),
            Text(
              'Implement your search functionality here',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

