import 'package:ai_ruchi/models/recipe.dart';

/// A wrapper class for saved recipes with additional metadata
class SavedRecipe {
  final String id;
  final Recipe recipe;
  final DateTime savedAt;

  SavedRecipe({required this.id, required this.recipe, required this.savedAt});

  factory SavedRecipe.fromJson(Map<String, dynamic> json) {
    return SavedRecipe(
      id: json['id'] ?? '',
      recipe: Recipe.fromJson(json['recipe'] ?? {}),
      savedAt: DateTime.tryParse(json['savedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipe': recipe.toJson(),
      'savedAt': savedAt.toIso8601String(),
    };
  }

  /// Calculate a simple health score based on nutrition
  String get healthScore {
    final nutrition = recipe.nutrition.perServing;
    final protein = nutrition.macros.protein.value;
    final fat = nutrition.macros.fat.value;
    final carbs = nutrition.macros.carbohydrates.value;
    final calories = nutrition.calories.value;

    // Simple scoring logic
    double score = 0;

    // Protein is good (higher = better for health score)
    if (protein > 20) {
      score += 2;
    } else if (protein > 10) {
      score += 1;
    }

    // Lower fat percentage is better
    if (fat < 15) {
      score += 2;
    } else if (fat < 25) {
      score += 1;
    }

    // Moderate calories
    if (calories >= 200 && calories <= 500) {
      score += 1;
    }

    // Good carb to protein ratio
    if (carbs > 0 && protein / carbs > 0.5) {
      score += 1;
    }

    // Score interpretation
    if (score >= 5) return 'A+ Health Score';
    if (score >= 4) return 'A Health Score';
    if (score >= 3) return 'B+ Health Score';
    if (score >= 2) return 'B Health Score';
    return 'C Health Score';
  }

  /// Get icon for the recipe based on title
  String get recipeEmoji {
    final title = recipe.title.toLowerCase();
    if (title.contains('chicken')) return '🍗';
    if (title.contains('salad')) return '🥗';
    if (title.contains('smoothie') || title.contains('bowl')) return '🥤';
    if (title.contains('toast') || title.contains('avocado')) return '🥑';
    if (title.contains('grilled')) return '🍖';
    if (title.contains('soup')) return '🍲';
    if (title.contains('pasta')) return '🍝';
    if (title.contains('fish') || title.contains('salmon')) return '🐟';
    if (title.contains('rice')) return '🍚';
    if (title.contains('egg')) return '🥚';
    if (title.contains('beef') || title.contains('steak')) return '🥩';
    if (title.contains('vegetable') || title.contains('veggie')) return '🥬';
    if (title.contains('fruit')) return '🍎';
    if (title.contains('dessert') || title.contains('cake')) return '🍰';
    if (title.contains('pizza')) return '🍕';
    if (title.contains('burger')) return '🍔';
    if (title.contains('sandwich')) return '🥪';
    return '🍽️';
  }
}
