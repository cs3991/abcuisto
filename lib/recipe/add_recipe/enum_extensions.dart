import 'package:abcuisto/generated/pocketbase/recettes_record.dart';

extension RecettesRecordCategorieEnumExtension on RecettesRecordCategorieEnum {
  String get displayValue {
    switch (this) {
      case RecettesRecordCategorieEnum.aperitif:
        return 'Aperitif';
      case RecettesRecordCategorieEnum.entree:
        return 'Entree';
      case RecettesRecordCategorieEnum.plat:
        return 'Plat';
      case RecettesRecordCategorieEnum.fromage:
        return 'Fromage';
      case RecettesRecordCategorieEnum.dessert:
        return 'Dessert';
      case RecettesRecordCategorieEnum.petitxdejeuner:
        return 'Petit-dejeuner';
      case RecettesRecordCategorieEnum.boisson:
        return 'Boisson';
      case RecettesRecordCategorieEnum.sauce:
        return 'Sauce';
    }
  }
}

extension RecettesRecordTypeNumberEnumExtension on RecettesRecordTypeNumberEnum {
  String get displayValue {
    switch (this) {
      case RecettesRecordTypeNumberEnum.personnes:
        return 'Personnes';
      case RecettesRecordTypeNumberEnum.pieces:
        return 'Pieces';
    }
  }
}

extension RecettesRecordPrixEnumExtension on RecettesRecordPrixEnum {
  String get displayValue {
    switch (this) {
      case RecettesRecordPrixEnum.x:
        return '€';
      case RecettesRecordPrixEnum.xx:
        return '€€';
      case RecettesRecordPrixEnum.xxx:
        return '€€€';
    }
  }
}

extension RecettesRecordTagsEnumExtension on RecettesRecordTagsEnum {
  String get displayValue {
    switch (this) {
      case RecettesRecordTagsEnum.thermomix:
        return 'THERMOMIX';
      case RecettesRecordTagsEnum.vegan:
        return 'VEGAN';
      case RecettesRecordTagsEnum.vegetarien:
        return 'VEGETARIEN';
      case RecettesRecordTagsEnum.alcool:
        return 'ALCOOL';
      case RecettesRecordTagsEnum.sansgluten:
        return 'SANSGLUTEN';
    }
  }
}
