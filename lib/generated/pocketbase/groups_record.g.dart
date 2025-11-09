// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'groups_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupsRecord _$GroupsRecordFromJson(Map<String, dynamic> json) => GroupsRecord(
  id: json['id'] as String,
  collectionId: json['collectionId'] as String,
  collectionName: json['collectionName'] as String,
  owner: json['owner'] as String?,
  name: json['name'] as String?,
  link: json['link'] as String?,
  canEdit: json['canEdit'] as bool,
  created: json['created'] == null ? null : DateTime.parse(json['created'] as String),
  updated: json['updated'] == null ? null : DateTime.parse(json['updated'] as String),
);

Map<String, dynamic> _$GroupsRecordToJson(GroupsRecord instance) => <String, dynamic>{
  'id': instance.id,
  'collectionId': instance.collectionId,
  'collectionName': instance.collectionName,
  'owner': instance.owner,
  'name': instance.name,
  'link': instance.link,
  'canEdit': instance.canEdit,
  'created': instance.created?.toIso8601String(),
  'updated': instance.updated?.toIso8601String(),
};
