import 'package:ai_ruchi/models/recipe.dart';
import 'package:ai_ruchi/models/removed_ingredient.dart';

/// Model for the API response from generate-from-image endpoint
class ImageRecipeResponse {
  final bool success;
  final List<String> extractedIngredients;
  final Recipe recipe;
  final List<RemovedIngredient>? removedIngredients;
  final String? analysisNote;

  ImageRecipeResponse({
    required this.success,
    required this.extractedIngredients,
    required this.recipe,
    this.removedIngredients,
    this.analysisNote,
  });

  factory ImageRecipeResponse.fromJson(Map<String, dynamic> json) {
    return ImageRecipeResponse(
      success: json['success'] ?? false,
      extractedIngredients:
          (json['extractedIngredients'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      recipe: Recipe.fromJson(json['recipe'] ?? {}),
      removedIngredients: (json['removedIngredients'] as List<dynamic>?)
          ?.map((e) => RemovedIngredient.fromJson(e as Map<String, dynamic>))
          .toList(),
      analysisNote: json['analysisNote']?.toString(),
    );
  }
}

/// Model for API error responses
class ImageRecipeError {
  final String error;
  final String? message;

  ImageRecipeError({required this.error, this.message});

  factory ImageRecipeError.fromJson(Map<String, dynamic> json) {
    return ImageRecipeError(
      error: json['error']?.toString() ?? 'Unknown error',
      message: json['message']?.toString(),
    );
  }

  @override
  String toString() {
    if (message != null) {
      return '$error: $message';
    }
    return error;
  }
}

/// Model for recipe preferences
class RecipePreferences {
  final String cuisine;
  final String dietary;
  final int servings;

  RecipePreferences({
    this.cuisine = 'Any',
    this.dietary = 'none',
    this.servings = 4,
  });

  Map<String, dynamic> toJson() {
    return {'cuisine': cuisine, 'dietary': dietary, 'servings': servings};
  }

  @override
  String toString() {
    return '{"cuisine":"$cuisine","dietary":"$dietary","servings":$servings}';
  }
}
