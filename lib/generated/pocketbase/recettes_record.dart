// GENERATED CODE - DO NOT MODIFY BY HAND
// *****************************************************
// POCKETBASE_UTILS
// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint

// ignore_for_file: unused_import

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:collection/collection.dart' as _i4;
import 'package:json_annotation/json_annotation.dart' as _i1;
import 'package:json_annotation/json_annotation.dart';
import 'package:pocketbase/pocketbase.dart' as _i3;

import 'base_record.dart' as _i2;
import 'date_time_json_methods.dart';
import 'geo_point_class.dart';

part 'recettes_record.g.dart';

enum RecettesRecordFieldsEnum {
  id('id'),
  collectionId('collectionId'),
  collectionName('collectionName'),
  categoriesIds('categoriesIds'),
  ustensiles('ustensiles'),
  nom('nom'),
  tempsPreparation('tempsPreparation'),
  tempsCuisson('tempsCuisson'),
  vege('vege'),
  steps('steps'),
  createur('createur'),
  createurPseudo('createur_pseudo'),
  categorie('categorie'),
  visible('visible'),
  documents('documents'),
  forNumber('forNumber'),
  typeNumber('typeNumber'),
  prix('prix'),
  noteId('noteId'),
  groupsIds('groupsIds'),
  nameWithoutDiacritics('nameWithoutDiacritics'),
  tags('tags'),
  created('created'),
  updated('updated');

  const RecettesRecordFieldsEnum(this.nameInSchema);

  final String nameInSchema;
}

enum RecettesRecordCategorieEnum {
  @_i1.JsonValue('Apéritif')
  aperitif('aperitif'),
  @_i1.JsonValue('Entrée')
  entree('entree'),
  @_i1.JsonValue('Plat')
  plat('plat'),
  @_i1.JsonValue('Fromage')
  fromage('fromage'),
  @_i1.JsonValue('Dessert')
  dessert('dessert'),
  @_i1.JsonValue('Petit-déjeuner')
  petitxdejeuner('petitxdejeuner'),
  @_i1.JsonValue('Boisson')
  boisson('boisson'),
  @_i1.JsonValue('Sauce')
  sauce('sauce');

  const RecettesRecordCategorieEnum(this.nameInSchema);

  final String nameInSchema;
}

enum RecettesRecordTypeNumberEnum {
  @_i1.JsonValue('Personnes')
  personnes('personnes'),
  @_i1.JsonValue('Pièces')
  pieces('pieces');

  const RecettesRecordTypeNumberEnum(this.nameInSchema);

  final String nameInSchema;
}

enum RecettesRecordPrixEnum {
  @_i1.JsonValue('€')
  x('x'),
  @_i1.JsonValue('€€')
  xx('xx'),
  @_i1.JsonValue('€€€')
  xxx('xxx');

  const RecettesRecordPrixEnum(this.nameInSchema);

  final String nameInSchema;
}

enum RecettesRecordTagsEnum {
  @_i1.JsonValue('THERMOMIX')
  thermomix('thermomix'),
  @_i1.JsonValue('VEGAN')
  vegan('vegan'),
  @_i1.JsonValue('VEGETARIEN')
  vegetarien('vegetarien'),
  @_i1.JsonValue('ALCOOL')
  alcool('alcool'),
  @_i1.JsonValue('SANSGLUTEN')
  sansgluten('sansgluten');

  const RecettesRecordTagsEnum(this.nameInSchema);

  final String nameInSchema;
}

@_i1.JsonSerializable()
final class RecettesRecord extends _i2.BaseRecord {
  RecettesRecord({
    required super.id,
    required super.collectionId,
    required super.collectionName,
    this.categoriesIds,
    this.ustensiles,
    this.nom,
    this.tempsPreparation,
    this.tempsCuisson,
    required this.vege,
    this.steps,
    this.createur,
    this.createurPseudo,
    this.categorie,
    required this.visible,
    this.documents,
    this.forNumber,
    this.typeNumber,
    this.prix,
    this.noteId,
    this.groupsIds,
    this.nameWithoutDiacritics,
    this.tags,
    this.created,
    this.updated,
    this.expand,
  }) : super();

  factory RecettesRecord.fromJson(Map<String, dynamic> json) =>
      _$RecettesRecordFromJson(json);

  factory RecettesRecord.fromRecordModel(_i3.RecordModel recordModel) {
    final extendedJsonMap = {
      ...recordModel.data,
      RecettesRecordFieldsEnum.id.nameInSchema: recordModel.id,
      RecettesRecordFieldsEnum.collectionId.nameInSchema:
      recordModel.collectionId,
      RecettesRecordFieldsEnum.collectionName.nameInSchema:
      recordModel.collectionName,
      'expand': recordModel.expand,
    };
    return RecettesRecord.fromJson(extendedJsonMap);
  }

  final List<String>? categoriesIds;

  final String? ustensiles;

  final String? nom;

  static const nomMinValue = 0;

  static const nomMaxValue = 0;

  final String? tempsPreparation;

  static const tempsPreparationMinValue = 0;

  static const tempsPreparationMaxValue = 0;

  final String? tempsCuisson;

  static const tempsCuissonMinValue = 0;

  static const tempsCuissonMaxValue = 0;

  final bool vege;

  final String? steps;

  final String? createur;

  @_i1.JsonKey(name: 'createur_pseudo')
  final String? createurPseudo;

  static const createur_pseudoMinValue = 0;

  static const createur_pseudoMaxValue = 0;

  @_i1.JsonKey(unknownEnumValue: _i1.JsonKey.nullForUndefinedEnumValue)
  final RecettesRecordCategorieEnum? categorie;

  final bool visible;

  final List<String>? documents;

  final double? forNumber;

  @_i1.JsonKey(unknownEnumValue: _i1.JsonKey.nullForUndefinedEnumValue)
  final RecettesRecordTypeNumberEnum? typeNumber;

  @_i1.JsonKey(unknownEnumValue: _i1.JsonKey.nullForUndefinedEnumValue)
  final RecettesRecordPrixEnum? prix;

  final String? noteId;

  final List<String>? groupsIds;

  final String? nameWithoutDiacritics;

  static const nameWithoutDiacriticsMinValue = 0;

  static const nameWithoutDiacriticsMaxValue = 0;

  final List<RecettesRecordTagsEnum>? tags;

  final DateTime? created;

  final DateTime? updated;

  static const $collectionId = 'pbc_2869346101';

  static const $collectionName = 'recettes';

  final Map<String, dynamic>? expand;

  Map<String, dynamic> toJson() => _$RecettesRecordToJson(this);

  RecettesRecord copyWith({
    List<String>? categoriesIds,
    String? ustensiles,
    String? nom,
    String? tempsPreparation,
    String? tempsCuisson,
    bool? vege,
    String? steps,
    String? createur,
    String? createurPseudo,
    RecettesRecordCategorieEnum? categorie,
    bool? visible,
    List<String>? documents,
    double? forNumber,
    RecettesRecordTypeNumberEnum? typeNumber,
    RecettesRecordPrixEnum? prix,
    String? noteId,
    List<String>? groupsIds,
    String? nameWithoutDiacritics,
    List<RecettesRecordTagsEnum>? tags,
    DateTime? created,
    DateTime? updated,
  }) {
    return RecettesRecord(
      id: id,
      collectionId: collectionId,
      collectionName: collectionName,
      categoriesIds: categoriesIds ?? this.categoriesIds,
      ustensiles: ustensiles ?? this.ustensiles,
      nom: nom ?? this.nom,
      tempsPreparation: tempsPreparation ?? this.tempsPreparation,
      tempsCuisson: tempsCuisson ?? this.tempsCuisson,
      vege: vege ?? this.vege,
      steps: steps ?? this.steps,
      createur: createur ?? this.createur,
      createurPseudo: createurPseudo ?? this.createurPseudo,
      categorie: categorie ?? this.categorie,
      visible: visible ?? this.visible,
      documents: documents ?? this.documents,
      forNumber: forNumber ?? this.forNumber,
      typeNumber: typeNumber ?? this.typeNumber,
      prix: prix ?? this.prix,
      noteId: noteId ?? this.noteId,
      groupsIds: groupsIds ?? this.groupsIds,
      nameWithoutDiacritics:
      nameWithoutDiacritics ?? this.nameWithoutDiacritics,
      tags: tags ?? this.tags,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  Map<String, dynamic> takeDiff(RecettesRecord other) {
    final thisInJsonMap = toJson();
    final otherInJsonMap = other.toJson();
    final Map<String, dynamic> result = {};
    final _i4.DeepCollectionEquality deepCollectionEquality =
    _i4.DeepCollectionEquality();
    for (final mapEntry in thisInJsonMap.entries) {
      final thisValue = mapEntry.value;
      final otherValue = otherInJsonMap[mapEntry.key];
      if (!deepCollectionEquality.equals(
        thisValue,
        otherValue,
      )) {
        result.addAll({mapEntry.key: otherValue});
      }
    }
    return result;
  }

  @override
  List<Object?> get props =>
      [
        ...super.props,
        categoriesIds,
        ustensiles,
        nom,
        tempsPreparation,
        tempsCuisson,
        vege,
        steps,
        createur,
        createurPseudo,
        categorie,
        visible,
        documents,
        forNumber,
        typeNumber,
        prix,
        noteId,
        groupsIds,
        nameWithoutDiacritics,
        tags,
        created,
        updated,
      ];

  static Map<String, dynamic> forCreateRequest({
    List<String>? categoriesIds,
    String? ustensiles,
    String? nom,
    String? tempsPreparation,
    String? tempsCuisson,
    required bool vege,
    String? steps,
    String? createur,
    String? createurPseudo,
    RecettesRecordCategorieEnum? categorie,
    required bool visible,
    List<String>? documents,
    double? forNumber,
    RecettesRecordTypeNumberEnum? typeNumber,
    RecettesRecordPrixEnum? prix,
    String? noteId,
    List<String>? groupsIds,
    String? nameWithoutDiacritics,
    List<RecettesRecordTagsEnum>? tags,
    DateTime? created,
    DateTime? updated,
  }) {
    final jsonMap = RecettesRecord(
      id: '',
      collectionId: $collectionId,
      collectionName: $collectionName,
      categoriesIds: categoriesIds,
      ustensiles: ustensiles,
      nom: nom,
      tempsPreparation: tempsPreparation,
      tempsCuisson: tempsCuisson,
      vege: vege,
      steps: steps,
      createur: createur,
      createurPseudo: createurPseudo,
      categorie: categorie,
      visible: visible,
      documents: documents,
      forNumber: forNumber,
      typeNumber: typeNumber,
      prix: prix,
      noteId: noteId,
      groupsIds: groupsIds,
      nameWithoutDiacritics: nameWithoutDiacritics,
      tags: tags,
      created: created,
      updated: updated,
    ).toJson();
    final Map<String, dynamic> result = {};
    if (categoriesIds != null) {
      result.addAll({
        RecettesRecordFieldsEnum.categoriesIds.nameInSchema:
        jsonMap[RecettesRecordFieldsEnum.categoriesIds.nameInSchema]
      });
    }
    if (ustensiles != null) {
      result.addAll({
        RecettesRecordFieldsEnum.ustensiles.nameInSchema:
        jsonMap[RecettesRecordFieldsEnum.ustensiles.nameInSchema]
      });
    }
    if (nom != null) {
      result.addAll({
        RecettesRecordFieldsEnum.nom.nameInSchema:
        jsonMap[RecettesRecordFieldsEnum.nom.nameInSchema]
      });
    }
    if (tempsPreparation != null) {
      result.addAll({
        RecettesRecordFieldsEnum.tempsPreparation.nameInSchema:
        jsonMap[RecettesRecordFieldsEnum.tempsPreparation.nameInSchema]
      });
    }
    if (tempsCuisson != null) {
      result.addAll({
        RecettesRecordFieldsEnum.tempsCuisson.nameInSchema:
        jsonMap[RecettesRecordFieldsEnum.tempsCuisson.nameInSchema]
      });
    }
    result.addAll({
      RecettesRecordFieldsEnum.vege.nameInSchema:
      jsonMap[RecettesRecordFieldsEnum.vege.nameInSchema]
    });
    if (steps != null) {
      result.addAll({
        RecettesRecordFieldsEnum.steps.nameInSchema:
        jsonMap[RecettesRecordFieldsEnum.steps.nameInSchema]
      });
    }
    if (createur != null) {
      result.addAll({
        RecettesRecordFieldsEnum.createur.nameInSchema:
        jsonMap[RecettesRecordFieldsEnum.createur.nameInSchema]
      });
    }
    if (createurPseudo != null) {
      result.addAll({
        RecettesRecordFieldsEnum.createurPseudo.nameInSchema:
        jsonMap[RecettesRecordFieldsEnum.createurPseudo.nameInSchema]
      });
    }
    if (categorie != null) {
      result.addAll({
        RecettesRecordFieldsEnum.categorie.nameInSchema:
        jsonMap[RecettesRecordFieldsEnum.categorie.nameInSchema]
      });
    }
    result.addAll({
      RecettesRecordFieldsEnum.visible.nameInSchema:
      jsonMap[RecettesRecordFieldsEnum.visible.nameInSchema]
    });
    if (documents != null) {
      result.addAll({
        RecettesRecordFieldsEnum.documents.nameInSchema:
        jsonMap[RecettesRecordFieldsEnum.documents.nameInSchema]
      });
    }
    if (forNumber != null) {
      result.addAll({
        RecettesRecordFieldsEnum.forNumber.nameInSchema:
        jsonMap[RecettesRecordFieldsEnum.forNumber.nameInSchema]
      });
    }
    if (typeNumber != null) {
      result.addAll({
        RecettesRecordFieldsEnum.typeNumber.nameInSchema:
        jsonMap[RecettesRecordFieldsEnum.typeNumber.nameInSchema]
      });
    }
    if (prix != null) {
      result.addAll({
        RecettesRecordFieldsEnum.prix.nameInSchema:
        jsonMap[RecettesRecordFieldsEnum.prix.nameInSchema]
      });
    }
    if (noteId != null) {
      result.addAll({
        RecettesRecordFieldsEnum.noteId.nameInSchema:
        jsonMap[RecettesRecordFieldsEnum.noteId.nameInSchema]
      });
    }
    if (groupsIds != null) {
      result.addAll({
        RecettesRecordFieldsEnum.groupsIds.nameInSchema:
        jsonMap[RecettesRecordFieldsEnum.groupsIds.nameInSchema]
      });
    }
    if (nameWithoutDiacritics != null) {
      result.addAll({
        RecettesRecordFieldsEnum.nameWithoutDiacritics.nameInSchema:
        jsonMap[RecettesRecordFieldsEnum.nameWithoutDiacritics.nameInSchema]
      });
    }
    if (tags != null) {
      result.addAll({
        RecettesRecordFieldsEnum.tags.nameInSchema:
        jsonMap[RecettesRecordFieldsEnum.tags.nameInSchema]
      });
    }
    if (created != null) {
      result.addAll({
        RecettesRecordFieldsEnum.created.nameInSchema:
        jsonMap[RecettesRecordFieldsEnum.created.nameInSchema]
      });
    }
    if (updated != null) {
      result.addAll({
        RecettesRecordFieldsEnum.updated.nameInSchema:
        jsonMap[RecettesRecordFieldsEnum.updated.nameInSchema]
      });
    }
    return result;
  }
}
