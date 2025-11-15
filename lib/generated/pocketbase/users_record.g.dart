// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsersRecord _$UsersRecordFromJson(Map<String, dynamic> json) => UsersRecord(
  id: json['id'] as String,
  collectionId: json['collectionId'] as String,
  collectionName: json['collectionName'] as String,
  email: json['email'] as String?,
  emailVisibility: json['emailVisibility'] as bool,
  verified: json['verified'] as bool,
  name: json['name'] as String?,
  avatar: json['avatar'] as String?,
  username: json['username'] as String?,
  bio: json['bio'] as String?,
  image: json['image'] as String?,
  groups: (json['groups'] as List<dynamic>?)?.map((e) => e as String).toList(),
  created: json['created'] == null ? null : DateTime.parse(json['created'] as String),
  updated: json['updated'] == null ? null : DateTime.parse(json['updated'] as String),
  expand: json['expand'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$UsersRecordToJson(UsersRecord instance) => <String, dynamic>{
  'id': instance.id,
  'collectionId': instance.collectionId,
  'collectionName': instance.collectionName,
  'email': instance.email,
  'emailVisibility': instance.emailVisibility,
  'verified': instance.verified,
  'name': instance.name,
  'avatar': instance.avatar,
  'username': instance.username,
  'bio': instance.bio,
  'image': instance.image,
  'groups': instance.groups,
  'created': instance.created?.toIso8601String(),
  'updated': instance.updated?.toIso8601String(),
  'expand': instance.expand,
};
