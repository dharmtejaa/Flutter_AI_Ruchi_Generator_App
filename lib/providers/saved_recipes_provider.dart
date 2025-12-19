import 'dart:convert';

import 'package:ai_ruchi/models/recipe.dart';
import 'package:ai_ruchi/models/saved_recipe.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedRecipesProvider with ChangeNotifier {
  static const String _savedRecipesKey = 'saved_recipes';

  List<SavedRecipe> _savedRecipes = [];
  bool _isLoading = false;

  List<SavedRecipe> get savedRecipes => _savedRecipes;
  bool get isLoading => _isLoading;
  int get count => _savedRecipes.length;
  bool get isEmpty => _savedRecipes.isEmpty;

  SavedRecipesProvider() {
    _loadSavedRecipes();
  }

  /// Check if a recipe is already saved (by title)
  bool isRecipeSaved(String title) {
    return _savedRecipes.any(
      (saved) => saved.recipe.title.toLowerCase() == title.toLowerCase(),
    );
  }

  /// Save a new recipe
  Future<bool> saveRecipe(Recipe recipe) async {
    // Check if already saved
    if (isRecipeSaved(recipe.title)) {
      return false;
    }

    final savedRecipe = SavedRecipe(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      recipe: recipe,
      savedAt: DateTime.now(),
    );

    _savedRecipes.insert(0, savedRecipe); // Add to beginning
    notifyListeners();

    await _persistSavedRecipes();
    return true;
  }

  /// Delete a saved recipe by id
  Future<void> deleteRecipe(String id) async {
    _savedRecipes.removeWhere((recipe) => recipe.id == id);
    notifyListeners();
    await _persistSavedRecipes();
  }

  /// Get a saved recipe by id
  SavedRecipe? getRecipeById(String id) {
    try {
      return _savedRecipes.firstWhere((recipe) => recipe.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Clear all saved recipes
  Future<void> clearAllRecipes() async {
    _savedRecipes.clear();
    notifyListeners();
    await _persistSavedRecipes();
  }

  /// Load saved recipes from SharedPreferences
  Future<void> _loadSavedRecipes() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? recipesJson = prefs.getString(_savedRecipesKey);

      if (recipesJson != null && recipesJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(recipesJson);
        _savedRecipes = decoded
            .map((json) => SavedRecipe.fromJson(json))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading saved recipes: $e');
      _savedRecipes = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Persist saved recipes to SharedPreferences
  Future<void> _persistSavedRecipes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String recipesJson = jsonEncode(
        _savedRecipes.map((r) => r.toJson()).toList(),
      );
      await prefs.setString(_savedRecipesKey, recipesJson);
    } catch (e) {
      debugPrint('Error saving recipes: $e');
    }
  }
}
