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
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
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
      prepTime: json['prepTime']?.toString() ?? '',
      cookTime: json['cookTime']?.toString() ?? '',
      servings: json['servings']?.toString() ?? '',
      difficulty: json['difficulty']?.toString() ?? '',
      tips: json['tips']?.toString(),
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
      disclaimer: json['disclaimer']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'instructions': instructions,
      'prepTime': prepTime,
      'cookTime': cookTime,
      'servings': servings,
      'difficulty': difficulty,
      'tips': tips,
      'nutrition': nutrition.toJson(),
      'targetAudience': targetAudience,
      'healthBenefits': healthBenefits,
      'disclaimer': disclaimer,
      'imageUrl': imageUrl,
    };
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
      name: json['name']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'amount': amount, 'unit': unit};
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

  Map<String, dynamic> toJson() {
    return {'perServing': perServing.toJson()};
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

  Map<String, dynamic> toJson() {
    return {
      'calories': calories.toJson(),
      'macros': macros.toJson(),
      'micros': micros.toJson(),
    };
  }
}

class NutritionValue {
  final double value;
  final String unit;

  NutritionValue({required this.value, required this.unit});

  factory NutritionValue.fromJson(Map<String, dynamic> json) {
    return NutritionValue(
      value: (json['value'] ?? 0).toDouble(),
      unit: json['unit']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'unit': unit};
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

  /// Returns fiber and sugar as a list with names
  List<MicroNutrientInfo> get otherMacros {
    final list = <MicroNutrientInfo>[];
    if (fiber != null) list.add(MicroNutrientInfo('Fiber', fiber!));
    if (sugar != null) list.add(MicroNutrientInfo('Sugar', sugar!));
    return list;
  }

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

  Map<String, dynamic> toJson() {
    return {
      'carbohydrates': carbohydrates.toJson(),
      'protein': protein.toJson(),
      'fat': fat.toJson(),
      if (fiber != null) 'fiber': fiber!.toJson(),
      if (sugar != null) 'sugar': sugar!.toJson(),
    };
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
      unit: json['unit']?.toString() ?? '',
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'value': value, 'unit': unit, 'percentage': percentage};
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

  /// Returns all available vitamins as a list
  List<MicroNutrientInfo> get vitamins {
    final list = <MicroNutrientInfo>[];
    if (vitaminA != null) list.add(MicroNutrientInfo('Vitamin A', vitaminA!));
    if (vitaminC != null) list.add(MicroNutrientInfo('Vitamin C', vitaminC!));
    if (vitaminD != null) list.add(MicroNutrientInfo('Vitamin D', vitaminD!));
    if (vitaminE != null) list.add(MicroNutrientInfo('Vitamin E', vitaminE!));
    if (vitaminK != null) list.add(MicroNutrientInfo('Vitamin K', vitaminK!));
    if (thiamin != null) list.add(MicroNutrientInfo('Thiamin (B1)', thiamin!));
    if (riboflavin != null) {
      list.add(MicroNutrientInfo('Riboflavin (B2)', riboflavin!));
    }
    if (niacin != null) list.add(MicroNutrientInfo('Niacin (B3)', niacin!));
    if (vitaminB6 != null) {
      list.add(MicroNutrientInfo('Vitamin B6', vitaminB6!));
    }
    if (folate != null) list.add(MicroNutrientInfo('Folate', folate!));
    if (vitaminB12 != null) {
      list.add(MicroNutrientInfo('Vitamin B12', vitaminB12!));
    }
    return list;
  }

  /// Returns all available minerals as a list
  List<MicroNutrientInfo> get minerals {
    final list = <MicroNutrientInfo>[];
    if (calcium != null) list.add(MicroNutrientInfo('Calcium', calcium!));
    if (iron != null) list.add(MicroNutrientInfo('Iron', iron!));
    if (magnesium != null) list.add(MicroNutrientInfo('Magnesium', magnesium!));
    if (phosphorus != null) {
      list.add(MicroNutrientInfo('Phosphorus', phosphorus!));
    }
    if (potassium != null) list.add(MicroNutrientInfo('Potassium', potassium!));
    if (sodium != null) list.add(MicroNutrientInfo('Sodium', sodium!));
    if (zinc != null) list.add(MicroNutrientInfo('Zinc', zinc!));
    return list;
  }

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

  Map<String, dynamic> toJson() {
    return {
      if (vitaminA != null) 'vitaminA': vitaminA!.toJson(),
      if (vitaminC != null) 'vitaminC': vitaminC!.toJson(),
      if (vitaminD != null) 'vitaminD': vitaminD!.toJson(),
      if (vitaminE != null) 'vitaminE': vitaminE!.toJson(),
      if (vitaminK != null) 'vitaminK': vitaminK!.toJson(),
      if (thiamin != null) 'thiamin': thiamin!.toJson(),
      if (riboflavin != null) 'riboflavin': riboflavin!.toJson(),
      if (niacin != null) 'niacin': niacin!.toJson(),
      if (vitaminB6 != null) 'vitaminB6': vitaminB6!.toJson(),
      if (folate != null) 'folate': folate!.toJson(),
      if (vitaminB12 != null) 'vitaminB12': vitaminB12!.toJson(),
      if (calcium != null) 'calcium': calcium!.toJson(),
      if (iron != null) 'iron': iron!.toJson(),
      if (magnesium != null) 'magnesium': magnesium!.toJson(),
      if (phosphorus != null) 'phosphorus': phosphorus!.toJson(),
      if (potassium != null) 'potassium': potassium!.toJson(),
      if (sodium != null) 'sodium': sodium!.toJson(),
      if (zinc != null) 'zinc': zinc!.toJson(),
    };
  }
}

/// Helper class to hold micronutrient info with name
class MicroNutrientInfo {
  final String name;
  final NutritionValue nutrient;

  MicroNutrientInfo(this.name, this.nutrient);

  double get value => nutrient.value;
  String get unit => nutrient.unit;
}
