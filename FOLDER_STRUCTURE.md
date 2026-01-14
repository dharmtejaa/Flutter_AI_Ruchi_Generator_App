# AI Ruchi - Project Folder Structure

This document describes the organized folder structure of the AI Ruchi Flutter application.

## 📁 Root Directory Structure

```
lib/
├── main.dart                 # App entry point
├── core/                     # Core utilities, services, and configurations
├── models/                   # Data models
├── providers/                # State management (Provider)
├── screens/                  # Screen/page widgets
└── shared/                   # Shared/reusable widgets
```

---

## 📂 Core (`lib/core/`)

Contains all core application logic, utilities, services, and configurations.

```
core/
├── config/                   # App configuration
│   └── env_config.dart       # Environment variables (from .env)
│
├── data/                     # Static data and constants
│   └── ingredient_categories.dart  # Ingredient category definitions
│
├── services/                 # Business logic and API services
│   ├── ad_service.dart             # Google Mobile Ads management
│   ├── haptic_service.dart         # Haptic feedback utilities
│   ├── image_recipe_api_service.dart  # Image-based recipe API
│   ├── my_custom_cache_manager.dart   # Cache management
│   ├── poison_ingredient_service.dart # Dangerous ingredient detection
│   ├── recipe_api_service.dart     # Text-based recipe API
│   ├── secure_storage_service.dart # Encrypted secure storage
│   ├── shake_detector_service.dart # Shake-to-scan detection
│   ├── speech_service.dart         # Speech-to-text
│   ├── tts_service.dart            # Text-to-speech
│   └── tutorial_service.dart       # Onboarding tutorials
│
├── theme/                    # App theming
│   ├── app_shadows.dart      # Shadow definitions
│   ├── app_theme.dart        # Main theme configuration
│   ├── appcolors.dart        # Color utilities
│   ├── dark_theme_colors.dart    # Dark mode colors
│   └── light_theme_colors.dart   # Light mode colors
│
└── utils/                    # Utility functions
    ├── app_router.dart       # Navigation/routing (go_router)
    ├── app_sizes.dart        # Responsive sizing constants
    ├── ingredient_helper.dart    # Ingredient input helpers
    ├── ingredient_utils.dart     # Ingredient parsing utilities
    ├── recipe_helper.dart        # Recipe generation helpers
    └── time_parser_utils.dart    # Time parsing utilities
```

---

## 📂 Models (`lib/models/`)

Data models and entities used throughout the app.

```
models/
├── image_recipe_response.dart  # API response for image-based recipes
├── ingredient.dart             # Ingredient model
├── recipe.dart                 # Recipe model with nutrition info
├── removed_ingredient.dart     # Removed ingredient tracking
└── saved_recipe.dart           # Saved recipe model
```

---

## 📂 Providers (`lib/providers/`)

State management using Provider pattern.

```
providers/
├── app_settings_provider.dart    # App-wide settings (TTS, shake, etc.)
├── ingredients_provider.dart     # Current ingredients state
├── recipe_provider.dart          # Recipe generation state
├── saved_recipes_provider.dart   # Saved recipes management
└── theme_provider.dart           # Theme mode (light/dark/system)
```

---

## 📂 Screens (`lib/screens/`)

All app screens/pages organized by feature.

```
screens/
├── entry/                    # Main ingredient entry screen
│   └── entry_screen.dart
│
├── main/                     # Main shell with bottom navigation
│   └── main_shell_screen.dart
│
├── nutrition/                # Nutrition information screens
│   ├── nutrition_detail_screen.dart
│   └── nutrition_info_screen.dart
│
├── onboarding/              # First-time user onboarding
│   └── onboarding_screen.dart
│
├── profile/                 # User profile/settings
│   └── profile_screen.dart
│
├── recipe/                  # Recipe-related screens
│   ├── adjust_ingredients_screen.dart    # Modify ingredients
│   ├── recipe_generated_screen.dart      # View generated recipe
│   └── recipe_generation_loading_screen.dart  # Loading state
│
├── saved/                   # Saved recipes
│   └── saved_recipes_screen.dart
│
├── scan/                    # Image scanning for ingredients
│   └── scan_screen.dart
│
└── search/                  # Search functionality
    └── search_screen.dart
```

---

## 📂 Shared Widgets (`lib/shared/widgets/`)

Reusable widgets organized by category.

```
shared/widgets/
├── ads/                      # Advertisement widgets
│   └── banner_ad_widget.dart
│
├── common/                   # Common UI components
│   ├── custom_button.dart        # Styled buttons
│   ├── custom_dialog.dart        # Styled dialogs
│   ├── custom_snackbar.dart      # Toast notifications
│   ├── custom_textfield.dart     # Styled text inputs
│   ├── dismiss_keyboard.dart     # Keyboard dismissal wrapper
│   ├── double_back_to_exit.dart  # Back button handler
│   ├── no_result_found.dart      # Empty state widget
│   ├── nutrition_summary_row.dart    # Nutrition display
│   └── poison_warning_dialog.dart    # Dangerous ingredient warning
│
├── ingredient/               # Ingredient-related widgets
│   ├── categorized_ingredient_suggestions.dart  # Category chips
│   ├── category_chip.dart                # Individual category chip
│   ├── current_ingredients_section.dart  # Current ingredients list
│   ├── expanded_category_section.dart    # Expanded category view
│   ├── ingredient_action_bar.dart        # Bottom action buttons
│   ├── ingredient_card_widget.dart       # Ingredient card
│   ├── ingredient_header_widget.dart     # Section header
│   └── ingredient_input_widget.dart      # Text input for ingredients
│
├── navigation/               # Navigation widgets
│   └── app_bottom_navigation_bar.dart
│
└── recipe/                   # Recipe-related widgets
    ├── instruction_timer_widget.dart     # Cooking timer
    ├── recipe_action_buttons.dart        # Save/share actions
    ├── recipe_image_widget.dart          # Recipe image display
    ├── recipe_ingredients_tab.dart       # Ingredients tab
    ├── recipe_instructions_tab.dart      # Instructions tab
    ├── recipe_loading_screen.dart        # Loading animation
    ├── recipe_nutrition_tab.dart         # Nutrition tab
    ├── recipe_preferences_bottom_sheet.dart  # Preferences sheet
    ├── recipe_preferences_dialog.dart    # Preferences dialog
    └── save_recipe_dialog.dart           # Save confirmation
```

---

## 🎯 Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                          main.dart                          │
│                    (App Initialization)                     │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                        Providers                            │
│         (State Management - ChangeNotifierProvider)         │
│                                                             │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────────┐    │
│  │   Theme      │ │ Ingredients  │ │     Recipe       │    │
│  │  Provider    │ │  Provider    │ │    Provider      │    │
│  └──────────────┘ └──────────────┘ └──────────────────┘    │
│  ┌──────────────┐ ┌──────────────┐                         │
│  │ App Settings │ │Saved Recipes │                         │
│  │  Provider    │ │  Provider    │                         │
│  └──────────────┘ └──────────────┘                         │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                         Screens                             │
│                 (UI Layer with Routing)                     │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Shared Widgets                           │
│              (Reusable UI Components)                       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     Core Services                           │
│           (API, Storage, Utilities, Theme)                  │
│                                                             │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────────┐    │
│  │  API Layer   │ │   Storage    │ │    Utilities     │    │
│  │ (Recipe API) │ │  (Secure)    │ │  (Helpers)       │    │
│  └──────────────┘ └──────────────┘ └──────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                         Models                              │
│                (Data Transfer Objects)                      │
└─────────────────────────────────────────────────────────────┘
```

---

## 📋 Naming Conventions

| Type      | Convention          | Example                   |
| --------- | ------------------- | ------------------------- |
| Files     | `snake_case.dart`   | `recipe_api_service.dart` |
| Classes   | `PascalCase`        | `RecipeApiService`        |
| Providers | `FeatureProvider`   | `IngredientsProvider`     |
| Screens   | `FeatureScreen`     | `EntryScreen`             |
| Widgets   | `DescriptiveWidget` | `IngredientCardWidget`    |
| Services  | `FeatureService`    | `SecureStorageService`    |

---

## 🔒 Security Files

- `.env` - Environment variables (API endpoints, keys) - **gitignored**
- `.env.example` - Template for environment variables
- `secure_storage_service.dart` - Encrypted storage for sensitive data

---

## 📝 Notes

1. **Screens vs Widgets**: Screens are full pages with their own route. Widgets are reusable components.
2. **Services**: Contain business logic and external API interactions.
3. **Providers**: Manage application state using the Provider pattern.
4. **Models**: Plain Dart objects for data transfer and serialization.
