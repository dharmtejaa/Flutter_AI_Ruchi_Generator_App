import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ai_ruchi/models/image_recipe_response.dart';

/// API Service for generating recipes from food ingredient images
class ImageRecipeApiService {
  static const String baseUrl =
      'https://aicook-backend.onrender.com/api/recipe/generate-from-image';

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

  /// Generate recipe from an image of food ingredients
  ///
  /// [imageFile] - Image file containing food ingredients (max 10MB)
  /// [provider] - AI provider: 'openai' or 'gemini'
  /// [preferences] - Recipe preferences (cuisine and dietary)
  static Future<ImageRecipeResponse> generateRecipeFromImage({
    required File imageFile,
    required String provider,
    required RecipePreferences preferences,
  }) async {
    try {
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

      // Add preferences as JSON string
      request.fields['preferences'] = preferences.toString();

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['recipe'] != null) {
          return ImageRecipeResponse.fromJson(jsonResponse);
        } else {
          throw Exception(
            'Failed to generate recipe: ${jsonResponse['error'] ?? 'Unknown error'}',
          );
        }
      } else if (response.statusCode == 400) {
        final jsonResponse = jsonDecode(response.body);
        final error = ImageRecipeError.fromJson(jsonResponse);
        throw Exception(error.toString());
      } else if (response.statusCode == 500) {
        final jsonResponse = jsonDecode(response.body);
        final error = ImageRecipeError.fromJson(jsonResponse);
        throw Exception(error.toString());
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error generating recipe from image: $e');
    }
  }
}
