import 'package:flutter/material.dart';

/// Represents a category of ingredients with its display properties
class IngredientCategory {
  final String id;
  final String name;
  final String emoji;
  final IconData icon;
  final Color color;
  final List<String> ingredients;

  const IngredientCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.icon,
    required this.color,
    required this.ingredients,
  });
}

/// All available ingredient categories
class IngredientCategories {
  static const List<IngredientCategory> all = [
    IngredientCategory(
      id: 'vegetables',
      name: 'Vegetables',
      emoji: '🥬',
      icon: Icons.eco,
      color: Color(0xFF4CAF50),
      ingredients: [
        'Onion',
        'Tomato',
        'Potato',
        'Carrot',
        'Spinach',
        'Capsicum',
        'Broccoli',
        'Cauliflower',
        'Cabbage',
        'Cucumber',
        'Garlic',
        'Ginger',
        'Green Chili',
        'Coriander',
        'Mint',
        'Peas',
        'Beans',
        'Eggplant',
        'Mushroom',
        'Zucchini',
      ],
    ),
    IngredientCategory(
      id: 'proteins',
      name: 'Proteins',
      emoji: '🍗',
      icon: Icons.set_meal,
      color: Color(0xFFE91E63),
      ingredients: [
        'Chicken',
        'Mutton',
        'Fish',
        'Prawns',
        'Eggs',
        'Paneer',
        'Tofu',
        'Beef',
        'Pork',
        'Turkey',
        'Lamb',
        'Salmon',
        'Tuna',
        'Crab',
        'Lobster',
      ],
    ),
    IngredientCategory(
      id: 'dairy',
      name: 'Dairy',
      emoji: '🧀',
      icon: Icons.water_drop,
      color: Color(0xFFFFC107),
      ingredients: [
        'Milk',
        'Butter',
        'Cheese',
        'Cream',
        'Yogurt',
        'Ghee',
        'Curd',
        'Cottage Cheese',
        'Sour Cream',
        'Whipped Cream',
        'Mozzarella',
        'Parmesan',
      ],
    ),
    IngredientCategory(
      id: 'grains',
      name: 'Grains & Cereals',
      emoji: '🌾',
      icon: Icons.grain,
      color: Color(0xFF795548),
      ingredients: [
        'Rice',
        'Wheat Flour',
        'Bread',
        'Pasta',
        'Oats',
        'Quinoa',
        'Noodles',
        'Semolina',
        'Cornflour',
        'Maida',
        'Besan',
        'Poha',
        'Vermicelli',
        'Couscous',
      ],
    ),
    IngredientCategory(
      id: 'spices',
      name: 'Spices & Herbs',
      emoji: '🌶️',
      icon: Icons.local_fire_department,
      color: Color(0xFFFF5722),
      ingredients: [
        'Salt',
        'Pepper',
        'Turmeric',
        'Cumin',
        'Coriander Powder',
        'Red Chili Powder',
        'Garam Masala',
        'Cinnamon',
        'Cardamom',
        'Cloves',
        'Bay Leaves',
        'Oregano',
        'Basil',
        'Thyme',
        'Rosemary',
        'Paprika',
      ],
    ),
    IngredientCategory(
      id: 'fruits',
      name: 'Fruits',
      emoji: '🍎',
      icon: Icons.apple,
      color: Color(0xFFE53935),
      ingredients: [
        'Apple',
        'Banana',
        'Orange',
        'Mango',
        'Grapes',
        'Strawberry',
        'Lemon',
        'Lime',
        'Pineapple',
        'Watermelon',
        'Papaya',
        'Pomegranate',
        'Kiwi',
        'Blueberry',
        'Avocado',
      ],
    ),
    IngredientCategory(
      id: 'legumes',
      name: 'Legumes & Pulses',
      emoji: '🫘',
      icon: Icons.spa,
      color: Color(0xFF8D6E63),
      ingredients: [
        'Chickpeas',
        'Lentils',
        'Black Beans',
        'Kidney Beans',
        'Green Gram',
        'Black Gram',
        'Soybeans',
        'Lima Beans',
        'Pinto Beans',
        'Split Peas',
      ],
    ),
    IngredientCategory(
      id: 'condiments',
      name: 'Condiments & Sauces',
      emoji: '🫙',
      icon: Icons.local_dining,
      color: Color(0xFF9C27B0),
      ingredients: [
        'Soy Sauce',
        'Tomato Ketchup',
        'Mayonnaise',
        'Mustard',
        'Vinegar',
        'Olive Oil',
        'Vegetable Oil',
        'Sesame Oil',
        'Honey',
        'Maple Syrup',
        'Hot Sauce',
        'Worcestershire Sauce',
      ],
    ),
    IngredientCategory(
      id: 'nuts',
      name: 'Nuts & Seeds',
      emoji: '🥜',
      icon: Icons.filter_vintage,
      color: Color(0xFF6D4C41),
      ingredients: [
        'Almonds',
        'Cashews',
        'Peanuts',
        'Walnuts',
        'Pistachios',
        'Sesame Seeds',
        'Sunflower Seeds',
        'Pumpkin Seeds',
        'Chia Seeds',
        'Flaxseeds',
        'Pine Nuts',
        'Hazelnuts',
      ],
    ),
  ];

  /// Get category by ID
  static IngredientCategory? getById(String id) {
    try {
      return all.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all category names
  static List<String> get allNames => all.map((cat) => cat.name).toList();

  /// Search ingredients across all categories
  static List<String> searchIngredients(String query) {
    if (query.isEmpty) return [];
    final lowerQuery = query.toLowerCase();
    final results = <String>[];
    for (final category in all) {
      for (final ingredient in category.ingredients) {
        if (ingredient.toLowerCase().contains(lowerQuery)) {
          results.add(ingredient);
        }
      }
    }
    return results;
  }
}
