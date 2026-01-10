/// Model for removed ingredients with reason for removal
class RemovedIngredient {
  final String name;
  final String reason;
  final String category;

  RemovedIngredient({
    required this.name,
    required this.reason,
    required this.category,
  });

  factory RemovedIngredient.fromJson(Map<String, dynamic> json) {
    return RemovedIngredient(
      name: json['name']?.toString() ?? '',
      reason: json['reason']?.toString() ?? 'Removed based on preferences',
      category: json['category']?.toString() ?? 'preference_mismatch',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'reason': reason, 'category': category};
  }

  /// Get icon based on category
  String get categoryIcon {
    switch (category) {
      case 'dietary_conflict':
        return '🥗';
      case 'allergen':
        return '⚠️';
      case 'health_concern':
        return '❤️';
      case 'preference_mismatch':
        return '🔧';
      default:
        return 'ℹ️';
    }
  }

  /// Get user-friendly category name
  String get categoryDisplayName {
    switch (category) {
      case 'dietary_conflict':
        return 'Dietary Conflict';
      case 'allergen':
        return 'Potential Allergen';
      case 'health_concern':
        return 'Health Consideration';
      case 'preference_mismatch':
        return 'Preference Mismatch';
      default:
        return 'Other';
    }
  }
}
