// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notations_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotationsRecord _$NotationsRecordFromJson(Map<String, dynamic> json) => NotationsRecord(
  id: json['id'] as String,
  collectionId: json['collectionId'] as String,
  collectionName: json['collectionName'] as String,
  note: (json['note'] as num?)?.toDouble(),
  nbNotes: (json['nbNotes'] as num?)?.toDouble(),
  created: json['created'] == null ? null : DateTime.parse(json['created'] as String),
  updated: json['updated'] == null ? null : DateTime.parse(json['updated'] as String),
  expand: json['expand'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$NotationsRecordToJson(NotationsRecord instance) => <String, dynamic>{
  'id': instance.id,
  'collectionId': instance.collectionId,
  'collectionName': instance.collectionName,
  'note': instance.note,
  'nbNotes': instance.nbNotes,
  'created': instance.created?.toIso8601String(),
  'updated': instance.updated?.toIso8601String(),
  'expand': instance.expand,
};
