import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';

/// Service to manage the app onboarding tutorial using TutorialCoachMark
/// Provides beautiful, minimal UI with professional animations
class TutorialService {
  // SharedPreferences keys
  static const String _entryTutorialKey = 'entry_tutorial_shown';
  static const String _scanTutorialKey = 'scan_tutorial_shown';
  static const String _recipeTutorialKey = 'recipe_tutorial_shown';
  static const String _scanNavTutorialKey = 'scan_nav_tutorial_shown';
  static const String _generateNavTutorialKey = 'generate_nav_tutorial_shown';
  static const String _preferencesTutorialKey = 'preferences_tutorial_shown';

  /// Check if entry screen tutorial has been shown
  static Future<bool> isEntryTutorialShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_entryTutorialKey) ?? false;
  }

  /// Mark entry screen tutorial as shown
  static Future<void> markEntryTutorialShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_entryTutorialKey, true);
  }

  /// Check if scan screen tutorial has been shown
  static Future<bool> isScanTutorialShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_scanTutorialKey) ?? false;
  }

  /// Mark scan screen tutorial as shown
  static Future<void> markScanTutorialShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_scanTutorialKey, true);
  }

  /// Check if recipe screen tutorial has been shown
  static Future<bool> isRecipeTutorialShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_recipeTutorialKey) ?? false;
  }

  /// Mark recipe screen tutorial as shown
  static Future<void> markRecipeTutorialShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_recipeTutorialKey, true);
  }

  /// Check if scan nav tutorial has been shown
  static Future<bool> isScanNavTutorialShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_scanNavTutorialKey) ?? false;
  }

  /// Mark scan nav tutorial as shown
  static Future<void> markScanNavTutorialShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_scanNavTutorialKey, true);
  }

  /// Check if generate nav tutorial has been shown
  static Future<bool> isGenerateNavTutorialShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_generateNavTutorialKey) ?? false;
  }

  /// Mark generate nav tutorial as shown
  static Future<void> markGenerateNavTutorialShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_generateNavTutorialKey, true);
  }

  /// Check if preferences tutorial has been shown
  static Future<bool> isPreferencesTutorialShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_preferencesTutorialKey) ?? false;
  }

  /// Mark preferences tutorial as shown
  static Future<void> markPreferencesTutorialShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_preferencesTutorialKey, true);
  }

  /// Reset all tutorials (for testing or settings)
  static Future<void> resetAllTutorials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_entryTutorialKey);
    await prefs.remove(_scanTutorialKey);
    await prefs.remove(_recipeTutorialKey);
    await prefs.remove(_scanNavTutorialKey);
    await prefs.remove(_generateNavTutorialKey);
    await prefs.remove(_preferencesTutorialKey);
  }

  // ==========================================================================
  // SCAN NAV ICON TUTORIAL (shown when entering scan screen)
  // ==========================================================================

  /// Show tutorial for the Scan navigation icon (camera access tip)
  /// This is shown when user navigates to scan screen
  static void showScanNavTutorial({
    required BuildContext context,
    required GlobalKey scanNavKey,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    final List<TargetFocus> targets = [
      _createTarget(
        identify: 'scan_nav_camera',
        keyTarget: scanNavKey,
        shape: ShapeLightFocus.Circle,
        contents: [
          _buildContent(
            colorScheme: colorScheme,
            align: ContentAlign.top,
            title: '📷 Quick Camera Access',
            description:
                'Tap this Scan icon again to\nopen the camera directly!\n\nPerfect for quickly capturing\nyour ingredients.',
            stepNumber: 1,
            totalSteps: 1,
          ),
        ],
      ),
    ];

    _showTutorial(
      context: context,
      targets: targets,
      colorScheme: colorScheme,
      onFinish: () => markScanNavTutorialShown(),
      onSkip: () {
        markScanNavTutorialShown();
        return true;
      },
    );
  }

  // ==========================================================================
  // GENERATE NAV ICON TUTORIAL (shown after adding ingredients)
  // ==========================================================================

  /// Show tutorial for the Generate navigation icon
  /// This is shown after user adds their first ingredient
  static void showGenerateNavTutorial({
    required BuildContext context,
    required GlobalKey recipesNavKey,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    final List<TargetFocus> targets = [
      _createTarget(
        identify: 'generate_nav',
        keyTarget: recipesNavKey,
        shape: ShapeLightFocus.Circle,
        contents: [
          _buildContent(
            colorScheme: colorScheme,
            align: ContentAlign.top,
            title: '✨ Ready to Generate!',
            description:
                'Your ingredients are added!\n\nTap this icon to open recipe\npreferences and generate\na delicious AI-powered recipe.',
            stepNumber: 1,
            totalSteps: 1,
          ),
        ],
      ),
    ];

    _showTutorial(
      context: context,
      targets: targets,
      colorScheme: colorScheme,
      onFinish: () => markGenerateNavTutorialShown(),
      onSkip: () {
        markGenerateNavTutorialShown();
        return true;
      },
    );
  }

  // ==========================================================================
  // PREFERENCES BOTTOM SHEET TUTORIAL
  // ==========================================================================

  /// Show the preferences bottom sheet tutorial
  /// Targets: AI Model, Cuisine, Dietary, Nutrition button, Generate button
  static void showPreferencesTutorial({
    required BuildContext context,
    required GlobalKey aiModelKey,
    required GlobalKey cuisineKey,
    required GlobalKey dietaryKey,
    required GlobalKey nutritionButtonKey,
    required GlobalKey generateButtonKey,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    const totalSteps = 5;

    final List<TargetFocus> targets = [
      // Target 1: AI Model Selection
      _createTarget(
        identify: 'pref_ai_model',
        keyTarget: aiModelKey,
        shape: ShapeLightFocus.RRect,
        radius: AppSizes.radiusMd,
        contents: [
          _buildContent(
            colorScheme: colorScheme,
            align: ContentAlign.bottom,
            title: '🤖 Choose AI Model',
            description:
                'Select which AI will create your recipe.\n\nOpenAI provides creative recipes,\nGemini offers unique alternatives.',
            stepNumber: 1,
            totalSteps: totalSteps,
          ),
        ],
      ),

      // Target 2: Cuisine Type
      _createTarget(
        identify: 'pref_cuisine',
        keyTarget: cuisineKey,
        shape: ShapeLightFocus.RRect,
        radius: AppSizes.radiusMd,
        contents: [
          _buildContent(
            colorScheme: colorScheme,
            align: ContentAlign.bottom,
            title: '🍽️ Select Cuisine',
            description:
                'Pick your preferred cuisine style!\n\nFrom Italian to Japanese,\nchoose what you\'re craving today.',
            stepNumber: 2,
            totalSteps: totalSteps,
          ),
        ],
      ),

      // Target 3: Dietary Preferences
      _createTarget(
        identify: 'pref_dietary',
        keyTarget: dietaryKey,
        shape: ShapeLightFocus.RRect,
        radius: AppSizes.radiusMd,
        contents: [
          _buildContent(
            colorScheme: colorScheme,
            align: ContentAlign.top,
            title: '🥗 Dietary Needs',
            description:
                'Set your dietary preferences.\n\nVegetarian, Vegan, Keto, and more!\nWe\'ll tailor recipes just for you.',
            stepNumber: 3,
            totalSteps: totalSteps,
          ),
        ],
      ),

      // Target 4: Nutrition Info Button
      _createTarget(
        identify: 'pref_nutrition',
        keyTarget: nutritionButtonKey,
        shape: ShapeLightFocus.RRect,
        radius: AppSizes.radiusMd,
        contents: [
          _buildContent(
            colorScheme: colorScheme,
            align: ContentAlign.top,
            title: '📊 Nutrition Info',
            description:
                'Tap here to analyze your ingredients.\n\nGet detailed nutritional breakdown\nwithout generating a recipe.',
            stepNumber: 4,
            totalSteps: totalSteps,
          ),
        ],
      ),

      // Target 5: Generate Recipe Button
      _createTarget(
        identify: 'pref_generate',
        keyTarget: generateButtonKey,
        shape: ShapeLightFocus.RRect,
        radius: AppSizes.radiusMd,
        contents: [
          _buildContent(
            colorScheme: colorScheme,
            align: ContentAlign.top,
            title: '✨ Generate Recipe',
            description:
                'Ready to cook? Tap here!\n\nAI will create a delicious recipe\nusing your ingredients and preferences.',
            stepNumber: 5,
            totalSteps: totalSteps,
          ),
        ],
      ),
    ];

    _showTutorial(
      context: context,
      targets: targets,
      colorScheme: colorScheme,
      onFinish: () => markPreferencesTutorialShown(),
      onSkip: () {
        markPreferencesTutorialShown();
        return true;
      },
    );
  }

  // ==========================================================================
  // ENTRY SCREEN TUTORIAL
  // ==========================================================================

  /// Show the entry screen tutorial
  /// Targets: Input field, Add button, Category suggestions, Generate button
  static void showEntryTutorial({
    required BuildContext context,
    required GlobalKey inputKey,
    required GlobalKey addButtonKey,
    required GlobalKey categorySuggestionsKey,
    required GlobalKey? generateButtonKey,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final totalSteps = generateButtonKey != null ? 4 : 3;

    final List<TargetFocus> targets = [
      // Target 1: Input Field
      _createTarget(
        identify: 'entry_input',
        keyTarget: inputKey,
        shape: ShapeLightFocus.RRect,
        radius: AppSizes.radiusXxxl,
        contents: [
          _buildContent(
            colorScheme: colorScheme,
            align: ContentAlign.bottom,
            title: '🍳 Add Your Ingredients',
            description:
                'Type any ingredient you have in your kitchen.\nInclude quantities for better results!\n\nExample: "2 eggs", "chicken breast", "tomatoes"',
            stepNumber: 1,
            totalSteps: totalSteps,
          ),
        ],
      ),

      // Target 2: Add Button
      _createTarget(
        identify: 'entry_add_button',
        keyTarget: addButtonKey,
        shape: ShapeLightFocus.Circle,
        contents: [
          _buildContent(
            colorScheme: colorScheme,
            align: ContentAlign.bottom,
            title: '➕ Tap to Add',
            description:
                'After typing an ingredient,\ntap this button or press Enter\nto add it to your list.\n\nAdd as many ingredients as you like!',
            stepNumber: 2,
            totalSteps: totalSteps,
          ),
        ],
      ),

      // Target 3: Category Suggestions
      _createTarget(
        identify: 'entry_categories',
        keyTarget: categorySuggestionsKey,
        shape: ShapeLightFocus.RRect,
        radius: AppSizes.radiusXl,
        contents: [
          _buildContent(
            colorScheme: colorScheme,
            align: ContentAlign.top,
            title: '🥗 Quick Add Categories',
            description:
                'Browse common ingredient categories.\nTap any ingredient to add it to your list.\n\nTap again to remove it!',
            stepNumber: 3,
            totalSteps: totalSteps,
          ),
        ],
      ),
    ];

    // Add generate button target if available
    if (generateButtonKey != null) {
      targets.add(
        _createTarget(
          identify: 'entry_generate',
          keyTarget: generateButtonKey,
          shape: ShapeLightFocus.RRect,
          radius: AppSizes.radiusXxxl,
          contents: [
            _buildContent(
              colorScheme: colorScheme,
              align: ContentAlign.top,
              title: '✨ Generate Recipe',
              description:
                  'Once you\'ve added ingredients,\ntap here to open recipe preferences.\n\nCustomize cuisine, dietary needs,\nand let AI create the perfect recipe!',
              stepNumber: 4,
              totalSteps: totalSteps,
            ),
          ],
        ),
      );
    }

    _showTutorial(
      context: context,
      targets: targets,
      colorScheme: colorScheme,
      onFinish: () => markEntryTutorialShown(),
      onSkip: () {
        markEntryTutorialShown();
        return true;
      },
    );
  }

  // ==========================================================================
  // SCAN SCREEN TUTORIAL
  // ==========================================================================

  /// Show the scan screen tutorial
  /// Targets: Image picker area, Tips button, Proceed button, Scan Nav Icon
  static void showScanTutorial({
    required BuildContext context,
    required GlobalKey imagePickerKey,
    required GlobalKey tipButtonKey,
    required GlobalKey proceedButtonKey,
    GlobalKey? scanNavKey,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final totalSteps = scanNavKey != null ? 4 : 3;

    final List<TargetFocus> targets = [
      // Target 1: Image Picker Area
      _createTarget(
        identify: 'scan_picker',
        keyTarget: imagePickerKey,
        shape: ShapeLightFocus.RRect,
        radius: AppSizes.radiusXl,
        contents: [
          _buildContent(
            colorScheme: colorScheme,
            align: ContentAlign.bottom,
            title: '📸 Select from Gallery',
            description:
                'Tap here to choose an image\nof your ingredients from gallery.',
            stepNumber: 1,
            totalSteps: totalSteps,
          ),
        ],
      ),

      // Target 2: Tips Button
      _createTarget(
        identify: 'scan_tips',
        keyTarget: tipButtonKey,
        shape: ShapeLightFocus.Circle,
        contents: [
          _buildContent(
            colorScheme: colorScheme,
            align: ContentAlign.bottom,
            title: '💡 Helpful Tips',
            description:
                'Get tips for best results!\n\nGood lighting and clear frames\nhelp our AI detect ingredients better.',
            stepNumber: 2,
            totalSteps: totalSteps,
          ),
        ],
      ),

      // Target 3: Proceed Button
      _createTarget(
        identify: 'scan_proceed',
        keyTarget: proceedButtonKey,
        shape: ShapeLightFocus.RRect,
        radius: AppSizes.radiusXxxl,
        contents: [
          _buildContent(
            colorScheme: colorScheme,
            align: ContentAlign.top,
            title: '🚀 Generate Recipe',
            description:
                'After selecting an image,\ntap here to start the magic!\n\nAI will analyze your ingredients\nand create a delicious recipe.',
            stepNumber: 3,
            totalSteps: totalSteps,
          ),
        ],
      ),
    ];

    // Target 4: Scan Nav Icon for Camera Access
    if (scanNavKey != null) {
      targets.add(
        _createTarget(
          identify: 'scan_nav_camera',
          keyTarget: scanNavKey,
          shape: ShapeLightFocus.Circle,
          contents: [
            _buildContent(
              colorScheme: colorScheme,
              align: ContentAlign.top,
              title: '📷 Quick Camera Access',
              description:
                  'Pro tip: Tap this Scan icon again\nto open the camera directly!\n\nPerfect for quickly capturing\nyour ingredients.',
              stepNumber: 4,
              totalSteps: totalSteps,
            ),
          ],
        ),
      );
    }

    _showTutorial(
      context: context,
      targets: targets,
      colorScheme: colorScheme,
      onFinish: () {
        markScanTutorialShown();
        if (scanNavKey != null) markScanNavTutorialShown();
      },
      onSkip: () {
        markScanTutorialShown();
        if (scanNavKey != null) markScanNavTutorialShown();
        return true;
      },
    );
  }

  // ==========================================================================
  // RECIPE RESULT SCREEN TUTORIAL
  // ==========================================================================

  /// Show the recipe result screen tutorial
  /// Targets: Recipe image, Info badges, Tabs, Save, Regenerate buttons
  static void showRecipeTutorial({
    required BuildContext context,
    required GlobalKey recipeImageKey,
    required GlobalKey infoBadgesKey,
    required GlobalKey ingredientsTabKey,
    required GlobalKey stepsTabKey,
    required GlobalKey nutritionTabKey,
    required GlobalKey saveButtonKey,
    required GlobalKey regenerateButtonKey,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    const totalSteps = 7;

    final List<TargetFocus> targets = [
      // Target 1: Recipe Image
      _createTarget(
        identify: 'recipe_image',
        keyTarget: recipeImageKey,
        shape: ShapeLightFocus.RRect,
        radius: AppSizes.radiusXl,
        contents: [
          _buildContent(
            colorScheme: colorScheme,
            align: ContentAlign.bottom,
            title: '🍽️ Your AI-Generated Recipe',
            description:
                'Here\'s the beautiful dish our AI created!\n\nThe image is generated to match\nyour personalized recipe.',
            stepNumber: 1,
            totalSteps: totalSteps,
          ),
        ],
      ),

      // Target 2: Info Badges
      _createTarget(
        identify: 'recipe_info',
        keyTarget: infoBadgesKey,
        shape: ShapeLightFocus.RRect,
        radius: AppSizes.radiusMd,
        contents: [
          _buildContent(
            colorScheme: colorScheme,
            align: ContentAlign.bottom,
            title: '⏱️ Quick Info',
            description:
                'View preparation time, cooking time,\nserving size, and difficulty level.\n\nPlan your cooking session easily!',
            stepNumber: 2,
            totalSteps: totalSteps,
          ),
        ],
      ),

      // Target 3: Ingredients Tab
      _createTarget(
        identify: 'recipe_ingredients_tab',
        keyTarget: ingredientsTabKey,
        shape: ShapeLightFocus.RRect,
        radius: AppSizes.radiusSm,
        contents: [
          _buildContent(
            colorScheme: colorScheme,
            align: ContentAlign.top,
            title: '🥕 Ingredients Tab',
            description:
                'View all ingredients with quantities.\n\nPerfect for creating your shopping list\nor checking what you already have!',
            stepNumber: 3,
            totalSteps: totalSteps,
          ),
        ],
      ),

      // Target 4: Steps Tab
      _createTarget(
        identify: 'recipe_steps_tab',
        keyTarget: stepsTabKey,
        shape: ShapeLightFocus.RRect,
        radius: AppSizes.radiusSm,
        contents: [
          _buildContent(
            colorScheme: colorScheme,
            align: ContentAlign.top,
            title: '📝 Instructions Tab',
            description:
                'Follow step-by-step cooking instructions.\n\nEach step is clearly explained\nto help you cook with confidence!',
            stepNumber: 4,
            totalSteps: totalSteps,
          ),
        ],
      ),

      // Target 5: Nutrition Tab
      _createTarget(
        identify: 'recipe_nutrition_tab',
        keyTarget: nutritionTabKey,
        shape: ShapeLightFocus.RRect,
        radius: AppSizes.radiusSm,
        contents: [
          _buildContent(
            colorScheme: colorScheme,
            align: ContentAlign.top,
            title: '📊 Nutrition Info Tab',
            description:
                'Check detailed nutritional information.\n\nCalories, protein, carbs, fats,\nand more per serving!',
            stepNumber: 5,
            totalSteps: totalSteps,
          ),
        ],
      ),

      // Target 6: Save Button
      _createTarget(
        identify: 'recipe_save',
        keyTarget: saveButtonKey,
        shape: ShapeLightFocus.Circle,
        contents: [
          _buildContent(
            colorScheme: colorScheme,
            align: ContentAlign.bottom,
            title: '💾 Save Recipe',
            description:
                'Love this recipe? Save it!\n\nAccess your favorites anytime\nfrom the Saved tab.',
            stepNumber: 6,
            totalSteps: totalSteps,
          ),
        ],
      ),

      // Target 7: Regenerate Button
      _createTarget(
        identify: 'recipe_regenerate',
        keyTarget: regenerateButtonKey,
        shape: ShapeLightFocus.RRect,
        radius: AppSizes.radiusXxxl,
        contents: [
          _buildContent(
            colorScheme: colorScheme,
            align: ContentAlign.top,
            title: '🔄 Try Again',
            description:
                'Not satisfied? No problem!\n\nTap to generate a completely\nnew recipe with the same ingredients.',
            stepNumber: 7,
            totalSteps: totalSteps,
          ),
        ],
      ),
    ];

    _showTutorial(
      context: context,
      targets: targets,
      colorScheme: colorScheme,
      onFinish: () => markRecipeTutorialShown(),
      onSkip: () {
        markRecipeTutorialShown();
        return true;
      },
    );
  }

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================

  /// Create a TargetFocus with common settings
  static TargetFocus _createTarget({
    required String identify,
    required GlobalKey keyTarget,
    required ShapeLightFocus shape,
    double radius = 8.0,
    required List<TargetContent> contents,
  }) {
    return TargetFocus(
      identify: identify,
      keyTarget: keyTarget,
      shape: shape,
      radius: radius,
      enableOverlayTab: true,
      enableTargetTab: true,
      paddingFocus: 8,
      focusAnimationDuration: const Duration(milliseconds: 400),
      unFocusAnimationDuration: const Duration(milliseconds: 400),
      pulseVariation: Tween(begin: 1.0, end: 0.96),
      contents: contents,
    );
  }

  /// Build content for a tutorial target with step tracking
  static TargetContent _buildContent({
    required ColorScheme colorScheme,
    required ContentAlign align,
    required String title,
    required String description,
    required int stepNumber,
    required int totalSteps,
  }) {
    return TargetContent(
      align: align,
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingLg,
        vertical: AppSizes.vPaddingMd,
      ),
      builder: (context, controller) {
        return _TutorialContentWidget(
          title: title,
          description: description,
          colorScheme: colorScheme,
          currentStep: stepNumber,
          totalSteps: totalSteps,
          onNext: () => controller.next(),
          onPrevious: stepNumber > 1 ? () => controller.previous() : null,
          onSkip: () => controller.skip(),
          isLast: stepNumber == totalSteps,
        );
      },
    );
  }

  /// Show the tutorial with common configuration
  static void _showTutorial({
    required BuildContext context,
    required List<TargetFocus> targets,
    required ColorScheme colorScheme,
    required VoidCallback onFinish,
    required bool Function() onSkip,
  }) {
    TutorialCoachMark(
      targets: targets,
      colorShadow: colorScheme.scrim,
      opacityShadow: 0.85,
      textSkip: '',
      hideSkip: true,
      paddingFocus: 10,
      focusAnimationDuration: const Duration(milliseconds: 400),
      unFocusAnimationDuration: const Duration(milliseconds: 400),
      pulseAnimationDuration: const Duration(milliseconds: 800),
      pulseEnable: true,
      onFinish: onFinish,
      onSkip: onSkip,
    ).show(context: context);
  }
}

// =============================================================================
// TUTORIAL CONTENT WIDGET
// =============================================================================

/// Beautiful, minimal tutorial content widget
class _TutorialContentWidget extends StatelessWidget {
  final String title;
  final String description;
  final ColorScheme colorScheme;
  final int currentStep;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback? onPrevious;
  final VoidCallback onSkip;
  final bool isLast;

  const _TutorialContentWidget({
    required this.title,
    required this.description,
    required this.colorScheme,
    required this.currentStep,
    required this.totalSteps,
    required this.onNext,
    this.onPrevious,
    required this.onSkip,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 320.w),
      padding: EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title + Skip Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                    height: 1.3,
                  ),
                ),
              ),
              SizedBox(width: AppSizes.spaceSm),
              // Skip Button (top right)
              GestureDetector(
                onTap: onSkip,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingSm,
                    vertical: AppSizes.vPaddingXs,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.spaceHeightSm),

          // Description
          Text(
            description,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
          SizedBox(height: AppSizes.spaceHeightLg),

          // Footer: Back Button | Step Counter | Next/Got it Button
          Row(
            children: [
              // Previous button (if not first step)
              if (onPrevious != null)
                GestureDetector(
                  onTap: onPrevious,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingSm,
                      vertical: AppSizes.vPaddingXs,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: colorScheme.outline),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 16.sp,
                      color: colorScheme.onSurface,
                    ),
                  ),
                )
              else
                SizedBox(width: 36.w), // Placeholder for alignment
              // Step counter (center)
              Expanded(
                child: Center(
                  child: Text(
                    '$currentStep of $totalSteps',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Next/Finish button
              GestureDetector(
                onTap: onNext,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMd,
                    vertical: AppSizes.vPaddingXs,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withValues(alpha: 0.85),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isLast ? 'Got it!' : 'Next',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        isLast
                            ? Icons.check_rounded
                            : Icons.arrow_forward_ios_rounded,
                        size: 14.sp,
                        color: colorScheme.onPrimary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
