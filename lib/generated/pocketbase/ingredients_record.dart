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

part 'ingredients_record.g.dart';

enum IngredientsRecordFieldsEnum {
  id('id'),
  collectionId('collectionId'),
  collectionName('collectionName'),
  name('name'),
  type('type'),
  number('number'),
  nameWithoutDiacritics('nameWithoutDiacritics'),
  created('created'),
  updated('updated');

  const IngredientsRecordFieldsEnum(this.nameInSchema);

  final String nameInSchema;
}

enum IngredientsRecordTypeEnum {
  @_i1.JsonValue('g')
  g('g'),
  @_i1.JsonValue('L')
  l('L'),
  @_i1.JsonValue('kg')
  kg('kg'),
  @_i1.JsonValue('mg')
  mg('mg'),
  @_i1.JsonValue('cL')
  cL('cL'),
  @_i1.JsonValue('mL')
  mL('mL'),
  @_i1.JsonValue('piece')
  piece('piece'),
  @_i1.JsonValue('cuillere a cafe')
  cuillereACafe('cuillere a cafe'),
  @_i1.JsonValue('cuillere a soupe')
  cuillereASoupe('cuillere a soupe'),
  @_i1.JsonValue('pincee')
  pincee('pincee');

  const IngredientsRecordTypeEnum(this.nameInSchema);

  final String nameInSchema;
}

@_i1.JsonSerializable()
final class IngredientsRecord extends _i2.BaseRecord {
  IngredientsRecord({
    required super.id,
    required super.collectionId,
    required super.collectionName,
    this.name,
    this.type,
    this.number,
    this.nameWithoutDiacritics,
    this.created,
    this.updated,
  }) : super();

  factory IngredientsRecord.fromJson(Map<String, dynamic> json) => _$IngredientsRecordFromJson(json);

  factory IngredientsRecord.fromRecordModel(_i3.RecordModel recordModel) {
    final extendedJsonMap = {
      ...recordModel.data,
      IngredientsRecordFieldsEnum.id.nameInSchema: recordModel.id,
      IngredientsRecordFieldsEnum.collectionId.nameInSchema: recordModel.collectionId,
      IngredientsRecordFieldsEnum.collectionName.nameInSchema: recordModel.collectionName,
    };
    return IngredientsRecord.fromJson(extendedJsonMap);
  }

  final String? name;

  static const nameMinValue = 0;

  static const nameMaxValue = 0;

  @_i1.JsonKey(unknownEnumValue: _i1.JsonKey.nullForUndefinedEnumValue)
  final IngredientsRecordTypeEnum? type;

  final double? number;

  final String? nameWithoutDiacritics;

  static const nameWithoutDiacriticsMinValue = 0;

  static const nameWithoutDiacriticsMaxValue = 0;

  final DateTime? created;

  final DateTime? updated;

  static const $collectionId = 'pbc_3146854971';

  static const $collectionName = 'ingredients';

  Map<String, dynamic> toJson() => _$IngredientsRecordToJson(this);

  IngredientsRecord copyWith({
    String? name,
    IngredientsRecordTypeEnum? type,
    double? number,
    String? nameWithoutDiacritics,
    DateTime? created,
    DateTime? updated,
  }) {
    return IngredientsRecord(
      id: id,
      collectionId: collectionId,
      collectionName: collectionName,
      name: name ?? this.name,
      type: type ?? this.type,
      number: number ?? this.number,
      nameWithoutDiacritics: nameWithoutDiacritics ?? this.nameWithoutDiacritics,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  Map<String, dynamic> takeDiff(IngredientsRecord other) {
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
  List<Object?> get props => [...super.props, name, type, number, nameWithoutDiacritics, created, updated];

  static Map<String, dynamic> forCreateRequest({
    String? name,
    IngredientsRecordTypeEnum? type,
    double? number,
    String? nameWithoutDiacritics,
    DateTime? created,
    DateTime? updated,
  }) {
    final jsonMap = IngredientsRecord(
      id: '',
      collectionId: $collectionId,
      collectionName: $collectionName,
      name: name,
      type: type,
      number: number,
      nameWithoutDiacritics: nameWithoutDiacritics,
      created: created,
      updated: updated,
    ).toJson();
    final Map<String, dynamic> result = {};
    if (name != null) {
      result.addAll({
        IngredientsRecordFieldsEnum.name.nameInSchema: jsonMap[IngredientsRecordFieldsEnum.name.nameInSchema],
      });
    }
    if (type != null) {
      result.addAll({
        IngredientsRecordFieldsEnum.type.nameInSchema: jsonMap[IngredientsRecordFieldsEnum.type.nameInSchema],
      });
    }
    if (number != null) {
      result.addAll({
        IngredientsRecordFieldsEnum.number.nameInSchema:
            jsonMap[IngredientsRecordFieldsEnum.number.nameInSchema],
      });
    }
    if (nameWithoutDiacritics != null) {
      result.addAll({
        IngredientsRecordFieldsEnum.nameWithoutDiacritics.nameInSchema:
            jsonMap[IngredientsRecordFieldsEnum.nameWithoutDiacritics.nameInSchema],
      });
    }
    if (created != null) {
      result.addAll({
        IngredientsRecordFieldsEnum.created.nameInSchema:
            jsonMap[IngredientsRecordFieldsEnum.created.nameInSchema],
      });
    }
    if (updated != null) {
      result.addAll({
        IngredientsRecordFieldsEnum.updated.nameInSchema:
            jsonMap[IngredientsRecordFieldsEnum.updated.nameInSchema],
      });
    }
    return result;
  }
}
