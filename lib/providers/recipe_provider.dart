import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ai_ruchi/models/recipe.dart';
import 'package:ai_ruchi/core/services/recipe_api_service.dart';
import 'package:ai_ruchi/models/ingredient.dart';

/// Provider for managing generated recipe state.
///
/// **Memory Management:** This provider keeps recipe data in memory only.
/// Data is NOT automatically persisted to disk. Users must explicitly save
/// recipes using [SavedRecipesProvider.saveRecipe] to persist them.
class RecipeProvider with ChangeNotifier {
  Recipe? _recipe;
  bool _isLoading = false;
  String? _error;
  String _selectedProvider = 'openai';
  String _selectedCuisine = 'none';
  String _selectedDietary = 'none';
  int _selectedServings = 1;

  // Instruction state (preserved across tab switches)
  final Set<int> _completedSteps = {};
  int? _currentlyPlayingIndex;

  Recipe? get recipe => _recipe;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedProvider => _selectedProvider;
  String get selectedCuisine => _selectedCuisine;
  String get selectedDietary => _selectedDietary;
  int get selectedServings => _selectedServings;

  // Instruction state getters
  Set<int> get completedSteps => _completedSteps;
  int? get currentlyPlayingIndex => _currentlyPlayingIndex;

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
  static const List<int> servingsOptions = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    10,
    12,
    15,
    20,
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

  void setServings(int servings) {
    _selectedServings = servings.clamp(1, 20);
    notifyListeners();
  }

  // Instruction state management
  void toggleStepCompletion(int index) {
    if (_completedSteps.contains(index)) {
      // When uncompleting, also uncomplete all steps after this one (lock them)
      _completedSteps.removeWhere((step) => step >= index);
    } else {
      _completedSteps.add(index);
    }
    notifyListeners();
  }

  void markStepCompleted(int index) {
    if (!_completedSteps.contains(index)) {
      _completedSteps.add(index);
      notifyListeners();
    }
  }

  void setCurrentlyPlayingIndex(int? index) {
    _currentlyPlayingIndex = index;
    notifyListeners();
  }

  void resetInstructionState() {
    _completedSteps.clear();
    _currentlyPlayingIndex = null;
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
        servings: _selectedServings,
      );

      _recipe = generatedRecipe;
      _isLoading = false;
      _error = null;
      // Reset instruction state for new recipe
      _completedSteps.clear();
      _currentlyPlayingIndex = null;
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
    _completedSteps.clear();
    _currentlyPlayingIndex = null;
    notifyListeners();
  }

  /// Set recipe directly (used by scan screen)
  void setRecipe(Recipe recipe) {
    _recipe = recipe;
    _error = null;
    // Reset instruction state for new recipe
    _completedSteps.clear();
    _currentlyPlayingIndex = null;
    notifyListeners();
  }

  void resetPreferences() {
    _selectedProvider = 'openai';
    _selectedCuisine = 'none';
    _selectedDietary = 'none';
    _selectedServings = 1;
    notifyListeners();
  }

  // Timer Command Stream
  // stepIndex: null means "current playing or active"
  final _timerCommandController = StreamController<TimerEvent>.broadcast();
  Stream<TimerEvent> get timerCommandStream => _timerCommandController.stream;

  void dispatchTimerCommand(TimerAction action, {int? stepIndex}) {
    _timerCommandController.add(
      TimerEvent(action: action, stepIndex: stepIndex),
    );
  }

  @override
  void dispose() {
    _timerCommandController.close();
    super.dispose();
  }
}

enum TimerAction { start, pause, reset }

class TimerEvent {
  final TimerAction action;
  final int? stepIndex;

  TimerEvent({required this.action, this.stepIndex});
}
