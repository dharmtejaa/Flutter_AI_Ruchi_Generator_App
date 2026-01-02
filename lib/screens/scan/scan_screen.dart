import 'dart:io';
import 'dart:ui';
import 'package:ai_ruchi/core/services/image_recipe_api_service.dart';
import 'package:ai_ruchi/core/theme/app_shadows.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/models/image_recipe_response.dart';
import 'package:ai_ruchi/providers/recipe_provider.dart';
import 'package:ai_ruchi/shared/widgets/common/custom_snackbar.dart';
import 'package:ai_ruchi/shared/widgets/recipe/recipe_preferences_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => ScanScreenState();
}

/// State class with public name so it can be accessed via GlobalKey
class ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();

  /// Public method to open camera - can be called from MainShellScreen
  /// when user re-taps the Scan tab
  void openCamera() {
    _pickImage(ImageSource.camera);
  }

  File? _selectedImage;
  bool _isLoading = false;
  List<String>? _extractedIngredients;

  // Loading state
  String _loadingMessage = 'Generating Recipe...';

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _extractedIngredients = null;
        });
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Failed to pick image: $e');
      }
    }
  }

  Future<void> _generateRecipe() async {
    if (_selectedImage == null) {
      CustomSnackBar.showWarning(context, 'Please select an image first');
      return;
    }

    // Show preferences bottom sheet first
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => RecipePreferencesBottomSheet(
        onGenerateRecipe: () => _processImageRecipe(),
      ),
    );
  }

  Future<void> _processImageRecipe() async {
    if (_selectedImage == null || !mounted) return;

    // Get preferences from provider
    final recipeProvider = context.read<RecipeProvider>();

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Analyzing image...';
    });

    try {
      final preferences = RecipePreferences(
        cuisine: recipeProvider.selectedCuisine,
        dietary: recipeProvider.selectedDietary,
      );

      final response = await ImageRecipeApiService.generateRecipeFromImage(
        imageFile: _selectedImage!,
        provider: recipeProvider.selectedProvider,
        preferences: preferences,
        onRetry: (attempt, maxAttempts) {
          if (mounted) {
            setState(() {
              _loadingMessage =
                  'Retrying... (Attempt $attempt of $maxAttempts)';
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _extractedIngredients = response.extractedIngredients;
        });

        // Update recipe provider
        context.read<RecipeProvider>().setRecipe(response.recipe);

        // Navigate to recipe screen
        context.push('/recipe');
      }
    } catch (e) {
      if (mounted) {
        // Clean up the error message
        String errorMessage = e.toString();
        // Remove all "Exception: " prefixes
        while (errorMessage.contains('Exception: ')) {
          errorMessage = errorMessage.replaceAll('Exception: ', '');
        }
        errorMessage = errorMessage.trim();

        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        _showErrorDialog(errorMessage, colorScheme, textTheme);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMessage = 'Generating Recipe...';
        });
      }
    }
  }

  /// Use demo/mock data for testing
  void _useDemoData() {
    final demoResponse = ImageRecipeApiService.getMockResponse();

    setState(() {
      _extractedIngredients = demoResponse.extractedIngredients;
    });

    // Update recipe provider with demo data
    context.read<RecipeProvider>().setRecipe(demoResponse.recipe);

    // Show info that demo data is being used
    CustomSnackBar.showInfo(context, 'Using demo recipe for preview');

    // Navigate to recipe screen
    context.push('/recipe');
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
      _extractedIngredients = null;
    });
  }

  void _showTipsDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(AppSizes.paddingMd),
        child: _buildTipsSection(colorScheme, textTheme),
      ),
    );
  }

  void _showErrorDialog(
    String message,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(AppSizes.paddingLg),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Error Icon with gradient background
              Container(
                width: 64.w,
                height: 64.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.error.withValues(alpha: 0.15),
                      colorScheme.error.withValues(alpha: 0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: colorScheme.error,
                  size: 32.sp,
                ),
              ),
              SizedBox(height: AppSizes.spaceHeightMd),

              // Title
              Text(
                'Oops! Something went wrong',
                style: textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSizes.spaceHeightXs),

              // Message
              Text(
                message,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: AppSizes.spaceHeightLg),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44.h,
                      decoration: BoxDecoration(
                        border: Border.all(color: colorScheme.outline),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          _generateRecipe();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.onSurface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMd,
                            ),
                          ),
                        ),
                        child: Text(
                          'Retry',
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSizes.spaceSm),
                  Expanded(
                    child: Container(
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          _useDemoData();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMd,
                            ),
                          ),
                        ),
                        child: Text(
                          'Try Demo',
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - AppSizes.paddingMd * 2,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Scan Ingredients',
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          onPressed: _showTipsDialog,
                          icon: Icon(Icons.info_outline_rounded),
                          color: colorScheme.primary,
                        ),
                      ],
                    ),
                    Text(
                      'Capture your ingredients and let AI create magic',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: AppSizes.spaceHeightXl),
                    // Centered Content (Image + Button or Error)
                    _buildModernImagePicker(colorScheme, textTheme),
                    SizedBox(height: AppSizes.spaceHeightLg),

                    // Extracted Ingredients (if available)
                    if (_extractedIngredients != null &&
                        _extractedIngredients!.isNotEmpty)
                      _buildExtractedIngredients(colorScheme, textTheme),

                    // Generate Button
                    _buildPremiumGenerateButton(colorScheme, textTheme),
                    SizedBox(height: AppSizes.spaceHeightLg),

                    // Bottom spacer for balance
                    SizedBox(height: AppSizes.spaceHeightXl),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildModernImagePicker(ColorScheme colorScheme, TextTheme textTheme) {
    return GestureDetector(
      onTap: () => _pickImage(ImageSource.gallery),
      child: Container(
        height: 350.h, // Increased height since buttons are removed
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        ),
        child: _selectedImage != null
            ? _buildImagePreview(colorScheme)
            : _buildEmptyImageState(colorScheme, textTheme),
      ),
    );
  }

  Widget _buildImagePreview(ColorScheme colorScheme) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          child: Image.file(_selectedImage!, fit: BoxFit.contain),
        ),
        // Gradient overlay with rounded bottom corners
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 55.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(AppSizes.radiusXl),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
        ),
        // Remove button with glassmorphism
        Positioned(
          top: AppSizes.paddingSm,
          right: AppSizes.paddingSm,
          child: GestureDetector(
            onTap: _clearImage,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.all(AppSizes.paddingXs),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.onPrimary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: colorScheme.onPrimary,
                    size: AppSizes.iconSm,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Success indicator
        Positioned(
          bottom: AppSizes.paddingSm,
          left: AppSizes.paddingSm,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusXxxl),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingSm,
                  vertical: AppSizes.vPaddingXs,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(AppSizes.radiusXxxl),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: colorScheme.onPrimary,
                      size: AppSizes.iconXs,
                    ),
                    SizedBox(width: AppSizes.spaceXs),
                    Text(
                      'Ready',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyImageState(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          color: colorScheme.primary,
          size: AppSizes.iconXl,
        ),

        SizedBox(height: AppSizes.spaceHeightMd),
        Text('Tap here to choose from gallery', style: textTheme.bodyMedium),
        SizedBox(height: AppSizes.spaceHeightSm),
        Text(
          'JPG, PNG • Max 10MB',
          style: textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 100.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_scanner,
              size: AppSizes.iconXs,
              color: colorScheme.primary,
            ),
            SizedBox(width: AppSizes.spaceSm),
            Text(
              'Tap scan icon again for camera',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.spaceHeightSm),
      ],
    );
  }

  Widget _buildExtractedIngredients(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Simple header
        Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: AppSizes.iconSm,
            ),
            SizedBox(width: AppSizes.spaceXs),
            Text(
              'Detected ${_extractedIngredients!.length} ingredients',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.spaceHeightSm),

        // Simple ingredient chips
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _extractedIngredients!.map((ingredient) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Text(
                ingredient,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: AppSizes.spaceHeightMd),
      ],
    );
  }

  Widget _buildPremiumGenerateButton(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final bool isEnabled = _selectedImage != null && !_isLoading;
    final bool showPrimaryStyle = isEnabled || _isLoading;

    return Container(
      width: double.infinity,
      height: 45.h,
      decoration: BoxDecoration(
        color: showPrimaryStyle
            ? colorScheme.primary
            : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSizes.radiusXxxl),
        boxShadow: showPrimaryStyle ? AppShadows.buttonShadow(context) : null,
      ),
      child: ElevatedButton(
        onPressed: isEnabled ? _generateRecipe : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusXxxl),
          ),
          padding: EdgeInsets.zero,
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24.w,
                    height: 24.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  SizedBox(width: AppSizes.spaceMd),
                  Flexible(
                    child: Text(
                      _loadingMessage,
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome_rounded, size: AppSizes.iconMd),
                  SizedBox(width: AppSizes.spaceSm),
                  Text(
                    'Proceed',
                    style: textTheme.titleMedium?.copyWith(
                      color: _selectedImage != null
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTipsSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      height: 220.h,
      padding: EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: colorScheme.primary,
                size: AppSizes.iconMd,
              ),
              SizedBox(width: AppSizes.spaceSm),
              Text(
                'Tips for Best Results',
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.close,
                  size: AppSizes.iconMd,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.spaceHeightMd),
          _buildTipItem(
            colorScheme,
            textTheme,
            Icons.wb_sunny_rounded,
            'Good Lighting',
            'Ensure proper lighting for clear visibility',
          ),
          SizedBox(height: AppSizes.spaceHeightSm),
          _buildTipItem(
            colorScheme,
            textTheme,
            Icons.crop_free_rounded,
            'Clear Frame',
            'Include all ingredients in the frame',
          ),
          SizedBox(height: AppSizes.spaceHeightSm),
          _buildTipItem(
            colorScheme,
            textTheme,
            Icons.layers_rounded,
            'Separate Items',
            'Spread ingredients for better detection',
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(
    ColorScheme colorScheme,
    TextTheme textTheme,
    IconData icon,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(AppSizes.paddingSm),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          child: Icon(icon, color: colorScheme.primary, size: AppSizes.iconSm),
        ),
        SizedBox(width: AppSizes.spaceMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                description,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
