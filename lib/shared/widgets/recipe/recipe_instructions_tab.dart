import 'package:ai_ruchi/core/theme/app_shadows.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/models/recipe.dart';
import 'package:ai_ruchi/shared/widgets/recipe/recipe_action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecipeInstructionsTab extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onRegenerate;
  final VoidCallback onSave;

  const RecipeInstructionsTab({
    super.key,
    required this.recipe,
    required this.onRegenerate,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingLg),
            itemCount: recipe.instructions.length,
            itemBuilder: (context, index) {
              final instruction = recipe.instructions[index];
              return Container(
                margin: EdgeInsets.only(bottom: AppSizes.spaceHeightMd),
                padding: EdgeInsets.all(AppSizes.paddingMd),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  boxShadow: AppShadows.cardShadow(context),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32.w,
                      height: 32.h,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSizes.spaceMd),
                    Expanded(
                      child: Text(
                        instruction,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        RecipeActionButtons(onRegenerate: onRegenerate, onSave: onSave),
      ],
    );
  }
}
