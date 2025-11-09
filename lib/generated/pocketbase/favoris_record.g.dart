// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favoris_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FavorisRecord _$FavorisRecordFromJson(Map<String, dynamic> json) => FavorisRecord(
  id: json['id'] as String,
  collectionId: json['collectionId'] as String,
  collectionName: json['collectionName'] as String,
  user: json['user'] as String?,
  recettes: (json['recettes'] as List<dynamic>?)?.map((e) => e as String).toList(),
  created: json['created'] == null ? null : DateTime.parse(json['created'] as String),
  updated: json['updated'] == null ? null : DateTime.parse(json['updated'] as String),
);

Map<String, dynamic> _$FavorisRecordToJson(FavorisRecord instance) => <String, dynamic>{
  'id': instance.id,
  'collectionId': instance.collectionId,
  'collectionName': instance.collectionName,
  'user': instance.user,
  'recettes': instance.recettes,
  'created': instance.created?.toIso8601String(),
  'updated': instance.updated?.toIso8601String(),
};
