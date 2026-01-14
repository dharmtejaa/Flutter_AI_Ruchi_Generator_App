import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service for accessing environment configuration loaded from .env file.
///
/// This provides centralized access to API endpoints and keys,
/// avoiding hardcoded values in the codebase.
///
/// Usage:
/// 1. Call `EnvConfig.load()` in main.dart before runApp()
/// 2. Access values using static getters
class EnvConfig {
  /// Load environment variables from .env file
  /// Call this in main() before runApp()
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  /// Check if environment is loaded
  static bool get isLoaded => dotenv.isEveryDefined([
    'RECIPE_API_BASE_URL',
    'IMAGE_RECIPE_API_BASE_URL',
  ]);

  // ============================================================================
  // API ENDPOINTS
  // ============================================================================

  /// Base URL for recipe generation API
  static String get recipeApiBaseUrl =>
      dotenv.env['RECIPE_API_BASE_URL'] ??
      'https://aicook-backend.onrender.com/api/recipe/generate';

  /// Base URL for image-based recipe generation API
  static String get imageRecipeApiBaseUrl =>
      dotenv.env['IMAGE_RECIPE_API_BASE_URL'] ??
      'https://aicook-backend.onrender.com/api/recipe/generate-from-image';

  // ============================================================================
  // API KEYS (for future use)
  // ============================================================================

  /// OpenAI API key (optional, if needed locally)
  static String? get openAiApiKey => dotenv.env['OPENAI_API_KEY'];

  /// Gemini API key (optional, if needed locally)
  static String? get geminiApiKey => dotenv.env['GEMINI_API_KEY'];

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Get any environment variable by key
  static String? get(String key) => dotenv.env[key];

  /// Get environment variable with fallback
  static String getOrDefault(String key, String defaultValue) =>
      dotenv.env[key] ?? defaultValue;

  /// Check if a specific variable is defined
  static bool isDefined(String key) => dotenv.env.containsKey(key);
}
