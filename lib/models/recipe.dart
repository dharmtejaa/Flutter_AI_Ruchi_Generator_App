class Recipe {
  final String title;
  final String description;
  final List<RecipeIngredient> ingredients;
  final List<String> instructions;
  final String prepTime;
  final String cookTime;
  final String servings;
  final String difficulty;
  final String? tips;
  final Nutrition nutrition;
  final List<String> targetAudience;
  final List<String> healthBenefits;
  final String disclaimer;
  final String? imageUrl;

  Recipe({
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.difficulty,
    this.tips,
    required this.nutrition,
    required this.targetAudience,
    required this.healthBenefits,
    required this.disclaimer,
    this.imageUrl,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      ingredients:
          (json['ingredients'] as List<dynamic>?)
              ?.map((e) => RecipeIngredient.fromJson(e))
              .toList() ??
          [],
      instructions:
          (json['instructions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      prepTime: json['prepTime'] ?? '',
      cookTime: json['cookTime'] ?? '',
      servings: json['servings'] ?? '',
      difficulty: json['difficulty'] ?? '',
      tips: json['tips'],
      nutrition: Nutrition.fromJson(json['nutrition'] ?? {}),
      targetAudience:
          (json['targetAudience'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      healthBenefits:
          (json['healthBenefits'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      disclaimer: json['disclaimer'] ?? '',
      imageUrl: json['imageUrl'],
    );
  }
}

class RecipeIngredient {
  final String name;
  final String amount;
  final String unit;

  RecipeIngredient({
    required this.name,
    required this.amount,
    required this.unit,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      name: json['name'] ?? '',
      amount: json['amount'] ?? '',
      unit: json['unit'] ?? '',
    );
  }
}

class Nutrition {
  final PerServingNutrition perServing;

  Nutrition({required this.perServing});

  factory Nutrition.fromJson(Map<String, dynamic> json) {
    return Nutrition(
      perServing: PerServingNutrition.fromJson(json['perServing'] ?? {}),
    );
  }
}

class PerServingNutrition {
  final NutritionValue calories;
  final Macros macros;
  final Micros micros;

  PerServingNutrition({
    required this.calories,
    required this.macros,
    required this.micros,
  });

  factory PerServingNutrition.fromJson(Map<String, dynamic> json) {
    return PerServingNutrition(
      calories: NutritionValue.fromJson(json['calories'] ?? {}),
      macros: Macros.fromJson(json['macros'] ?? {}),
      micros: Micros.fromJson(json['micros'] ?? {}),
    );
  }
}

class NutritionValue {
  final double value;
  final String unit;

  NutritionValue({required this.value, required this.unit});

  factory NutritionValue.fromJson(Map<String, dynamic> json) {
    return NutritionValue(
      value: (json['value'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
    );
  }
}

class Macros {
  final MacroNutrient carbohydrates;
  final MacroNutrient protein;
  final MacroNutrient fat;
  final NutritionValue? fiber;
  final NutritionValue? sugar;

  Macros({
    required this.carbohydrates,
    required this.protein,
    required this.fat,
    this.fiber,
    this.sugar,
  });

  factory Macros.fromJson(Map<String, dynamic> json) {
    return Macros(
      carbohydrates: MacroNutrient.fromJson(json['carbohydrates'] ?? {}),
      protein: MacroNutrient.fromJson(json['protein'] ?? {}),
      fat: MacroNutrient.fromJson(json['fat'] ?? {}),
      fiber: json['fiber'] != null
          ? NutritionValue.fromJson(json['fiber'])
          : null,
      sugar: json['sugar'] != null
          ? NutritionValue.fromJson(json['sugar'])
          : null,
    );
  }
}

class MacroNutrient extends NutritionValue {
  final double percentage;

  MacroNutrient({
    required super.value,
    required super.unit,
    required this.percentage,
  });

  factory MacroNutrient.fromJson(Map<String, dynamic> json) {
    return MacroNutrient(
      value: (json['value'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}

class Micros {
  final NutritionValue? vitaminA;
  final NutritionValue? vitaminC;
  final NutritionValue? vitaminD;
  final NutritionValue? vitaminE;
  final NutritionValue? vitaminK;
  final NutritionValue? thiamin;
  final NutritionValue? riboflavin;
  final NutritionValue? niacin;
  final NutritionValue? vitaminB6;
  final NutritionValue? folate;
  final NutritionValue? vitaminB12;
  final NutritionValue? calcium;
  final NutritionValue? iron;
  final NutritionValue? magnesium;
  final NutritionValue? phosphorus;
  final NutritionValue? potassium;
  final NutritionValue? sodium;
  final NutritionValue? zinc;

  Micros({
    this.vitaminA,
    this.vitaminC,
    this.vitaminD,
    this.vitaminE,
    this.vitaminK,
    this.thiamin,
    this.riboflavin,
    this.niacin,
    this.vitaminB6,
    this.folate,
    this.vitaminB12,
    this.calcium,
    this.iron,
    this.magnesium,
    this.phosphorus,
    this.potassium,
    this.sodium,
    this.zinc,
  });

  factory Micros.fromJson(Map<String, dynamic> json) {
    return Micros(
      vitaminA: json['vitaminA'] != null
          ? NutritionValue.fromJson(json['vitaminA'])
          : null,
      vitaminC: json['vitaminC'] != null
          ? NutritionValue.fromJson(json['vitaminC'])
          : null,
      vitaminD: json['vitaminD'] != null
          ? NutritionValue.fromJson(json['vitaminD'])
          : null,
      vitaminE: json['vitaminE'] != null
          ? NutritionValue.fromJson(json['vitaminE'])
          : null,
      vitaminK: json['vitaminK'] != null
          ? NutritionValue.fromJson(json['vitaminK'])
          : null,
      thiamin: json['thiamin'] != null
          ? NutritionValue.fromJson(json['thiamin'])
          : null,
      riboflavin: json['riboflavin'] != null
          ? NutritionValue.fromJson(json['riboflavin'])
          : null,
      niacin: json['niacin'] != null
          ? NutritionValue.fromJson(json['niacin'])
          : null,
      vitaminB6: json['vitaminB6'] != null
          ? NutritionValue.fromJson(json['vitaminB6'])
          : null,
      folate: json['folate'] != null
          ? NutritionValue.fromJson(json['folate'])
          : null,
      vitaminB12: json['vitaminB12'] != null
          ? NutritionValue.fromJson(json['vitaminB12'])
          : null,
      calcium: json['calcium'] != null
          ? NutritionValue.fromJson(json['calcium'])
          : null,
      iron: json['iron'] != null ? NutritionValue.fromJson(json['iron']) : null,
      magnesium: json['magnesium'] != null
          ? NutritionValue.fromJson(json['magnesium'])
          : null,
      phosphorus: json['phosphorus'] != null
          ? NutritionValue.fromJson(json['phosphorus'])
          : null,
      potassium: json['potassium'] != null
          ? NutritionValue.fromJson(json['potassium'])
          : null,
      sodium: json['sodium'] != null
          ? NutritionValue.fromJson(json['sodium'])
          : null,
      zinc: json['zinc'] != null ? NutritionValue.fromJson(json['zinc']) : null,
    );
  }
}

