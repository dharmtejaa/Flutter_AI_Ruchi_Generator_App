import 'package:ai_ruchi/models/recipe.dart';

/// Model for the API response from generate-from-image endpoint
class ImageRecipeResponse {
  final bool success;
  final List<String> extractedIngredients;
  final Recipe recipe;

  ImageRecipeResponse({
    required this.success,
    required this.extractedIngredients,
    required this.recipe,
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

  RecipePreferences({this.cuisine = 'Any', this.dietary = 'none'});

  Map<String, String> toJson() {
    return {'cuisine': cuisine, 'dietary': dietary};
  }

  @override
  String toString() {
    return '{"cuisine":"$cuisine","dietary":"$dietary"}';
  }
}
