// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commentaires_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentairesRecord _$CommentairesRecordFromJson(Map<String, dynamic> json) => CommentairesRecord(
  id: json['id'] as String,
  collectionId: json['collectionId'] as String,
  collectionName: json['collectionName'] as String,
  recette: json['recette'] as String?,
  user: json['user'] as String?,
  commentaire: json['commentaire'] as String?,
  username: json['username'] as String?,
  note: (json['note'] as num?)?.toDouble(),
  created: json['created'] == null ? null : DateTime.parse(json['created'] as String),
  updated: json['updated'] == null ? null : DateTime.parse(json['updated'] as String),
  expand: json['expand'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$CommentairesRecordToJson(CommentairesRecord instance) => <String, dynamic>{
  'id': instance.id,
  'collectionId': instance.collectionId,
  'collectionName': instance.collectionName,
  'recette': instance.recette,
  'user': instance.user,
  'commentaire': instance.commentaire,
  'username': instance.username,
  'note': instance.note,
  'created': instance.created?.toIso8601String(),
  'updated': instance.updated?.toIso8601String(),
  'expand': instance.expand,
};
