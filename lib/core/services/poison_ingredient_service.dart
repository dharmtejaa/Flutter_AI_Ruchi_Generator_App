/// Service for detecting potentially dangerous/poisonous ingredients
class PoisonIngredientService {
  /// List of dangerous household items and poisons that should not be consumed
  static const List<String> _dangerousItems = [
    // Cleaning products
    'bleach',
    'ammonia',
    'detergent',
    'soap',
    'dish soap',
    'laundry detergent',
    'fabric softener',
    'drain cleaner',
    'oven cleaner',
    'toilet cleaner',
    'bathroom cleaner',
    'cleaning fluid',
    'disinfectant',
    'lysol',
    'clorox',

    // Pesticides and chemicals
    'rat poison',
    'mouse poison',
    'pesticide',
    'insecticide',
    'herbicide',
    'weed killer',
    'roach killer',
    'ant poison',
    'moth balls',
    'mothballs',

    // Automotive/Industrial
    'antifreeze',
    'motor oil',
    'gasoline',
    'kerosene',
    'paint thinner',
    'turpentine',
    'acetone',
    'nail polish remover',
    'paint',
    'varnish',
    'glue',
    'super glue',
    'epoxy',

    // Medical/Pharmaceutical (non-food)
    'rubbing alcohol',
    'isopropyl alcohol',
    'hydrogen peroxide',
    'hand sanitizer',

    // Other dangerous items
    'silica gel',
    'desiccant',
    'battery acid',
    'lighter fluid',
    'charcoal lighter',
    'fertilizer',
    'pool chemicals',
    'chlorine tablets',
  ];

  /// Check if the ingredient list contains any dangerous items
  /// Returns a list of detected dangerous ingredients with warnings
  static List<DetectedPoisonItem> detectDangerousIngredients(
    List<String> ingredients,
  ) {
    final List<DetectedPoisonItem> detectedItems = [];

    for (final ingredient in ingredients) {
      final lowerIngredient = ingredient.toLowerCase().trim();

      for (final dangerous in _dangerousItems) {
        if (lowerIngredient.contains(dangerous) ||
            dangerous.contains(lowerIngredient)) {
          detectedItems.add(
            DetectedPoisonItem(
              ingredientName: ingredient,
              matchedDangerousItem: dangerous,
              warningMessage: _getWarningMessage(dangerous),
            ),
          );
          break; // Only add once per ingredient
        }
      }
    }

    return detectedItems;
  }

  /// Check if any ingredient is dangerous (quick check)
  static bool containsDangerousIngredient(List<String> ingredients) {
    return detectDangerousIngredients(ingredients).isNotEmpty;
  }

  /// Get appropriate warning message for dangerous item category
  static String _getWarningMessage(String item) {
    final lowerItem = item.toLowerCase();

    if (lowerItem.contains('bleach') ||
        lowerItem.contains('ammonia') ||
        lowerItem.contains('cleaning') ||
        lowerItem.contains('detergent') ||
        lowerItem.contains('disinfectant')) {
      return 'This is a household cleaning product and is toxic if consumed.';
    }

    if (lowerItem.contains('poison') ||
        lowerItem.contains('pesticide') ||
        lowerItem.contains('insecticide') ||
        lowerItem.contains('herbicide')) {
      return 'This is a poison/pesticide and is extremely dangerous if consumed.';
    }

    if (lowerItem.contains('antifreeze') ||
        lowerItem.contains('motor') ||
        lowerItem.contains('gasoline') ||
        lowerItem.contains('paint') ||
        lowerItem.contains('turpentine')) {
      return 'This is an industrial/automotive chemical and is toxic if consumed.';
    }

    if (lowerItem.contains('alcohol') && !lowerItem.contains('cooking')) {
      return 'This type of alcohol is not safe for consumption.';
    }

    return 'This item is not safe for human consumption.';
  }
}

/// Model for a detected poison/dangerous item
class DetectedPoisonItem {
  final String ingredientName;
  final String matchedDangerousItem;
  final String warningMessage;

  DetectedPoisonItem({
    required this.ingredientName,
    required this.matchedDangerousItem,
    required this.warningMessage,
  });
}
