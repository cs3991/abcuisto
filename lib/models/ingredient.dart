import 'package:diacritic/diacritic.dart';

class Ingredient {
  final String id;
  final String name;
  final String nameWithoutDiacritics;
  final double quantity;
  final int index;
  final double? price;
  final String? category;
  final String type;

  Ingredient({
    required this.id,
    required this.name,
    required this.nameWithoutDiacritics,
    required this.quantity,
    this.index = 0,
    this.price,
    this.category,
    required this.type,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? '';
    final number = json['number'];
    return Ingredient(
      id: json['id'] as String? ?? '',
      name: name,
      nameWithoutDiacritics: removeDiacritics(name),
      quantity: number is num ? number.toDouble() : 0,
      index: json['index'] as int? ?? 0,
      price: (json['price'] as num?)?.toDouble(),
      category: json['category'] as String?,
      type: json['type'] as String? ?? '',
    );
  }

  String get typeFormatted => switch (type.toLowerCase()) {
    'g' || 'kg' || 'mg' || 'l' || 'cl' || 'ml' => type,
    'pièce(s)' => '',
    'cuillère à café' => 'cuillère${quantity > 1 ? "s" : ""} à café',
    'cuillère à soupe' => 'cuillère${quantity > 1 ? "s" : ""} à soupe',
    'pincée(s)' => 'pincée${quantity > 1 ? "s" : ""}',
    _ => type,
  };

  String get quantityFormatted {
    if (type.toLowerCase() == 'null' || type.isEmpty) return "";
    return quantity.toStringAsFixed(quantity.truncateToDouble() == quantity ? 0 : 1);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'number': quantity,
    'index': index,
    'price': price,
    'category': category,
  };

}
