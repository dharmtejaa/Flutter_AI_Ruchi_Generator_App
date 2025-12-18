import 'dart:io';
import 'package:ai_ruchi/core/services/image_recipe_api_service.dart';
import 'package:ai_ruchi/core/theme/app_shadows.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/models/image_recipe_response.dart';
import 'package:ai_ruchi/providers/recipe_provider.dart';
import 'package:ai_ruchi/shared/widgets/common/custom_snackbar.dart';
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

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  bool _isLoading = false;
  String _selectedProvider = 'gemini';
  String _selectedCuisine = 'Any';
  String _selectedDietary = 'none';
  List<String>? _extractedIngredients;

  // Loading and error states
  String _loadingMessage = 'Generating Recipe...';
  String? _errorMessage;
  bool _showError = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
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

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Analyzing image...';
      _showError = false;
      _errorMessage = null;
    });

    try {
      final preferences = RecipePreferences(
        cuisine: _selectedCuisine,
        dietary: _selectedDietary,
      );

      final response = await ImageRecipeApiService.generateRecipeFromImage(
        imageFile: _selectedImage!,
        provider: _selectedProvider,
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
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: child,
            ),
          );
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSizes.spaceHeightMd),

                // Header
                _buildHeader(textTheme, colorScheme),
                SizedBox(height: AppSizes.spaceHeightLg),

                // Image Picker Section
                _buildImagePicker(colorScheme, textTheme),
                SizedBox(height: AppSizes.spaceHeightLg),

                // Preferences Section
                _buildPreferencesSection(colorScheme, textTheme),
                SizedBox(height: AppSizes.spaceHeightLg),

                // Error State with Retry and Demo buttons
                if (_showError && _errorMessage != null)
                  _buildErrorSection(colorScheme, textTheme),

                // Extracted Ingredients (if available)
                if (_extractedIngredients != null &&
                    _extractedIngredients!.isNotEmpty)
                  _buildExtractedIngredients(colorScheme, textTheme),

                // Generate Button
                _buildGenerateButton(colorScheme, textTheme),
                SizedBox(height: AppSizes.spaceHeightXl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.paddingSm),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                boxShadow: AppShadows.cardShadow(context),
              ),
              child: Icon(
                Icons.document_scanner_rounded,
                color: colorScheme.onPrimary,
                size: AppSizes.iconLg,
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
                    'Take a photo of your ingredients',
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePicker(ColorScheme colorScheme, TextTheme textTheme) {
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
            onTap: () => _showImageSourceDialog(),
            child: Container(
              height: 220.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSizes.radiusXl),
                ),
              ),
              child: _selectedImage != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(AppSizes.radiusXl),
                          ),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        ),
                        // Overlay gradient
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 60.h,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.5),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Remove button
                        Positioned(
                          top: AppSizes.paddingSm,
                          right: AppSizes.paddingSm,
                          child: GestureDetector(
                            onTap: _clearImage,
                            child: Container(
                              padding: EdgeInsets.all(AppSizes.paddingXs),
                              decoration: BoxDecoration(
                                color: colorScheme.error,
                                shape: BoxShape.circle,
                                boxShadow: AppShadows.elevatedShadow(context),
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                color: colorScheme.onError,
                                size: AppSizes.iconSm,
                              ),
                            ),
                          ),
                        ),
                        // Image selected indicator
                        Positioned(
                          bottom: AppSizes.paddingSm,
                          left: AppSizes.paddingSm,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingSm,
                              vertical: AppSizes.vPaddingXs,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusMd,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: colorScheme.onPrimary,
                                  size: AppSizes.iconSm,
                                ),
                                SizedBox(width: AppSizes.spaceXs),
                                Text(
                                  'Image Ready',
                                  style: textTheme.labelMedium?.copyWith(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(AppSizes.paddingLg),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_photo_alternate_rounded,
                            color: colorScheme.primary,
                            size: AppSizes.iconXl,
                          ),
                        ),
                        SizedBox(height: AppSizes.spaceHeightMd),
                        Text('Tap to add image', style: textTheme.titleMedium),
                        SizedBox(height: AppSizes.spaceHeightXs),
                        Text(
                          'Supports JPG, PNG (max 10MB)',
                          style: textTheme.labelMedium,
                        ),
                      ],
                    ),
            ),
          ),

          // Image Source Buttons
          Padding(
            padding: EdgeInsets.all(AppSizes.paddingMd),
            child: Row(
              children: [
                Expanded(
                  child: _ImageSourceButton(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    onTap: () => _pickImage(ImageSource.camera),
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                ),
                SizedBox(width: AppSizes.spaceMd),
                Expanded(
                  child: _ImageSourceButton(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: () => _pickImage(ImageSource.gallery),
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: AppShadows.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.paddingXs),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: colorScheme.primary,
                  size: AppSizes.iconSm,
                ),
              ),
              SizedBox(width: AppSizes.spaceSm),
              Text('Preferences', style: textTheme.titleMedium),
            ],
          ),
          SizedBox(height: AppSizes.spaceHeightMd),

          // AI Provider Selection
          Text('AI Provider', style: textTheme.labelMedium),
          SizedBox(height: AppSizes.spaceHeightSm),
          Row(
            children: ImageRecipeApiService.providers.map((provider) {
              final isSelected = _selectedProvider == provider;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedProvider = provider),
                  child: Container(
                    margin: EdgeInsets.only(
                      right: provider != ImageRecipeApiService.providers.last
                          ? AppSizes.spaceSm
                          : 0,
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: AppSizes.vPaddingSm,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.outline,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          provider == 'openai'
                              ? Icons.smart_toy_rounded
                              : Icons.auto_awesome_rounded,
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                          size: AppSizes.iconSm,
                        ),
                        SizedBox(width: AppSizes.spaceXs),
                        Text(
                          provider.toUpperCase(),
                          style: textTheme.labelMedium?.copyWith(
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: AppSizes.spaceHeightMd),

          // Cuisine Selection
          Text('Cuisine', style: textTheme.labelMedium),
          SizedBox(height: AppSizes.spaceHeightSm),
          _buildDropdown(
            value: _selectedCuisine,
            items: ImageRecipeApiService.cuisines,
            onChanged: (value) => setState(() => _selectedCuisine = value!),
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          SizedBox(height: AppSizes.spaceHeightMd),

          // Dietary Selection
          Text('Dietary Preference', style: textTheme.labelMedium),
          SizedBox(height: AppSizes.spaceHeightSm),
          _buildDropdown(
            value: _selectedDietary,
            items: ImageRecipeApiService.dietaryOptions,
            onChanged: (value) => setState(() => _selectedDietary = value!),
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMd,
        vertical: AppSizes.vPaddingXs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: colorScheme.outline),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
          dropdownColor: colorScheme.surface,
          style: textTheme.bodyMedium,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item.replaceAll('-', ' ').toUpperCase(),
                style: textTheme.bodyMedium,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
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
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: AppShadows.cardShadow(context),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.paddingXs),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(
                  Icons.restaurant_menu_rounded,
                  color: colorScheme.primary,
                  size: AppSizes.iconSm,
                ),
              ),
              SizedBox(width: AppSizes.spaceSm),
              Text('Detected Ingredients', style: textTheme.titleMedium),
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
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: colorScheme.primary,
                      size: AppSizes.iconXs,
                    ),
                    SizedBox(width: AppSizes.spaceXs),
                    Text(
                      ingredient,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
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

  Widget _buildGenerateButton(ColorScheme colorScheme, TextTheme textTheme) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _generateRecipe,
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedImage != null
              ? colorScheme.primary
              : colorScheme.surfaceContainerHigh,
          foregroundColor: _selectedImage != null
              ? colorScheme.onPrimary
              : colorScheme.onSurfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          elevation: _selectedImage != null ? 2 : 0,
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

  /// Build error section with retry and demo buttons
  Widget _buildErrorSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.spaceHeightLg),
      padding: EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.3),
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
                child: Icon(
                  Icons.close_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: AppSizes.iconSm,
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

  void _showImageSourceDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(AppSizes.paddingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colorScheme.outline,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: AppSizes.spaceHeightLg),
              Text('Select Image Source', style: textTheme.titleLarge),
              SizedBox(height: AppSizes.spaceHeightLg),
              Row(
                children: [
                  Expanded(
                    child: _ImageSourceButton(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      isLarge: true,
                    ),
                  ),
                  SizedBox(width: AppSizes.spaceMd),
                  Expanded(
                    child: _ImageSourceButton(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      isLarge: true,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.spaceHeightLg),
            ],
          ),
        );
      },
    );
  }
}

class _ImageSourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final bool isLarge;

  const _ImageSourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.colorScheme,
    required this.textTheme,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: isLarge ? AppSizes.vPaddingLg : AppSizes.vPaddingSm,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: colorScheme.outline),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(
                  isLarge ? AppSizes.paddingMd : AppSizes.paddingSm,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: colorScheme.primary,
                  size: isLarge ? AppSizes.iconLg : AppSizes.iconMd,
                ),
              ),
              SizedBox(height: AppSizes.spaceHeightSm),
              Text(
                label,
                style: isLarge ? textTheme.titleSmall : textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
