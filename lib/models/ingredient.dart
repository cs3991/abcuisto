import 'package:abcuisto/generated/pocketbase/ingredients_record.dart';

class Ingredient {
  final String id;
  final String name;
  final String nameWithoutDiacritics;
  final double quantity;
  final IngredientsRecordTypeEnum type;

  Ingredient({
    required this.id,
    required this.name,
    required this.nameWithoutDiacritics,
    required this.quantity,
    required this.type,
  });

  factory Ingredient.fromRecordModel(IngredientsRecord record) {
    return Ingredient(
      id: record.id,
      name: record.name!,
      nameWithoutDiacritics: record.nameWithoutDiacritics!,
      quantity: (record.number! is int) ? (record.number as int).toDouble() : (record.number as double),
      type: record.type!,
    );
  }

  String get typeFormatted => switch (type) {
    IngredientsRecordTypeEnum.g => "g",
    IngredientsRecordTypeEnum.l => "l",
    IngredientsRecordTypeEnum.kg => "kg",
    IngredientsRecordTypeEnum.mg => "mg",
    IngredientsRecordTypeEnum.cL => "cl",
    IngredientsRecordTypeEnum.mL => "ml",
    IngredientsRecordTypeEnum.piecexsx => "",
    IngredientsRecordTypeEnum.cuillerexaxcafe => "cuillère${quantity > 1 ? "s" : ""} à café",
    IngredientsRecordTypeEnum.cuillerexaxsoupe => "cuillère${quantity > 1 ? "s" : ""} à soupe",
    IngredientsRecordTypeEnum.pinceexsx => "pincée${quantity > 1 ? "s" : ""}",
    IngredientsRecordTypeEnum.nullValue => "",
  };

  String get quantityFormatted {
    if (type == IngredientsRecordTypeEnum.nullValue) return "";
    return quantity.toStringAsFixed(quantity.truncateToDouble() == quantity ? 0 : 1);
  }
}
