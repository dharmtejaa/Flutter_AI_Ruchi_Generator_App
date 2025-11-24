import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ai_ruchi/models/recipe.dart';
import 'package:ai_ruchi/models/ingredient.dart';

class RecipeApiService {
  static const String baseUrl =
      'https://aicook-backend.onrender.com/api/recipe/generate';

  /// Generate recipe from ingredients
  ///
  /// [ingredients] - List of ingredients from provider
  /// [provider] - Model provider: 'openai' or 'gemini'
  /// [cuisine] - Cuisine type (e.g., 'Italian', 'Indian', etc.)
  /// [dietary] - Dietary preference (e.g., 'none', 'vegetarian', 'vegan', etc.)
  static Future<Recipe> generateRecipe({
    required List<Ingredient> ingredients,
    required String provider,
    required String cuisine,
    required String dietary,
  }) async {
    try {
      // Optimize ingredients: combine name, amount, and unit into string format
      final ingredientsList = ingredients.map((ing) {
        return '${ing.quantity}${ing.unit} ${ing.name}';
      }).toList();

      final requestBody = {
        'ingredients': ingredientsList,
        'provider': provider,
        'preferences': {'cuisine': cuisine, 'dietary': dietary},
      };

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['recipe'] != null) {
          return Recipe.fromJson(jsonResponse['recipe']);
        } else {
          throw Exception(
            'Failed to generate recipe: ${jsonResponse['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error generating recipe: $e');
    }
  }
}

