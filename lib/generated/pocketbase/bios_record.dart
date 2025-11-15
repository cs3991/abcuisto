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

part 'bios_record.g.dart';

enum BiosRecordFieldsEnum {
  id('id'),
  collectionId('collectionId'),
  collectionName('collectionName'),
  user('user'),
  image('image'),
  bio('bio'),
  created('created'),
  updated('updated');

  const BiosRecordFieldsEnum(this.nameInSchema);

  final String nameInSchema;
}

@_i1.JsonSerializable()
final class BiosRecord extends _i2.BaseRecord {
  BiosRecord({
    required super.id,
    required super.collectionId,
    required super.collectionName,
    this.user,
    this.image,
    this.bio,
    this.created,
    this.updated,
    this.expand,
  }) : super();

  factory BiosRecord.fromJson(Map<String, dynamic> json) =>
      _$BiosRecordFromJson(json);

  factory BiosRecord.fromRecordModel(_i3.RecordModel recordModel) {
    final extendedJsonMap = {
      ...recordModel.data,
      BiosRecordFieldsEnum.id.nameInSchema: recordModel.id,
      BiosRecordFieldsEnum.collectionId.nameInSchema: recordModel.collectionId,
      BiosRecordFieldsEnum.collectionName.nameInSchema:
      recordModel.collectionName,
      'expand': recordModel.expand,
    };
    return BiosRecord.fromJson(extendedJsonMap);
  }

  final String? user;

  final String? image;

  final String? bio;

  static const bioMinValue = 0;

  static const bioMaxValue = 0;

  final DateTime? created;

  final DateTime? updated;

  static const $collectionId = 'pbc_4211679333';

  static const $collectionName = 'bios';

  final Map<String, dynamic>? expand;

  Map<String, dynamic> toJson() => _$BiosRecordToJson(this);

  BiosRecord copyWith({
    String? user,
    String? image,
    String? bio,
    DateTime? created,
    DateTime? updated,
  }) {
    return BiosRecord(
      id: id,
      collectionId: collectionId,
      collectionName: collectionName,
      user: user ?? this.user,
      image: image ?? this.image,
      bio: bio ?? this.bio,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  Map<String, dynamic> takeDiff(BiosRecord other) {
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
        user,
        image,
        bio,
        created,
        updated,
      ];

  static Map<String, dynamic> forCreateRequest({
    String? user,
    String? image,
    String? bio,
    DateTime? created,
    DateTime? updated,
  }) {
    final jsonMap = BiosRecord(
      id: '',
      collectionId: $collectionId,
      collectionName: $collectionName,
      user: user,
      image: image,
      bio: bio,
      created: created,
      updated: updated,
    ).toJson();
    final Map<String, dynamic> result = {};
    if (user != null) {
      result.addAll({
        BiosRecordFieldsEnum.user.nameInSchema:
        jsonMap[BiosRecordFieldsEnum.user.nameInSchema]
      });
    }
    if (image != null) {
      result.addAll({
        BiosRecordFieldsEnum.image.nameInSchema:
        jsonMap[BiosRecordFieldsEnum.image.nameInSchema]
      });
    }
    if (bio != null) {
      result.addAll({
        BiosRecordFieldsEnum.bio.nameInSchema:
        jsonMap[BiosRecordFieldsEnum.bio.nameInSchema]
      });
    }
    if (created != null) {
      result.addAll({
        BiosRecordFieldsEnum.created.nameInSchema:
        jsonMap[BiosRecordFieldsEnum.created.nameInSchema]
      });
    }
    if (updated != null) {
      result.addAll({
        BiosRecordFieldsEnum.updated.nameInSchema:
        jsonMap[BiosRecordFieldsEnum.updated.nameInSchema]
      });
    }
    return result;
  }
}
