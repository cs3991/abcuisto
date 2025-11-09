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

part 'favoris_record.g.dart';

enum FavorisRecordFieldsEnum {
  id('id'),
  collectionId('collectionId'),
  collectionName('collectionName'),
  user('user'),
  recettes('recettes'),
  created('created'),
  updated('updated');

  const FavorisRecordFieldsEnum(this.nameInSchema);

  final String nameInSchema;
}

@_i1.JsonSerializable()
final class FavorisRecord extends _i2.BaseRecord {
  FavorisRecord({
    required super.id,
    required super.collectionId,
    required super.collectionName,
    this.user,
    this.recettes,
    this.created,
    this.updated,
  }) : super();

  factory FavorisRecord.fromJson(Map<String, dynamic> json) => _$FavorisRecordFromJson(json);

  factory FavorisRecord.fromRecordModel(_i3.RecordModel recordModel) {
    final extendedJsonMap = {
      ...recordModel.data,
      FavorisRecordFieldsEnum.id.nameInSchema: recordModel.id,
      FavorisRecordFieldsEnum.collectionId.nameInSchema: recordModel.collectionId,
      FavorisRecordFieldsEnum.collectionName.nameInSchema: recordModel.collectionName,
    };
    return FavorisRecord.fromJson(extendedJsonMap);
  }

  final String? user;

  final List<String>? recettes;

  final DateTime? created;

  final DateTime? updated;

  static const $collectionId = 'pbc_408992728';

  static const $collectionName = 'favoris';

  Map<String, dynamic> toJson() => _$FavorisRecordToJson(this);

  FavorisRecord copyWith({String? user, List<String>? recettes, DateTime? created, DateTime? updated}) {
    return FavorisRecord(
      id: id,
      collectionId: collectionId,
      collectionName: collectionName,
      user: user ?? this.user,
      recettes: recettes ?? this.recettes,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  Map<String, dynamic> takeDiff(FavorisRecord other) {
    final thisInJsonMap = toJson();
    final otherInJsonMap = other.toJson();
    final Map<String, dynamic> result = {};
    final _i4.DeepCollectionEquality deepCollectionEquality = _i4.DeepCollectionEquality();
    for (final mapEntry in thisInJsonMap.entries) {
      final thisValue = mapEntry.value;
      final otherValue = otherInJsonMap[mapEntry.key];
      if (!deepCollectionEquality.equals(thisValue, otherValue)) {
        result.addAll({mapEntry.key: otherValue});
      }
    }
    return result;
  }

  @override
  List<Object?> get props => [...super.props, user, recettes, created, updated];

  static Map<String, dynamic> forCreateRequest({
    String? user,
    List<String>? recettes,
    DateTime? created,
    DateTime? updated,
  }) {
    final jsonMap = FavorisRecord(
      id: '',
      collectionId: $collectionId,
      collectionName: $collectionName,
      user: user,
      recettes: recettes,
      created: created,
      updated: updated,
    ).toJson();
    final Map<String, dynamic> result = {};
    if (user != null) {
      result.addAll({
        FavorisRecordFieldsEnum.user.nameInSchema: jsonMap[FavorisRecordFieldsEnum.user.nameInSchema],
      });
    }
    if (recettes != null) {
      result.addAll({
        FavorisRecordFieldsEnum.recettes.nameInSchema: jsonMap[FavorisRecordFieldsEnum.recettes.nameInSchema],
      });
    }
    if (created != null) {
      result.addAll({
        FavorisRecordFieldsEnum.created.nameInSchema: jsonMap[FavorisRecordFieldsEnum.created.nameInSchema],
      });
    }
    if (updated != null) {
      result.addAll({
        FavorisRecordFieldsEnum.updated.nameInSchema: jsonMap[FavorisRecordFieldsEnum.updated.nameInSchema],
      });
    }
    return result;
  }
}
