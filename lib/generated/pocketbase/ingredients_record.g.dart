// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredients_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IngredientsRecord _$IngredientsRecordFromJson(Map<String, dynamic> json) => IngredientsRecord(
  id: json['id'] as String,
  collectionId: json['collectionId'] as String,
  collectionName: json['collectionName'] as String,
  name: json['name'] as String?,
  type: $enumDecodeNullable(
    _$IngredientsRecordTypeEnumEnumMap,
    json['type'],
    unknownValue: JsonKey.nullForUndefinedEnumValue,
  ),
  number: (json['number'] as num?)?.toDouble(),
  nameWithoutDiacritics: json['nameWithoutDiacritics'] as String?,
  created: json['created'] == null ? null : DateTime.parse(json['created'] as String),
  updated: json['updated'] == null ? null : DateTime.parse(json['updated'] as String),
);

Map<String, dynamic> _$IngredientsRecordToJson(IngredientsRecord instance) => <String, dynamic>{
  'id': instance.id,
  'collectionId': instance.collectionId,
  'collectionName': instance.collectionName,
  'name': instance.name,
  'type': _$IngredientsRecordTypeEnumEnumMap[instance.type],
  'number': instance.number,
  'nameWithoutDiacritics': instance.nameWithoutDiacritics,
  'created': instance.created?.toIso8601String(),
  'updated': instance.updated?.toIso8601String(),
};

const _$IngredientsRecordTypeEnumEnumMap = {
  IngredientsRecordTypeEnum.g: 'g',
  IngredientsRecordTypeEnum.l: 'L',
  IngredientsRecordTypeEnum.kg: 'kg',
  IngredientsRecordTypeEnum.mg: 'mg',
  IngredientsRecordTypeEnum.cL: 'cL',
  IngredientsRecordTypeEnum.mL: 'mL',
  IngredientsRecordTypeEnum.piece: 'piece',
  IngredientsRecordTypeEnum.cuillereACafe: 'cuillere a cafe',
  IngredientsRecordTypeEnum.cuillereASoupe: 'cuillere a soupe',
  IngredientsRecordTypeEnum.pincee: 'pincee',
};
