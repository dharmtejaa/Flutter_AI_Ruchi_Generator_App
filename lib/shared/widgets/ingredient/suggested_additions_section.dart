import 'package:ai_ruchi/core/theme/app_shadows.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/providers/ingredients_provider.dart';
import 'package:ai_ruchi/shared/widgets/common/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SuggestedAdditionsSection extends StatelessWidget {
  final String? title;
  final List<String>? suggestions;

  const SuggestedAdditionsSection({super.key, this.title, this.suggestions});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.watch<IngredientsProvider>();
    final items = suggestions ?? provider.suggestedAdditions;

    if (items.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title ?? 'Suggested Additions',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: AppSizes.spaceHeightMd),
        Wrap(
          spacing: AppSizes.spaceSm,
          runSpacing: AppSizes.spaceHeightSm,
          children: items.map((suggestion) {
            return _SuggestionChip(
              suggestion: suggestion,
              onTap: () {
                provider.addSuggestedIngredient(suggestion);
                CustomSnackBar.showSuccess(context, '$suggestion added');
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String suggestion;
  final VoidCallback onTap;

  const _SuggestionChip({required this.suggestion, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMd,
          vertical: AppSizes.vPaddingSm,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          boxShadow: AppShadows.cardShadow(context),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: colorScheme.primary, size: AppSizes.iconSm),
            SizedBox(width: AppSizes.spaceXs),
            Text(
              suggestion,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
