import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ai_ruchi/models/image_recipe_response.dart';
import 'package:ai_ruchi/models/recipe.dart';
import 'package:flutter/foundation.dart';

/// API Service for generating recipes from food ingredient images
class ImageRecipeApiService {
  static const String baseUrl =
      'https://aicook-backend.onrender.com/api/recipe/generate-from-image';

  /// Maximum number of retry attempts
  static const int maxRetries = 2;

  /// Delay between retries (in seconds)
  static const int retryDelaySeconds = 3;

  /// AI providers available for recipe generation
  static const List<String> providers = ['openai', 'gemini'];

  /// Available cuisine options
  static const List<String> cuisines = [
    'Any',
    'Italian',
    'Indian',
    'Chinese',
    'Japanese',
    'Mexican',
    'Thai',
    'French',
    'Mediterranean',
    'American',
    'Korean',
    'Vietnamese',
    'Greek',
    'Middle Eastern',
    'Spanish',
  ];

  /// Available dietary options
  static const List<String> dietaryOptions = [
    'none',
    'vegetarian',
    'vegan',
    'gluten-free',
    'dairy-free',
    'keto',
    'paleo',
    'low-carb',
    'pescatarian',
  ];

  /// Generate recipe from an image of food ingredients with auto-retry
  ///
  /// [imageFile] - Image file containing food ingredients (max 10MB)
  /// [provider] - AI provider: 'openai' or 'gemini'
  /// [preferences] - Recipe preferences (cuisine and dietary)
  /// [onRetry] - Optional callback when retrying
  static Future<ImageRecipeResponse> generateRecipeFromImage({
    required File imageFile,
    required String provider,
    required RecipePreferences preferences,
    Function(int attempt, int maxAttempts)? onRetry,
  }) async {
    Exception? lastException;

    for (int attempt = 1; attempt <= maxRetries + 1; attempt++) {
      try {
        return await _makeRequest(
          imageFile: imageFile,
          provider: provider,
          preferences: preferences,
        );
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());

        // Don't retry if it's a client-side error
        final errorMsg = e.toString().toLowerCase();
        if (errorMsg.contains('image size exceeds') ||
            errorMsg.contains('please provide an image') ||
            errorMsg.contains('could not identify ingredients')) {
          throw lastException;
        }

        // Retry for server errors
        if (attempt <= maxRetries) {
          if (kDebugMode) {
            print('Retry attempt $attempt of $maxRetries...');
          }
          onRetry?.call(attempt, maxRetries);
          await Future.delayed(Duration(seconds: retryDelaySeconds * attempt));
        }
      }
    }

    throw lastException ?? Exception('Failed to generate recipe');
  }

  /// Internal method to make the actual API request
  static Future<ImageRecipeResponse> _makeRequest({
    required File imageFile,
    required String provider,
    required RecipePreferences preferences,
  }) async {
    // Validate file size (max 10MB)
    final fileSize = await imageFile.length();
    if (fileSize > 10 * 1024 * 1024) {
      throw Exception('Image size exceeds 10MB limit');
    }

    // Create multipart request
    final request = http.MultipartRequest('POST', Uri.parse(baseUrl));

    // Add headers
    request.headers.addAll({'accept': 'application/json'});

    // Add image file
    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    // Add provider
    request.fields['provider'] = provider;

    // Add preferences as JSON string using jsonEncode for proper formatting
    request.fields['preferences'] = jsonEncode(preferences.toJson());

    // Log request details in debug mode
    if (kDebugMode) {
      print('API Request to: $baseUrl');
      print('Provider: $provider');
      print('Preferences: ${request.fields['preferences']}');
      print('Image path: ${imageFile.path}');
    }

    // Send request with timeout
    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 120),
      onTimeout: () {
        throw Exception(
          'Request timeout. The server is taking too long to respond.',
        );
      },
    );
    final response = await http.Response.fromStream(streamedResponse);

    // Log response in debug mode
    if (kDebugMode) {
      print('Response status: ${response.statusCode}');
      print(
        'Response body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}',
      );
    }

    // Check if response body is valid JSON
    if (response.body.isEmpty) {
      throw Exception('Empty response from server');
    }

    // Try to detect if response is HTML instead of JSON (server error page)
    final bodyTrimmed = response.body.trim().toLowerCase();
    if (bodyTrimmed.startsWith('<!doctype') ||
        bodyTrimmed.startsWith('<html') ||
        bodyTrimmed.contains('<pre>internal server error</pre>')) {
      if (response.statusCode == 500) {
        throw Exception(
          'Server error: The recipe service is temporarily unavailable. Please try again in a few moments.',
        );
      }
      throw Exception(
        'Service temporarily unavailable. Please try again later.',
      );
    }

    // Parse response
    Map<String, dynamic> jsonResponse;
    try {
      jsonResponse = jsonDecode(response.body);
    } catch (e) {
      throw Exception('Invalid response from server. Please try again.');
    }

    if (response.statusCode == 200) {
      if (jsonResponse['success'] == true && jsonResponse['recipe'] != null) {
        return ImageRecipeResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
          jsonResponse['error']?.toString() ?? 'Failed to generate recipe',
        );
      }
    } else if (response.statusCode == 400) {
      final errorMsg = jsonResponse['error']?.toString() ?? 'Bad request';
      throw Exception(errorMsg);
    } else if (response.statusCode == 500) {
      final errorMsg =
          jsonResponse['error']?.toString() ??
          jsonResponse['message']?.toString() ??
          'Server error occurred';
      throw Exception(errorMsg);
    } else {
      throw Exception(
        'Server error (${response.statusCode}): ${jsonResponse['error'] ?? 'Unknown error'}',
      );
    }
  }

  /// Get mock/demo data for testing when server is unavailable
  static ImageRecipeResponse getMockResponse() {
    return ImageRecipeResponse(
      success: true,
      extractedIngredients: [
        'chicken breast',
        'tomatoes',
        'onion',
        'garlic',
        'olive oil',
        'basil',
        'salt',
        'pepper',
      ],
      recipe: Recipe(
        title: 'Grilled Chicken with Tomato Basil Sauce',
        description:
            'A delicious and healthy grilled chicken dish topped with a fresh tomato basil sauce. Perfect for a quick weeknight dinner!',
        ingredients: [
          RecipeIngredient(name: 'Chicken breast', amount: '500', unit: 'g'),
          RecipeIngredient(name: 'Tomatoes', amount: '4', unit: 'medium'),
          RecipeIngredient(name: 'Onion', amount: '1', unit: 'large'),
          RecipeIngredient(name: 'Garlic cloves', amount: '3', unit: 'cloves'),
          RecipeIngredient(name: 'Olive oil', amount: '3', unit: 'tbsp'),
          RecipeIngredient(name: 'Fresh basil', amount: '1/4', unit: 'cup'),
          RecipeIngredient(name: 'Salt', amount: 'to taste', unit: ''),
          RecipeIngredient(name: 'Black pepper', amount: 'to taste', unit: ''),
        ],
        instructions: [
          'Season the chicken breasts with salt and pepper on both sides.',
          'Heat 2 tablespoons of olive oil in a grill pan over medium-high heat.',
          'Grill the chicken for 6-7 minutes per side until fully cooked. Set aside to rest.',
          'In another pan, heat the remaining olive oil and sauté the minced garlic until fragrant.',
          'Add diced onions and cook until translucent, about 3-4 minutes.',
          'Add chopped tomatoes and cook for 5-7 minutes until they break down into a sauce.',
          'Stir in fresh basil leaves and season with salt and pepper.',
          'Slice the grilled chicken and serve topped with the tomato basil sauce.',
        ],
        prepTime: '15 minutes',
        cookTime: '25 minutes',
        servings: '4',
        difficulty: 'easy',
        tips:
            'For extra flavor, marinate the chicken in olive oil, lemon juice, and herbs for 30 minutes before grilling.',
        nutrition: Nutrition(
          perServing: PerServingNutrition(
            calories: NutritionValue(value: 320, unit: 'kcal'),
            macros: Macros(
              carbohydrates: MacroNutrient(
                value: 12,
                unit: 'g',
                percentage: 15,
              ),
              protein: MacroNutrient(value: 38, unit: 'g', percentage: 47),
              fat: MacroNutrient(value: 14, unit: 'g', percentage: 38),
              fiber: NutritionValue(value: 3, unit: 'g'),
              sugar: NutritionValue(value: 6, unit: 'g'),
            ),
            micros: Micros(
              vitaminA: NutritionValue(value: 800, unit: 'mcg'),
              vitaminC: NutritionValue(value: 25, unit: 'mg'),
              calcium: NutritionValue(value: 45, unit: 'mg'),
              iron: NutritionValue(value: 2, unit: 'mg'),
              potassium: NutritionValue(value: 650, unit: 'mg'),
              sodium: NutritionValue(value: 380, unit: 'mg'),
            ),
          ),
        ),
        targetAudience: [
          'General population',
          'Athletes/Fitness enthusiasts',
          'Weight loss seekers',
          'Muscle builders',
        ],
        healthBenefits: [
          'High in lean protein for muscle building and repair',
          'Rich in lycopene from tomatoes, supporting heart health',
          'Low in carbohydrates, suitable for low-carb diets',
        ],
        disclaimer:
            'This is demo data for testing purposes. Nutritional values are approximate. Always consult with a healthcare provider for personalized nutritional guidance.',
      ),
    );
  }
}
