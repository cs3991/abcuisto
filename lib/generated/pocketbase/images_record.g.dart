// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'images_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImagesRecord _$ImagesRecordFromJson(Map<String, dynamic> json) => ImagesRecord(
  id: json['id'] as String,
  collectionId: json['collectionId'] as String,
  collectionName: json['collectionName'] as String,
  nom: json['nom'] as String?,
  image: json['image'] as String?,
  created: json['created'] == null ? null : DateTime.parse(json['created'] as String),
  updated: json['updated'] == null ? null : DateTime.parse(json['updated'] as String),
);

Map<String, dynamic> _$ImagesRecordToJson(ImagesRecord instance) => <String, dynamic>{
  'id': instance.id,
  'collectionId': instance.collectionId,
  'collectionName': instance.collectionName,
  'nom': instance.nom,
  'image': instance.image,
  'created': instance.created?.toIso8601String(),
  'updated': instance.updated?.toIso8601String(),
};
