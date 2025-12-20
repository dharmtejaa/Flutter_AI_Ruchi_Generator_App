import 'package:flutter/material.dart';
import 'package:ai_ruchi/models/ingredient.dart';
import 'package:ai_ruchi/core/utils/ingredient_utils.dart';

class IngredientsProvider with ChangeNotifier {
  final List<Ingredient> _currentIngredients = [];
  List<String> _suggestedAdditions = [];
  String _recipeName = '';

  List<Ingredient> get currentIngredients => _currentIngredients;
  List<String> get suggestedAdditions => _suggestedAdditions;
  String get recipeName => _recipeName;

  IngredientsProvider() {
    // Initialize suggested additions
    _suggestedAdditions = ['Spinach', 'Chili Flakes', 'Lemon', 'Garlic'];
  }

  void setRecipeName(String name) {
    _recipeName = name;
    notifyListeners();
  }

  void addIngredient(Ingredient ingredient) {
    _currentIngredients.add(ingredient);
    notifyListeners();
  }

  void removeIngredient(String id) {
    _currentIngredients.removeWhere((ingredient) => ingredient.id == id);
    notifyListeners();
  }

  void clearAllIngredients() {
    _currentIngredients.clear();
    notifyListeners();
  }

  void updateIngredientQuantity(String id, double quantity) {
    final index = _currentIngredients.indexWhere((ing) => ing.id == id);
    if (index != -1) {
      _currentIngredients[index] = _currentIngredients[index].copyWith(
        quantity: quantity,
      );
      notifyListeners();
    }
  }

  void updateIngredientUnit(String id, String unit) {
    final index = _currentIngredients.indexWhere((ing) => ing.id == id);
    if (index != -1) {
      _currentIngredients[index] = _currentIngredients[index].copyWith(
        unit: unit,
      );
      notifyListeners();
    }
  }

  void addSuggestedIngredient(String ingredientName) {
    // Add to current ingredients
    final newIngredient = Ingredient(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: ingredientName,
      quantity: 1,
      unit: 'unit',
    );
    addIngredient(newIngredient);

    // Remove from suggested additions
    _suggestedAdditions.remove(ingredientName);
    notifyListeners();
  }

  void addCustomIngredient(String name, double quantity, String unit) {
    final newIngredient = Ingredient(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      quantity: quantity,
      unit: unit,
    );
    addIngredient(newIngredient);
  }

  /// Check if an ingredient exists by name (case-insensitive)
  bool hasIngredientByName(String name) {
    return _currentIngredients.any(
      (ingredient) => ingredient.name.toLowerCase() == name.toLowerCase(),
    );
  }

  /// Remove an ingredient by name (case-insensitive)
  void removeIngredientByName(String name) {
    _currentIngredients.removeWhere(
      (ingredient) => ingredient.name.toLowerCase() == name.toLowerCase(),
    );
    notifyListeners();
  }

  /// Parse and add ingredient from text input
  /// Returns true if successful, false if text is empty
  bool parseAndAddIngredient(String text) {
    if (text.trim().isEmpty) {
      return false;
    }

    final parsed = IngredientUtils.parseIngredientText(text);
    addCustomIngredient(
      parsed['name'] as String,
      parsed['quantity'] as double,
      parsed['unit'] as String,
    );
    return true;
  }

  void regenerateRecipe() {
    // This would typically call an API to regenerate the recipe
    // For now, we'll just notify that regeneration was triggered
    notifyListeners();
  }
}
