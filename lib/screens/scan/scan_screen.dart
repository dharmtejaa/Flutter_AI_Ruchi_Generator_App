import 'dart:io';
import 'dart:ui';
import 'package:ai_ruchi/core/services/image_recipe_api_service.dart';
import 'package:ai_ruchi/core/theme/app_shadows.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/models/image_recipe_response.dart';
import 'package:ai_ruchi/providers/recipe_provider.dart';
import 'package:ai_ruchi/screens/scan/widgets/modern_source_button.dart';
import 'package:ai_ruchi/shared/widgets/common/custom_snackbar.dart';
import 'package:ai_ruchi/shared/widgets/recipe/recipe_preferences_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();

  // Header animation (slides from top like entry screen)
  late AnimationController _headerAnimationController;
  late Animation<double> _headerAnimation;

  // Content animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  File? _selectedImage;
  bool _isLoading = false;
  List<String>? _extractedIngredients;

  // Loading and error states
  String _loadingMessage = 'Generating Recipe...';
  String? _errorMessage;
  bool _showError = false;

  @override
  void initState() {
    super.initState();

    // Header animation setup (slides from top)
    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOut,
    );
    _headerAnimationController.forward();

    // Content animation setup
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _animationController.dispose();
    super.dispose();
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
          _showError = false;
          _errorMessage = null;
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

    // Show preferences dialog first
    final shouldGenerate = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const RecipePreferencesDialog(),
      ),
    );

    if (shouldGenerate != true || !mounted) return;

    // Get preferences from provider
    final recipeProvider = context.read<RecipeProvider>();

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Analyzing image...';
      _showError = false;
      _errorMessage = null;
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

        setState(() {
          _showError = true;
          _errorMessage = errorMessage;
        });
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
      _showError = false;
      _errorMessage = null;
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
      _showError = false;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animated Premium Header Section (slides from top like entry screen)
            FadeTransition(
              opacity: _headerAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.3),
                  end: Offset.zero,
                ).animate(_headerAnimation),
                child: _buildPremiumHeader(textTheme, colorScheme),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: AppSizes.spaceHeightLg),

                      // Image Picker Section
                      _buildModernImagePicker(colorScheme, textTheme),
                      SizedBox(height: AppSizes.spaceHeightLg),

                      // Error State with Retry and Demo buttons
                      if (_showError && _errorMessage != null)
                        _buildErrorSection(colorScheme, textTheme),

                      // Extracted Ingredients (if available)
                      if (_extractedIngredients != null &&
                          _extractedIngredients!.isNotEmpty)
                        _buildExtractedIngredients(colorScheme, textTheme),

                      // Generate Button
                      _buildPremiumGenerateButton(colorScheme, textTheme),
                      SizedBox(height: AppSizes.spaceHeightXl),

                      // Tips Section
                      _buildTipsSection(colorScheme, textTheme),
                      SizedBox(height: AppSizes.spaceHeightXl),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(TextTheme textTheme, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMd,
        vertical: AppSizes.vPaddingLg,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.radiusXxxl),
          bottomRight: Radius.circular(AppSizes.radiusXxxl),
        ),
        boxShadow: AppShadows.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.paddingSm),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Icon(
                  Icons.qr_code_scanner_outlined,
                  color: colorScheme.onPrimary,
                  size: AppSizes.iconMd,
                ),
              ),
              SizedBox(width: AppSizes.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Scan Ingredients', style: textTheme.headlineSmall),
                    SizedBox(height: AppSizes.spaceHeightXs),
                    Text(
                      'Capture your ingredients and let AI create magic',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernImagePicker(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: AppShadows.cardShadow(context),
      ),
      child: Column(
        children: [
          // Image Preview or Placeholder
          GestureDetector(
            onTap: () => _pickImage(ImageSource.gallery),
            child: Container(
              height: 220.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSizes.radiusXl),
                ),
              ),
              child: _selectedImage != null
                  ? _buildImagePreview(colorScheme)
                  : _buildEmptyImageState(colorScheme, textTheme),
            ),
          ),

          // Image Source Buttons
          Container(
            padding: EdgeInsets.all(AppSizes.paddingMd),
            child: Row(
              children: [
                Expanded(
                  child: ModernSourceButton(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    onTap: () => _pickImage(ImageSource.camera),
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    isPrimary: true,
                  ),
                ),
                SizedBox(width: AppSizes.spaceMd),
                Expanded(
                  child: ModernSourceButton(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: () => _pickImage(ImageSource.gallery),
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    isPrimary: false,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(ColorScheme colorScheme) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusXxl),
          ),
          child: Image.file(_selectedImage!, fit: BoxFit.cover),
        ),
        // Gradient overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 80.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
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
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white,
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
                      color: Colors.white,
                      size: AppSizes.iconXs,
                    ),
                    SizedBox(width: AppSizes.spaceXs),
                    Text(
                      'Ready to scan',
                      style: TextStyle(
                        color: Colors.white,
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(AppSizes.paddingLg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary.withValues(alpha: 0.1),
                colorScheme.secondary.withValues(alpha: 0.1),
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.add_photo_alternate_rounded,
            color: colorScheme.primary,
            size: AppSizes.iconXl,
          ),
        ),
        SizedBox(height: AppSizes.spaceHeightMd),
        Text(
          'Add Your Ingredients Photo',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: AppSizes.spaceHeightXs),
        Text(
          'Tap to capture or select an image',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: AppSizes.spaceHeightXs),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingSm,
            vertical: AppSizes.vPaddingXs,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppSizes.radiusXxxl),
          ),
          child: Text(
            'JPG, PNG • Max 10MB',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExtractedIngredients(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.spaceHeightLg),
      padding: EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.5),
            colorScheme.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: AppShadows.cardShadow(context),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.paddingXs),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.secondary],
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(
                  Icons.restaurant_menu_rounded,
                  color: Colors.white,
                  size: AppSizes.iconSm,
                ),
              ),
              SizedBox(width: AppSizes.spaceSm),
              Text(
                'Detected Ingredients',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingXs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Text(
                  '${_extractedIngredients!.length} items',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.spaceHeightMd),
          Wrap(
            spacing: AppSizes.spaceSm,
            runSpacing: AppSizes.spaceHeightSm,
            children: _extractedIngredients!.map((ingredient) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingSm,
                  vertical: AppSizes.vPaddingXs,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: colorScheme.primary,
                        size: AppSizes.iconsUxs,
                      ),
                    ),
                    SizedBox(width: AppSizes.spaceXs),
                    Text(
                      ingredient,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumGenerateButton(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final bool isEnabled = _selectedImage != null && !_isLoading;

    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        gradient: isEnabled
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colorScheme.primary, colorScheme.secondary],
              )
            : null,
        color: isEnabled ? null : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: isEnabled ? _generateRecipe : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
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
                    'Generate Recipe',
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
      padding: EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: colorScheme.primary,
                size: AppSizes.iconSm,
              ),
              SizedBox(width: AppSizes.spaceSm),
              Text(
                'Tips for Best Results',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
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
          padding: EdgeInsets.all(AppSizes.paddingXs),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          child: Icon(icon, color: colorScheme.primary, size: AppSizes.iconXs),
        ),
        SizedBox(width: AppSizes.spaceSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                description,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build error section with retry and demo buttons
  Widget _buildErrorSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.spaceHeightLg),
      padding: EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Error header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.paddingXs),
                decoration: BoxDecoration(
                  color: colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: colorScheme.error,
                  size: AppSizes.iconSm,
                ),
              ),
              SizedBox(width: AppSizes.spaceSm),
              Expanded(
                child: Text(
                  'Something went wrong',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Close button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showError = false;
                    _errorMessage = null;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: colorScheme.error,
                    size: AppSizes.iconXs,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.spaceHeightSm),

          // Error message
          Text(
            _errorMessage ?? 'An unknown error occurred',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSizes.spaceHeightMd),

          // Action buttons
          Row(
            children: [
              // Retry button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _generateRecipe,
                  icon: Icon(Icons.refresh_rounded, size: AppSizes.iconSm),
                  label: Text('Retry'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(color: colorScheme.primary),
                    padding: EdgeInsets.symmetric(
                      vertical: AppSizes.vPaddingSm,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSizes.spaceMd),
              // Use Demo button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _useDemoData,
                  icon: Icon(Icons.science_rounded, size: AppSizes.iconSm),
                  label: Text('Try Demo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.secondary,
                    foregroundColor: colorScheme.onSecondary,
                    padding: EdgeInsets.symmetric(
                      vertical: AppSizes.vPaddingSm,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
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
