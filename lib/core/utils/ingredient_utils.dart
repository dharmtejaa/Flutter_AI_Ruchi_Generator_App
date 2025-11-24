import 'package:flutter/material.dart';

class IngredientUtils {
  static const List<String> units = [
    'g',
    'kg',
    'ml',
    'l',
    'cup',
    'tbsp',
    'tsp',
    'can',
    'unit',
    'piece',
  ];

  /// Parse ingredient text to extract name, quantity, and unit
  /// Examples: "2 eggs" -> name: "eggs", quantity: 2, unit: "unit"
  ///           "500g flour" -> name: "flour", quantity: 500, unit: "g"
  static Map<String, dynamic> parseIngredientText(String text) {
    final parts = text.trim().split(' ');
    double? quantity;
    String unit = 'unit';
    String name = text.trim();

    if (parts.isNotEmpty) {
      // Try to parse first part as number
      final firstPart = parts[0];
      final parsedQuantity = double.tryParse(firstPart);

      if (parsedQuantity != null) {
        quantity = parsedQuantity;
        if (parts.length > 1) {
          // Check if second part is a unit
          final secondPart = parts[1].toLowerCase();
          if (units.contains(secondPart)) {
            unit = secondPart;
            name = parts.skip(2).join(' ');
          } else {
            name = parts.skip(1).join(' ');
          }
        }
      } else {
        name = text.trim();
      }
    }

    return {
      'name': name.isEmpty ? text.trim() : name,
      'quantity': quantity ?? 1,
      'unit': unit,
    };
  }

  /// Get icon for ingredient based on name
  static IconData getIngredientIcon(String ingredientName) {
    final name = ingredientName.toLowerCase();
    if (name.contains('chicken')) {
      return Icons.emoji_food_beverage;
    } else if (name.contains('pasta') || name.contains('noodle')) {
      return Icons.ramen_dining;
    } else if (name.contains('tomato')) {
      return Icons.eco;
    } else if (name.contains('spinach') || name.contains('vegetable')) {
      return Icons.eco;
    } else if (name.contains('lemon') || name.contains('citrus')) {
      return Icons.eco;
    } else if (name.contains('garlic')) {
      return Icons.eco;
    } else if (name.contains('egg')) {
      return Icons.egg;
    } else if (name.contains('onion')) {
      return Icons.eco;
    } else if (name.contains('carrot')) {
      return Icons.eco;
    } else if (name.contains('cheese')) {
      return Icons.eco;
    } else if (name.contains('bread')) {
      return Icons.bakery_dining;
    } else {
      return Icons.fastfood;
    }
  }
}

