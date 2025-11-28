import 'package:ai_ruchi/core/theme/app_shadows.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/models/recipe.dart';
import 'package:ai_ruchi/shared/widgets/recipe/recipe_action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

class RecipeNutritionTab extends StatelessWidget {
  final PerServingNutrition nutrition;
  final VoidCallback onRegenerate;
  final VoidCallback onSave;
  final VoidCallback? onViewDetails;

  const RecipeNutritionTab({
    super.key,
    required this.nutrition,
    required this.onRegenerate,
    required this.onSave,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSizes.spaceHeightMd),

                // Macronutrients Pie Chart
                GestureDetector(
                  onTap: () {
                    context.push('/nutrition', extra: nutrition);
                  },
                  child: _buildMacroChart(
                    context,
                    nutrition.macros,
                    colorScheme,
                    textTheme,
                  ),
                ),

                SizedBox(height: AppSizes.spaceHeightLg),

                // Macronutrients Grid
                Text(
                  'Macronutrients',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: AppSizes.spaceHeightMd),
                _buildMacroGrid(
                  context,
                  nutrition.macros,
                  colorScheme,
                  textTheme,
                ),

                SizedBox(height: AppSizes.spaceHeightLg),

                // Micronutrients Grid
                Text(
                  'Micronutrients',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: AppSizes.spaceHeightMd),
                _buildMicroGrid(
                  context,
                  nutrition.micros,
                  colorScheme,
                  textTheme,
                ),

                SizedBox(height: AppSizes.spaceHeightXl),
              ],
            ),
          ),
        ),
        RecipeActionButtons(onRegenerate: onRegenerate, onSave: onSave),
      ],
    );
  }

  Widget _buildMacroChart(
    BuildContext context,
    Macros macros,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingLg),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: AppShadows.cardShadow(context),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 200.w,
            height: 200.h,
            child: CustomPaint(
              painter: _MacroPieChartPainter(
                carbs: macros.carbohydrates.percentage,
                protein: macros.protein.percentage,
                fat: macros.fat.percentage,
              ),
            ),
          ),
          SizedBox(height: AppSizes.spaceHeightMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ChartLegend(color: Colors.green, label: 'Carbs'),
              _ChartLegend(color: Colors.blue, label: 'Protein'),
              _ChartLegend(color: Colors.purple, label: 'Fat'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroGrid(
    BuildContext context,
    Macros macros,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppSizes.spaceMd,
      mainAxisSpacing: AppSizes.spaceHeightMd,
      childAspectRatio: 2.5,
      children: [
        _NutritionCard(
          label: 'Carbohydrates',
          value: '${macros.carbohydrates.value.toInt()}',
          unit: macros.carbohydrates.unit,
          percentage: macros.carbohydrates.percentage,
          color: Colors.green,
        ),
        _NutritionCard(
          label: 'Protein',
          value: '${macros.protein.value.toInt()}',
          unit: macros.protein.unit,
          percentage: macros.protein.percentage,
          color: Colors.blue,
        ),
        _NutritionCard(
          label: 'Fat',
          value: '${macros.fat.value.toInt()}',
          unit: macros.fat.unit,
          percentage: macros.fat.percentage,
          color: Colors.purple,
        ),
        if (macros.fiber != null)
          _NutritionCard(
            label: 'Fiber',
            value: '${macros.fiber!.value.toInt()}',
            unit: macros.fiber!.unit,
            color: Colors.orange,
          ),
        if (macros.sugar != null)
          _NutritionCard(
            label: 'Sugar',
            value: '${macros.sugar!.value.toInt()}',
            unit: macros.sugar!.unit,
            color: Colors.pink,
          ),
      ],
    );
  }

  Widget _buildMicroGrid(
    BuildContext context,
    Micros micros,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final microList = [
      if (micros.vitaminA != null) _MicroItem('Vitamin A', micros.vitaminA!),
      if (micros.vitaminC != null) _MicroItem('Vitamin C', micros.vitaminC!),
      if (micros.vitaminD != null) _MicroItem('Vitamin D', micros.vitaminD!),
      if (micros.vitaminE != null) _MicroItem('Vitamin E', micros.vitaminE!),
      if (micros.vitaminK != null) _MicroItem('Vitamin K', micros.vitaminK!),
      if (micros.calcium != null) _MicroItem('Calcium', micros.calcium!),
      if (micros.iron != null) _MicroItem('Iron', micros.iron!),
      if (micros.magnesium != null) _MicroItem('Magnesium', micros.magnesium!),
      if (micros.potassium != null) _MicroItem('Potassium', micros.potassium!),
      if (micros.sodium != null) _MicroItem('Sodium', micros.sodium!),
      if (micros.zinc != null) _MicroItem('Zinc', micros.zinc!),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSizes.spaceMd,
        mainAxisSpacing: AppSizes.spaceHeightMd,
        childAspectRatio: 2.5,
      ),
      itemCount: microList.length,
      itemBuilder: (context, index) {
        final item = microList[index];
        return _NutritionCard(
          label: item.label,
          value: '${item.value.value.toInt()}',
          unit: item.value.unit,
          color: Colors.teal,
        );
      },
    );
  }
}

class _MicroItem {
  final String label;
  final NutritionValue value;

  _MicroItem(this.label, this.value);
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _ChartLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.h,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: AppSizes.spaceXs),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _NutritionCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final double? percentage;
  final Color color;

  const _NutritionCard({
    required this.label,
    required this.value,
    required this.unit,
    this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: AppShadows.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSizes.spaceHeightXs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              SizedBox(width: AppSizes.spaceXs),
              Text(
                unit,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (percentage != null) ...[
            SizedBox(height: AppSizes.spaceHeightXs),
            Text(
              '${percentage!.toStringAsFixed(0)}%',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

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
    final radius = math.min(size.width, size.height) / 2 - 10;

    final total = carbs + protein + fat;
    if (total == 0) return;

    double startAngle = -math.pi / 2; // Start from top

    // Carbs (Green)
    final carbsSweep = (carbs / total) * 2 * math.pi;
    final carbsPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      carbsSweep,
      true,
      carbsPaint,
    );
    startAngle += carbsSweep;

    // Protein (Blue)
    final proteinSweep = (protein / total) * 2 * math.pi;
    final proteinPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      proteinSweep,
      true,
      proteinPaint,
    );
    startAngle += proteinSweep;

    // Fat (Purple)
    final fatSweep = (fat / total) * 2 * math.pi;
    final fatPaint = Paint()
      ..color = Colors.purple
      ..style = PaintingStyle.fill;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      fatSweep,
      true,
      fatPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
