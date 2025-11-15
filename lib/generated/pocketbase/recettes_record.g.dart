// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recettes_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecettesRecord _$RecettesRecordFromJson(Map<String, dynamic> json) => RecettesRecord(
  id: json['id'] as String,
  collectionId: json['collectionId'] as String,
  collectionName: json['collectionName'] as String,
  categoriesIds: (json['categoriesIds'] as List<dynamic>?)?.map((e) => e as String).toList(),
  ustensiles: json['ustensiles'] as String?,
  nom: json['nom'] as String?,
  tempsPreparation: json['tempsPreparation'] as String?,
  tempsCuisson: json['tempsCuisson'] as String?,
  vege: json['vege'] as bool,
  steps: json['steps'] as String?,
  createur: json['createur'] as String?,
  createurPseudo: json['createur_pseudo'] as String?,
  categorie: $enumDecodeNullable(
    _$RecettesRecordCategorieEnumEnumMap,
    json['categorie'],
    unknownValue: JsonKey.nullForUndefinedEnumValue,
  ),
  visible: json['visible'] as bool,
  documents: (json['documents'] as List<dynamic>?)?.map((e) => e as String).toList(),
  forNumber: (json['forNumber'] as num?)?.toDouble(),
  typeNumber: $enumDecodeNullable(
    _$RecettesRecordTypeNumberEnumEnumMap,
    json['typeNumber'],
    unknownValue: JsonKey.nullForUndefinedEnumValue,
  ),
  prix: $enumDecodeNullable(
    _$RecettesRecordPrixEnumEnumMap,
    json['prix'],
    unknownValue: JsonKey.nullForUndefinedEnumValue,
  ),
  noteId: json['noteId'] as String?,
  groupsIds: (json['groupsIds'] as List<dynamic>?)?.map((e) => e as String).toList(),
  nameWithoutDiacritics: json['nameWithoutDiacritics'] as String?,
  tags: (json['tags'] as List<dynamic>?)
      ?.map((e) => $enumDecode(_$RecettesRecordTagsEnumEnumMap, e))
      .toList(),
  created: json['created'] == null ? null : DateTime.parse(json['created'] as String),
  updated: json['updated'] == null ? null : DateTime.parse(json['updated'] as String),
  expand: json['expand'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$RecettesRecordToJson(RecettesRecord instance) => <String, dynamic>{
  'id': instance.id,
  'collectionId': instance.collectionId,
  'collectionName': instance.collectionName,
  'categoriesIds': instance.categoriesIds,
  'ustensiles': instance.ustensiles,
  'nom': instance.nom,
  'tempsPreparation': instance.tempsPreparation,
  'tempsCuisson': instance.tempsCuisson,
  'vege': instance.vege,
  'steps': instance.steps,
  'createur': instance.createur,
  'createur_pseudo': instance.createurPseudo,
  'categorie': _$RecettesRecordCategorieEnumEnumMap[instance.categorie],
  'visible': instance.visible,
  'documents': instance.documents,
  'forNumber': instance.forNumber,
  'typeNumber': _$RecettesRecordTypeNumberEnumEnumMap[instance.typeNumber],
  'prix': _$RecettesRecordPrixEnumEnumMap[instance.prix],
  'noteId': instance.noteId,
  'groupsIds': instance.groupsIds,
  'nameWithoutDiacritics': instance.nameWithoutDiacritics,
  'tags': instance.tags?.map((e) => _$RecettesRecordTagsEnumEnumMap[e]!).toList(),
  'created': instance.created?.toIso8601String(),
  'updated': instance.updated?.toIso8601String(),
  'expand': instance.expand,
};

const _$RecettesRecordCategorieEnumEnumMap = {
  RecettesRecordCategorieEnum.aperitif: 'Apéritif',
  RecettesRecordCategorieEnum.entree: 'Entrée',
  RecettesRecordCategorieEnum.plat: 'Plat',
  RecettesRecordCategorieEnum.fromage: 'Fromage',
  RecettesRecordCategorieEnum.dessert: 'Dessert',
  RecettesRecordCategorieEnum.petitxdejeuner: 'Petit-déjeuner',
  RecettesRecordCategorieEnum.boisson: 'Boisson',
  RecettesRecordCategorieEnum.sauce: 'Sauce',
};

const _$RecettesRecordTypeNumberEnumEnumMap = {
  RecettesRecordTypeNumberEnum.personnes: 'Personnes',
  RecettesRecordTypeNumberEnum.pieces: 'Pièces',
};

const _$RecettesRecordPrixEnumEnumMap = {
  RecettesRecordPrixEnum.x: '€',
  RecettesRecordPrixEnum.xx: '€€',
  RecettesRecordPrixEnum.xxx: '€€€',
};

const _$RecettesRecordTagsEnumEnumMap = {
  RecettesRecordTagsEnum.thermomix: 'THERMOMIX',
  RecettesRecordTagsEnum.vegan: 'VEGAN',
  RecettesRecordTagsEnum.vegetarien: 'VEGETARIEN',
  RecettesRecordTagsEnum.alcool: 'ALCOOL',
  RecettesRecordTagsEnum.sansgluten: 'SANSGLUTEN',
};
