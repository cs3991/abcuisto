// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bios_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BiosRecord _$BiosRecordFromJson(Map<String, dynamic> json) => BiosRecord(
  id: json['id'] as String,
  collectionId: json['collectionId'] as String,
  collectionName: json['collectionName'] as String,
  user: json['user'] as String?,
  image: json['image'] as String?,
  bio: json['bio'] as String?,
  created: json['created'] == null ? null : DateTime.parse(json['created'] as String),
  updated: json['updated'] == null ? null : DateTime.parse(json['updated'] as String),
  expand: json['expand'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$BiosRecordToJson(BiosRecord instance) => <String, dynamic>{
  'id': instance.id,
  'collectionId': instance.collectionId,
  'collectionName': instance.collectionName,
  'user': instance.user,
  'image': instance.image,
  'bio': instance.bio,
  'created': instance.created?.toIso8601String(),
  'updated': instance.updated?.toIso8601String(),
  'expand': instance.expand,
};
