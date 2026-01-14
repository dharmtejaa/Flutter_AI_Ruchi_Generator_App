import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ai_ruchi/models/recipe.dart';
import 'package:ai_ruchi/models/ingredient.dart';
import 'package:ai_ruchi/core/config/env_config.dart';

class RecipeApiService {
  /// Get the base URL from environment config
  static String get baseUrl => EnvConfig.recipeApiBaseUrl;

  /// Timeout for API requests (60 seconds for AI generation)
  static const Duration _timeout = Duration(seconds: 60);

  /// Generate recipe from ingredients
  ///
  /// [ingredients] - List of ingredients from provider
  /// [provider] - Model provider: 'openai' or 'gemini'
  /// [cuisine] - Cuisine type (e.g., 'Italian', 'Indian', etc.)
  /// [dietary] - Dietary preference (e.g., 'none', 'vegetarian', 'vegan', etc.)
  /// [servings] - Number of servings (1-20)
  static Future<Recipe> generateRecipe({
    required List<Ingredient> ingredients,
    required String provider,
    required String cuisine,
    required String dietary,
    int servings = 4,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      // Optimize ingredients: combine name, amount, and unit into string format
      final ingredientsList = ingredients.map((ing) {
        return '${ing.quantity}${ing.unit} ${ing.name}';
      }).toList();

      final requestBody = {
        'ingredients': ingredientsList,
        'provider': provider,
        'preferences': {
          'cuisine': cuisine,
          'dietary': dietary,
          'servings': servings,
        },
      };

      debugPrint('📤 [RecipeAPI] Sending request to: $baseUrl');
      debugPrint(
        '📤 [RecipeAPI] Provider: $provider, Cuisine: $cuisine, Dietary: $dietary',
      );
      debugPrint('📤 [RecipeAPI] Ingredients: ${ingredientsList.join(", ")}');

      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(
            _timeout,
            onTimeout: () {
              stopwatch.stop();
              debugPrint(
                '⏱️ [RecipeAPI] TIMEOUT after ${stopwatch.elapsedMilliseconds}ms',
              );
              throw TimeoutException(
                'Recipe generation timed out after ${_timeout.inSeconds} seconds. Please try again.',
              );
            },
          );

      stopwatch.stop();
      debugPrint(
        '📥 [RecipeAPI] Response received in ${stopwatch.elapsedMilliseconds}ms',
      );
      debugPrint('📥 [RecipeAPI] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['recipe'] != null) {
          debugPrint('✅ [RecipeAPI] Recipe generated successfully!');
          return Recipe.fromJson(jsonResponse['recipe']);
        } else {
          final errorMsg = jsonResponse['message'] ?? 'Unknown error';
          debugPrint('❌ [RecipeAPI] API returned error: $errorMsg');
          throw Exception('Failed to generate recipe: $errorMsg');
        }
      } else {
        debugPrint('❌ [RecipeAPI] HTTP Error: ${response.statusCode}');
        debugPrint('❌ [RecipeAPI] Body: ${response.body}');
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } on TimeoutException {
      rethrow;
    } catch (e) {
      stopwatch.stop();
      debugPrint(
        '❌ [RecipeAPI] Error after ${stopwatch.elapsedMilliseconds}ms: $e',
      );

      // Check if it's a connection error (backend might be sleeping)
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup')) {
        throw Exception(
          'Cannot connect to server. The server might be starting up, please try again in a moment.',
        );
      }

      throw Exception('Error generating recipe: $e');
    }
  }
}
