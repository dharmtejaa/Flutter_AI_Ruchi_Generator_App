class Ingredient {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final String? icon; // For future use with icons

  Ingredient({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.icon,
  });

  Ingredient copyWith({
    String? id,
    String? name,
    double? quantity,
    String? unit,
    String? icon,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      icon: icon ?? this.icon,
    );
  }
}
