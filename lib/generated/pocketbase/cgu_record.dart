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

part 'cgu_record.g.dart';

enum CguRecordFieldsEnum {
  id('id'),
  collectionId('collectionId'),
  collectionName('collectionName'),
  cgu('cgu'),
  created('created'),
  updated('updated');

  const CguRecordFieldsEnum(this.nameInSchema);

  final String nameInSchema;
}

@_i1.JsonSerializable()
final class CguRecord extends _i2.BaseRecord {
  CguRecord({
    required super.id,
    required super.collectionId,
    required super.collectionName,
    this.cgu,
    this.created,
    this.updated,
  }) : super();

  factory CguRecord.fromJson(Map<String, dynamic> json) => _$CguRecordFromJson(json);

  factory CguRecord.fromRecordModel(_i3.RecordModel recordModel) {
    final extendedJsonMap = {
      ...recordModel.data,
      CguRecordFieldsEnum.id.nameInSchema: recordModel.id,
      CguRecordFieldsEnum.collectionId.nameInSchema: recordModel.collectionId,
      CguRecordFieldsEnum.collectionName.nameInSchema: recordModel.collectionName,
    };
    return CguRecord.fromJson(extendedJsonMap);
  }

  final String? cgu;

  final DateTime? created;

  final DateTime? updated;

  static const $collectionId = 'pbc_2955267785';

  static const $collectionName = 'cgu';

  Map<String, dynamic> toJson() => _$CguRecordToJson(this);

  CguRecord copyWith({String? cgu, DateTime? created, DateTime? updated}) {
    return CguRecord(
      id: id,
      collectionId: collectionId,
      collectionName: collectionName,
      cgu: cgu ?? this.cgu,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  Map<String, dynamic> takeDiff(CguRecord other) {
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
  List<Object?> get props => [...super.props, cgu, created, updated];

  static Map<String, dynamic> forCreateRequest({String? cgu, DateTime? created, DateTime? updated}) {
    final jsonMap = CguRecord(
      id: '',
      collectionId: $collectionId,
      collectionName: $collectionName,
      cgu: cgu,
      created: created,
      updated: updated,
    ).toJson();
    final Map<String, dynamic> result = {};
    if (cgu != null) {
      result.addAll({CguRecordFieldsEnum.cgu.nameInSchema: jsonMap[CguRecordFieldsEnum.cgu.nameInSchema]});
    }
    if (created != null) {
      result.addAll({
        CguRecordFieldsEnum.created.nameInSchema: jsonMap[CguRecordFieldsEnum.created.nameInSchema],
      });
    }
    if (updated != null) {
      result.addAll({
        CguRecordFieldsEnum.updated.nameInSchema: jsonMap[CguRecordFieldsEnum.updated.nameInSchema],
      });
    }
    return result;
  }
}
