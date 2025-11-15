// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categories_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoriesRecord _$CategoriesRecordFromJson(Map<String, dynamic> json) => CategoriesRecord(
  id: json['id'] as String,
  collectionId: json['collectionId'] as String,
  collectionName: json['collectionName'] as String,
  name: json['name'] as String?,
  indexValue: (json['index'] as num?)?.toDouble(),
  ingredientsIds: (json['ingredientsIds'] as List<dynamic>?)?.map((e) => e as String).toList(),
  created: json['created'] == null ? null : DateTime.parse(json['created'] as String),
  updated: json['updated'] == null ? null : DateTime.parse(json['updated'] as String),
  expand: json['expand'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$CategoriesRecordToJson(CategoriesRecord instance) => <String, dynamic>{
  'id': instance.id,
  'collectionId': instance.collectionId,
  'collectionName': instance.collectionName,
  'name': instance.name,
  'index': instance.indexValue,
  'ingredientsIds': instance.ingredientsIds,
  'created': instance.created?.toIso8601String(),
  'updated': instance.updated?.toIso8601String(),
  'expand': instance.expand,
};
