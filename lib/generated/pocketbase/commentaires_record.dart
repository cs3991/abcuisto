// GENERATED CODE - DO NOT MODIFY BY HAND
// *****************************************************
// POCKETBASE_UTILS
// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint

// ignore_for_file: unused_import

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:collection/collection.dart' as _i4;
import 'package:json_annotation/json_annotation.dart' as _i1;
import 'package:json_annotation/json_annotation.dart';
import 'package:pocketbase/pocketbase.dart' as _i3;

import 'base_record.dart' as _i2;
import 'date_time_json_methods.dart';
import 'geo_point_class.dart';

part 'commentaires_record.g.dart';

enum CommentairesRecordFieldsEnum {
  id('id'),
  collectionId('collectionId'),
  collectionName('collectionName'),
  recette('recette'),
  user('user'),
  commentaire('commentaire'),
  username('username'),
  note('note'),
  created('created'),
  updated('updated');

  const CommentairesRecordFieldsEnum(this.nameInSchema);

  final String nameInSchema;
}

@_i1.JsonSerializable()
final class CommentairesRecord extends _i2.BaseRecord {
  CommentairesRecord({
    required super.id,
    required super.collectionId,
    required super.collectionName,
    this.recette,
    this.user,
    this.commentaire,
    this.username,
    this.note,
    this.created,
    this.updated,
    this.expand,
  }) : super();

  factory CommentairesRecord.fromJson(Map<String, dynamic> json) =>
      _$CommentairesRecordFromJson(json);

  factory CommentairesRecord.fromRecordModel(_i3.RecordModel recordModel) {
    final extendedJsonMap = {
      ...recordModel.data,
      CommentairesRecordFieldsEnum.id.nameInSchema: recordModel.id,
      CommentairesRecordFieldsEnum.collectionId.nameInSchema:
      recordModel.collectionId,
      CommentairesRecordFieldsEnum.collectionName.nameInSchema:
      recordModel.collectionName,
      'expand': recordModel.expand,
    };
    return CommentairesRecord.fromJson(extendedJsonMap);
  }

  final String? recette;

  final String? user;

  final String? commentaire;

  final String? username;

  static const usernameMinValue = 0;

  static const usernameMaxValue = 0;

  final double? note;

  final DateTime? created;

  final DateTime? updated;

  static const $collectionId = 'pbc_2384889026';

  static const $collectionName = 'commentaires';

  final Map<String, dynamic>? expand;

  Map<String, dynamic> toJson() => _$CommentairesRecordToJson(this);

  CommentairesRecord copyWith({
    String? recette,
    String? user,
    String? commentaire,
    String? username,
    double? note,
    DateTime? created,
    DateTime? updated,
  }) {
    return CommentairesRecord(
      id: id,
      collectionId: collectionId,
      collectionName: collectionName,
      recette: recette ?? this.recette,
      user: user ?? this.user,
      commentaire: commentaire ?? this.commentaire,
      username: username ?? this.username,
      note: note ?? this.note,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  Map<String, dynamic> takeDiff(CommentairesRecord other) {
    final thisInJsonMap = toJson();
    final otherInJsonMap = other.toJson();
    final Map<String, dynamic> result = {};
    final _i4.DeepCollectionEquality deepCollectionEquality =
    _i4.DeepCollectionEquality();
    for (final mapEntry in thisInJsonMap.entries) {
      final thisValue = mapEntry.value;
      final otherValue = otherInJsonMap[mapEntry.key];
      if (!deepCollectionEquality.equals(
        thisValue,
        otherValue,
      )) {
        result.addAll({mapEntry.key: otherValue});
      }
    }
    return result;
  }

  @override
  List<Object?> get props =>
      [
        ...super.props,
        recette,
        user,
        commentaire,
        username,
        note,
        created,
        updated,
      ];

  static Map<String, dynamic> forCreateRequest({
    String? recette,
    String? user,
    String? commentaire,
    String? username,
    double? note,
    DateTime? created,
    DateTime? updated,
  }) {
    final jsonMap = CommentairesRecord(
      id: '',
      collectionId: $collectionId,
      collectionName: $collectionName,
      recette: recette,
      user: user,
      commentaire: commentaire,
      username: username,
      note: note,
      created: created,
      updated: updated,
    ).toJson();
    final Map<String, dynamic> result = {};
    if (recette != null) {
      result.addAll({
        CommentairesRecordFieldsEnum.recette.nameInSchema:
        jsonMap[CommentairesRecordFieldsEnum.recette.nameInSchema]
      });
    }
    if (user != null) {
      result.addAll({
        CommentairesRecordFieldsEnum.user.nameInSchema:
        jsonMap[CommentairesRecordFieldsEnum.user.nameInSchema]
      });
    }
    if (commentaire != null) {
      result.addAll({
        CommentairesRecordFieldsEnum.commentaire.nameInSchema:
        jsonMap[CommentairesRecordFieldsEnum.commentaire.nameInSchema]
      });
    }
    if (username != null) {
      result.addAll({
        CommentairesRecordFieldsEnum.username.nameInSchema:
        jsonMap[CommentairesRecordFieldsEnum.username.nameInSchema]
      });
    }
    if (note != null) {
      result.addAll({
        CommentairesRecordFieldsEnum.note.nameInSchema:
        jsonMap[CommentairesRecordFieldsEnum.note.nameInSchema]
      });
    }
    if (created != null) {
      result.addAll({
        CommentairesRecordFieldsEnum.created.nameInSchema:
        jsonMap[CommentairesRecordFieldsEnum.created.nameInSchema]
      });
    }
    if (updated != null) {
      result.addAll({
        CommentairesRecordFieldsEnum.updated.nameInSchema:
        jsonMap[CommentairesRecordFieldsEnum.updated.nameInSchema]
      });
    }
    return result;
  }
}
