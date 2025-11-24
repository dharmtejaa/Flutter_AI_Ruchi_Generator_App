# Project Structure

This project follows industry-standard Flutter architecture patterns for better maintainability and scalability.

## Directory Structure

```
lib/
├── core/                    # Core functionality and utilities
│   ├── constants/          # App-wide constants
│   ├── services/           # Core services (cache, sizes, etc.)
│   ├── theme/              # Theme configuration (colors, shadows, etc.)
│   └── utils/              # Utility functions and helpers
│
├── shared/                  # Shared/reusable components
│   └── widgets/            # Reusable UI widgets
│
├── data/                    # Data layer
│   ├── models/             # Data models
│   ├── repositories/       # Repository implementations
│   └── datasources/        # Data sources (API, local, etc.)
│
└── presentation/            # Presentation/UI layer
    ├── providers/          # State management providers
    ├── screens/            # Screen widgets
    └── routes/             # Navigation routes
```

## Import Guidelines

### Using Barrel Exports

For easier imports, use the barrel export files:

```dart
// Instead of individual imports
import 'package:ai_ruchi/core/theme/app_theme.dart';
import 'package:ai_ruchi/core/theme/app_shadows.dart';

// Use barrel exports
import 'package:ai_ruchi/core/theme/theme.dart';
```

### Available Barrel Exports

- `core/theme/theme.dart` - All theme-related exports
- `core/services/services.dart` - All service exports
- `shared/widgets/widgets.dart` - All shared widget exports
- `presentation/providers/providers.dart` - All provider exports

## Best Practices

1. **Core Layer**: Contains app-wide utilities, services, and configurations
2. **Shared Layer**: Reusable components that can be used across features
3. **Data Layer**: Handles all data operations (API calls, local storage, etc.)
4. **Presentation Layer**: UI components, state management, and navigation

## Adding New Features

When adding new features:
1. Create feature-specific folders in `presentation/screens/` if needed
2. Add feature-specific models to `data/models/`
3. Add feature-specific repositories to `data/repositories/`
4. Add feature-specific data sources to `data/datasources/`