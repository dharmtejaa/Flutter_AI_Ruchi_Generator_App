import 'package:flutter/material.dart';
import 'package:ai_ruchi/models/recipe.dart';
import 'package:ai_ruchi/core/services/recipe_api_service.dart';
import 'package:ai_ruchi/models/ingredient.dart';

class RecipeProvider with ChangeNotifier {
  Recipe? _recipe;
  bool _isLoading = false;
  String? _error;
  String _selectedProvider = 'openai';
  String _selectedCuisine = 'none';
  String _selectedDietary = 'none';

  Recipe? get recipe => _recipe;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedProvider => _selectedProvider;
  String get selectedCuisine => _selectedCuisine;
  String get selectedDietary => _selectedDietary;

  // Available options
  static const List<String> providers = ['openai', 'gemini'];
  static const List<String> cuisines = [
    'none',
    'Italian',
    'Indian',
    'Chinese',
    'Mexican',
    'Japanese',
    'Thai',
    'French',
    'Mediterranean',
    'American',
  ];
  static const List<String> dietaryOptions = [
    'none',
    'vegetarian',
    'vegan',
    'gluten-free',
    'dairy-free',
    'keto',
    'paleo',
    'low-carb',
    'high-protein',
  ];

  void setProvider(String provider) {
    _selectedProvider = provider;
    notifyListeners();
  }

  void setCuisine(String cuisine) {
    _selectedCuisine = cuisine;
    notifyListeners();
  }

  void setDietary(String dietary) {
    _selectedDietary = dietary;
    notifyListeners();
  }

  Future<void> generateRecipe(List<Ingredient> ingredients) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final generatedRecipe = await RecipeApiService.generateRecipe(
        ingredients: ingredients,
        provider: _selectedProvider,
        cuisine: _selectedCuisine,
        dietary: _selectedDietary,
      );

      _recipe = generatedRecipe;
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _recipe = null;
      notifyListeners();
    }
  }

  void clearRecipe() {
    _recipe = null;
    _error = null;
    notifyListeners();
  }

  void resetPreferences() {
    _selectedProvider = 'openai';
    _selectedCuisine = 'none';
    _selectedDietary = 'none';
    notifyListeners();
  }
}

