// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cgu_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CguRecord _$CguRecordFromJson(Map<String, dynamic> json) => CguRecord(
  id: json['id'] as String,
  collectionId: json['collectionId'] as String,
  collectionName: json['collectionName'] as String,
  cgu: json['cgu'] as String?,
  created: json['created'] == null ? null : DateTime.parse(json['created'] as String),
  updated: json['updated'] == null ? null : DateTime.parse(json['updated'] as String),
);

Map<String, dynamic> _$CguRecordToJson(CguRecord instance) => <String, dynamic>{
  'id': instance.id,
  'collectionId': instance.collectionId,
  'collectionName': instance.collectionName,
  'cgu': instance.cgu,
  'created': instance.created?.toIso8601String(),
  'updated': instance.updated?.toIso8601String(),
};
