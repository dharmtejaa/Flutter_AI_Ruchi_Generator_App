import 'package:ai_ruchi/core/theme/app_shadows.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/models/recipe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

class RecipeNutritionTab extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onRegenerate;
  final VoidCallback onSave;

  const RecipeNutritionTab({
    super.key,
    required this.recipe,
    required this.onRegenerate,
    required this.onSave,
  });

  PerServingNutrition get nutrition => recipe.nutrition.perServing;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppSizes.spaceHeightSm),

          // Calories Card
          _CaloriesCard(calories: nutrition.calories),
          SizedBox(height: AppSizes.spaceHeightMd),

          // Macronutrients Section
          _SectionHeader(
            title: 'Macronutrients',
            icon: Icons.pie_chart_outline,
          ),
          SizedBox(height: AppSizes.spaceHeightSm),
          _MacroChartCard(macros: nutrition.macros),
          SizedBox(height: AppSizes.spaceHeightMd),

          // Macro Details Grid
          _MacroDetailsGrid(macros: nutrition.macros),
          SizedBox(height: AppSizes.spaceHeightMd),

          // Vitamins Section
          _SectionHeader(
            title: 'Vitamins',
            icon: Icons.local_pharmacy_outlined,
          ),
          SizedBox(height: AppSizes.spaceHeightSm),
          _VitaminsGrid(micros: nutrition.micros),
          SizedBox(height: AppSizes.spaceHeightMd),

          // Minerals Section
          _SectionHeader(title: 'Minerals', icon: Icons.science_outlined),
          SizedBox(height: AppSizes.spaceHeightSm),
          _MineralsGrid(micros: nutrition.micros),
          SizedBox(height: AppSizes.spaceHeightLg),

          // Tips Section
          if (recipe.tips != null && recipe.tips!.isNotEmpty) ...[
            _SimpleInfoCard(
              icon: Icons.lightbulb_outline,
              iconColor: const Color(0xFFFFA726),
              bgColor: const Color(0xFFFFF8E1),
              title: 'Chef\'s Tip',
              content: recipe.tips!,
            ),
            SizedBox(height: AppSizes.spaceHeightMd),
          ],

          // Health Benefits Section
          if (recipe.healthBenefits.isNotEmpty) ...[
            _SimpleListCard(
              icon: Icons.favorite_outline,
              iconColor: const Color(0xFF66BB6A),
              bgColor: const Color(0xFFE8F5E9),
              title: 'Health Benefits',
              items: recipe.healthBenefits,
            ),
            SizedBox(height: AppSizes.spaceHeightMd),
          ],

          // Target Audience Section
          if (recipe.targetAudience.isNotEmpty) ...[
            _SimpleChipsCard(
              icon: Icons.groups_outlined,
              title: 'Suitable For',
              items: recipe.targetAudience,
            ),
            SizedBox(height: AppSizes.spaceHeightMd),
          ],

          // Disclaimer
          if (recipe.disclaimer.isNotEmpty) ...[
            _DisclaimerText(disclaimer: recipe.disclaimer),
            SizedBox(height: AppSizes.spaceHeightMd),
          ],

          SizedBox(height: AppSizes.spaceHeightLg),
        ],
      ),
    );
  }
}

// Section Header
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 20.sp, color: colorScheme.primary),
        SizedBox(width: 8.w),
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

// Calories Card
class _CaloriesCard extends StatelessWidget {
  final NutritionValue calories;

  const _CaloriesCard({required this.calories});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(
              Icons.local_fire_department,
              color: colorScheme.onPrimary,
              size: 24.sp,
            ),
          ),
          SizedBox(width: AppSizes.spaceMd),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Calories per serving',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${calories.value.toInt()}',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    calories.unit,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Macro Chart Card
class _MacroChartCard extends StatelessWidget {
  final Macros macros;

  const _MacroChartCard({required this.macros});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: AppShadows.cardShadow(context),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100.w,
            height: 100.h,
            child: CustomPaint(
              painter: _MacroPieChartPainter(
                carbs: macros.carbohydrates.percentage,
                protein: macros.protein.percentage,
                fat: macros.fat.percentage,
              ),
            ),
          ),
          SizedBox(width: AppSizes.spaceLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MacroLegendItem(
                  color: const Color(0xFF4CAF50),
                  label: 'Carbs',
                  value: macros.carbohydrates.value,
                  unit: macros.carbohydrates.unit,
                  percentage: macros.carbohydrates.percentage,
                ),
                SizedBox(height: 8.h),
                _MacroLegendItem(
                  color: const Color(0xFF2196F3),
                  label: 'Protein',
                  value: macros.protein.value,
                  unit: macros.protein.unit,
                  percentage: macros.protein.percentage,
                ),
                SizedBox(height: 8.h),
                _MacroLegendItem(
                  color: const Color(0xFF9C27B0),
                  label: 'Fat',
                  value: macros.fat.value,
                  unit: macros.fat.unit,
                  percentage: macros.fat.percentage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroLegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final double value;
  final String unit;
  final double percentage;

  const _MacroLegendItem({
    required this.color,
    required this.label,
    required this.value,
    required this.unit,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 10.w,
          height: 10.h,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          '${value.toInt()}$unit',
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            '${percentage.toInt()}%',
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

// Macro Details Grid (Fiber, Sugar)
class _MacroDetailsGrid extends StatelessWidget {
  final Macros macros;

  const _MacroDetailsGrid({required this.macros});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final otherMacros = macros.otherMacros;

    if (otherMacros.isEmpty) return const SizedBox.shrink();

    return Row(
      children: otherMacros.asMap().entries.map((entry) {
        final index = entry.key;
        final macro = entry.value;
        final isLast = index == otherMacros.length - 1;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 8.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    macro.name,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      '${macro.value % 1 == 0 ? macro.value.toInt() : macro.value.toStringAsFixed(1)} ${macro.unit}',
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// Modern Vitamins List
class _VitaminsGrid extends StatelessWidget {
  final Micros micros;

  const _VitaminsGrid({required this.micros});

  @override
  Widget build(BuildContext context) {
    final vitamins = micros.vitamins;

    if (vitamins.isEmpty) return _EmptyState(message: 'No vitamin data');

    return _NutrientsList(
      nutrients: vitamins,
      accentColor: const Color(0xFF4CAF50),
    );
  }
}

// Modern Minerals List
class _MineralsGrid extends StatelessWidget {
  final Micros micros;

  const _MineralsGrid({required this.micros});

  @override
  Widget build(BuildContext context) {
    final minerals = micros.minerals;

    if (minerals.isEmpty) return _EmptyState(message: 'No mineral data');

    return _NutrientsList(
      nutrients: minerals,
      accentColor: const Color(0xFF2196F3),
    );
  }
}

// Modern Nutrients List Widget (Expandable)
class _NutrientsList extends StatefulWidget {
  final List<MicroNutrientInfo> nutrients;
  final Color accentColor;
  final int initialVisibleCount;

  const _NutrientsList({
    required this.nutrients,
    required this.accentColor,
    this.initialVisibleCount = 3,
  });

  @override
  State<_NutrientsList> createState() => _NutrientsListState();
}

class _NutrientsListState extends State<_NutrientsList> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final hasMore = widget.nutrients.length > widget.initialVisibleCount;
    final visibleNutrients = _isExpanded
        ? widget.nutrients
        : widget.nutrients.take(widget.initialVisibleCount).toList();
    final remainingCount = widget.nutrients.length - widget.initialVisibleCount;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          // Nutrient rows
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: Column(
              children: visibleNutrients.asMap().entries.map((entry) {
                final index = entry.key;
                final nutrient = entry.value;
                final isLast = index == visibleNutrients.length - 1 && !hasMore;

                return _NutrientRow(
                  name: nutrient.name,
                  value: nutrient.value,
                  unit: nutrient.unit,
                  accentColor: widget.accentColor,
                  showDivider: !isLast,
                );
              }).toList(),
            ),
          ),

          // Show More / Show Less button
          if (hasMore)
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppSizes.radiusMd),
                bottomRight: Radius.circular(AppSizes.radiusMd),
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(AppSizes.radiusMd),
                    bottomRight: Radius.circular(AppSizes.radiusMd),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isExpanded ? 'Show less' : 'Show $remainingCount more',
                      style: textTheme.labelMedium?.copyWith(
                        color: widget.accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 18.sp,
                        color: widget.accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Single Nutrient Row
class _NutrientRow extends StatelessWidget {
  final String name;
  final double value;
  final String unit;
  final Color accentColor;
  final bool showDivider;

  const _NutrientRow({
    required this.name,
    required this.value,
    required this.unit,
    required this.accentColor,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMd,
            vertical: 12.h,
          ),
          child: Row(
            children: [
              // Accent dot
              Container(
                width: 6.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 12.w),
              // Name
              Expanded(
                child: Text(
                  name,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Value with unit
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value % 1 == 0
                          ? value.toInt().toString()
                          : value.toStringAsFixed(1),
                      style: textTheme.bodyMedium?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      unit,
                      style: textTheme.bodySmall?.copyWith(
                        color: accentColor.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: AppSizes.paddingMd + 18.w,
            endIndent: AppSizes.paddingMd,
            color: colorScheme.outline.withValues(alpha: 0.08),
          ),
      ],
    );
  }
}

// Empty State
class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 16.sp,
            color: colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: 8.w),
          Text(
            message,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// Simple Info Card (Tips)
class _SimpleInfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String content;

  const _SimpleInfoCard({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: iconColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            content,
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// Simple List Card (Health Benefits)
class _SimpleListCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final List<String> items;

  const _SimpleListCard({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: iconColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ...items.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, color: iconColor, size: 16.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      item,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Visual Target Audience Card
class _SimpleChipsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> items;

  const _SimpleChipsCard({
    required this.icon,
    required this.title,
    required this.items,
  });

  // Get icon based on audience type
  IconData _getIconForAudience(String audience) {
    final lower = audience.toLowerCase();
    if (lower.contains('vegan') || lower.contains('vegetarian')) {
      return Icons.eco_outlined;
    } else if (lower.contains('athlete') || lower.contains('fitness')) {
      return Icons.fitness_center;
    } else if (lower.contains('weight') || lower.contains('diet')) {
      return Icons.monitor_weight_outlined;
    } else if (lower.contains('heart') || lower.contains('cardio')) {
      return Icons.favorite_outline;
    } else if (lower.contains('diabetes') || lower.contains('sugar')) {
      return Icons.bloodtype_outlined;
    } else if (lower.contains('kid') ||
        lower.contains('child') ||
        lower.contains('family')) {
      return Icons.child_care;
    } else if (lower.contains('elderly') || lower.contains('senior')) {
      return Icons.elderly;
    } else if (lower.contains('protein') || lower.contains('muscle')) {
      return Icons.sports_gymnastics;
    } else if (lower.contains('energy') || lower.contains('active')) {
      return Icons.bolt;
    } else if (lower.contains('immunity') || lower.contains('health')) {
      return Icons.shield_outlined;
    }
    return Icons.person_outline;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: colorScheme.primary, size: 20.sp),
            ),
            SizedBox(width: 10.w),
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        // Visual Audience Chips
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: items.map((item) {
            final audienceIcon = _getIconForAudience(item);

            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.1,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      audienceIcon,
                      size: 14.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      item,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Disclaimer Text
class _DisclaimerText extends StatelessWidget {
  final String disclaimer;
  const _DisclaimerText({required this.disclaimer});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.paddingSm),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: colorScheme.onSurfaceVariant,
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              disclaimer,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Pie Chart Painter
class _MacroPieChartPainter extends CustomPainter {
  final double carbs;
  final double protein;
  final double fat;

  _MacroPieChartPainter({
    required this.carbs,
    required this.protein,
    required this.fat,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 5;
    final innerRadius = radius * 0.6;
    final total = carbs + protein + fat;
    if (total == 0) return;

    double startAngle = -math.pi / 2;
    _drawArc(
      canvas,
      center,
      radius,
      innerRadius,
      startAngle,
      (carbs / total) * 2 * math.pi,
      const Color(0xFF4CAF50),
    );
    startAngle += (carbs / total) * 2 * math.pi;
    _drawArc(
      canvas,
      center,
      radius,
      innerRadius,
      startAngle,
      (protein / total) * 2 * math.pi,
      const Color(0xFF2196F3),
    );
    startAngle += (protein / total) * 2 * math.pi;
    _drawArc(
      canvas,
      center,
      radius,
      innerRadius,
      startAngle,
      (fat / total) * 2 * math.pi,
      const Color(0xFF9C27B0),
    );
  }

  void _drawArc(
    Canvas canvas,
    Offset center,
    double outerRadius,
    double innerRadius,
    double startAngle,
    double sweepAngle,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(
        center.dx + innerRadius * math.cos(startAngle),
        center.dy + innerRadius * math.sin(startAngle),
      )
      ..lineTo(
        center.dx + outerRadius * math.cos(startAngle),
        center.dy + outerRadius * math.sin(startAngle),
      )
      ..arcTo(
        Rect.fromCircle(center: center, radius: outerRadius),
        startAngle,
        sweepAngle,
        false,
      )
      ..lineTo(
        center.dx + innerRadius * math.cos(startAngle + sweepAngle),
        center.dy + innerRadius * math.sin(startAngle + sweepAngle),
      )
      ..arcTo(
        Rect.fromCircle(center: center, radius: innerRadius),
        startAngle + sweepAngle,
        -sweepAngle,
        false,
      )
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
