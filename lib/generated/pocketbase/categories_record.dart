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

part 'categories_record.g.dart';

enum CategoriesRecordFieldsEnum {
  id('id'),
  collectionId('collectionId'),
  collectionName('collectionName'),
  name('name'),
  orderIndex('orderIndex'),
  ingredientsIds('ingredientsIds'),
  created('created'),
  updated('updated');

  const CategoriesRecordFieldsEnum(this.nameInSchema);

  final String nameInSchema;
}

@_i1.JsonSerializable()
final class CategoriesRecord extends _i2.BaseRecord {
  CategoriesRecord({
    required super.id,
    required super.collectionId,
    required super.collectionName,
    this.name,
    this.orderIndex,
    this.ingredientsIds,
    this.created,
    this.updated,
  }) : super();

  factory CategoriesRecord.fromJson(Map<String, dynamic> json) => _$CategoriesRecordFromJson(json);

  factory CategoriesRecord.fromRecordModel(_i3.RecordModel recordModel) {
    final extendedJsonMap = {
      ...recordModel.data,
      CategoriesRecordFieldsEnum.id.nameInSchema: recordModel.id,
      CategoriesRecordFieldsEnum.collectionId.nameInSchema: recordModel.collectionId,
      CategoriesRecordFieldsEnum.collectionName.nameInSchema: recordModel.collectionName,
    };
    return CategoriesRecord.fromJson(extendedJsonMap);
  }

  final String? name;

  static const nameMinValue = 0;

  static const nameMaxValue = 0;

  final double? orderIndex;

  final List<String>? ingredientsIds;

  final DateTime? created;

  final DateTime? updated;

  static const $collectionId = 'pbc_3292755704';

  static const $collectionName = 'categories';

  Map<String, dynamic> toJson() => _$CategoriesRecordToJson(this);

  CategoriesRecord copyWith({
    String? name,
    double? orderIndex,
    List<String>? ingredientsIds,
    DateTime? created,
    DateTime? updated,
  }) {
    return CategoriesRecord(
      id: id,
      collectionId: collectionId,
      collectionName: collectionName,
      name: name ?? this.name,
      orderIndex: orderIndex ?? this.orderIndex,
      ingredientsIds: ingredientsIds ?? this.ingredientsIds,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  Map<String, dynamic> takeDiff(CategoriesRecord other) {
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
  List<Object?> get props => [...super.props, name, orderIndex, ingredientsIds, created, updated];

  static Map<String, dynamic> forCreateRequest({
    String? name,
    double? orderIndex,
    List<String>? ingredientsIds,
    DateTime? created,
    DateTime? updated,
  }) {
    final jsonMap = CategoriesRecord(
      id: '',
      collectionId: $collectionId,
      collectionName: $collectionName,
      name: name,
      orderIndex: orderIndex,
      ingredientsIds: ingredientsIds,
      created: created,
      updated: updated,
    ).toJson();
    final Map<String, dynamic> result = {};
    if (name != null) {
      result.addAll({
        CategoriesRecordFieldsEnum.name.nameInSchema: jsonMap[CategoriesRecordFieldsEnum.name.nameInSchema],
      });
    }
    if (orderIndex != null) {
      result.addAll({
        CategoriesRecordFieldsEnum.orderIndex.nameInSchema:
            jsonMap[CategoriesRecordFieldsEnum.orderIndex.nameInSchema],
      });
    }
    if (ingredientsIds != null) {
      result.addAll({
        CategoriesRecordFieldsEnum.ingredientsIds.nameInSchema:
            jsonMap[CategoriesRecordFieldsEnum.ingredientsIds.nameInSchema],
      });
    }
    if (created != null) {
      result.addAll({
        CategoriesRecordFieldsEnum.created.nameInSchema:
            jsonMap[CategoriesRecordFieldsEnum.created.nameInSchema],
      });
    }
    if (updated != null) {
      result.addAll({
        CategoriesRecordFieldsEnum.updated.nameInSchema:
            jsonMap[CategoriesRecordFieldsEnum.updated.nameInSchema],
      });
    }
    return result;
  }
}
