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

part 'images_record.g.dart';

enum ImagesRecordFieldsEnum {
  id('id'),
  collectionId('collectionId'),
  collectionName('collectionName'),
  nom('nom'),
  image('image'),
  created('created'),
  updated('updated');

  const ImagesRecordFieldsEnum(this.nameInSchema);

  final String nameInSchema;
}

@_i1.JsonSerializable()
final class ImagesRecord extends _i2.BaseRecord {
  ImagesRecord({
    required super.id,
    required super.collectionId,
    required super.collectionName,
    this.nom,
    this.image,
    this.created,
    this.updated,
  }) : super();

  factory ImagesRecord.fromJson(Map<String, dynamic> json) => _$ImagesRecordFromJson(json);

  factory ImagesRecord.fromRecordModel(_i3.RecordModel recordModel) {
    final extendedJsonMap = {
      ...recordModel.data,
      ImagesRecordFieldsEnum.id.nameInSchema: recordModel.id,
      ImagesRecordFieldsEnum.collectionId.nameInSchema: recordModel.collectionId,
      ImagesRecordFieldsEnum.collectionName.nameInSchema: recordModel.collectionName,
    };
    return ImagesRecord.fromJson(extendedJsonMap);
  }

  final String? nom;

  static const nomMinValue = 0;

  static const nomMaxValue = 0;

  final String? image;

  final DateTime? created;

  final DateTime? updated;

  static const $collectionId = 'pbc_3607937828';

  static const $collectionName = 'images';

  Map<String, dynamic> toJson() => _$ImagesRecordToJson(this);

  ImagesRecord copyWith({String? nom, String? image, DateTime? created, DateTime? updated}) {
    return ImagesRecord(
      id: id,
      collectionId: collectionId,
      collectionName: collectionName,
      nom: nom ?? this.nom,
      image: image ?? this.image,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  Map<String, dynamic> takeDiff(ImagesRecord other) {
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
  List<Object?> get props => [...super.props, nom, image, created, updated];

  static Map<String, dynamic> forCreateRequest({
    String? nom,
    String? image,
    DateTime? created,
    DateTime? updated,
  }) {
    final jsonMap = ImagesRecord(
      id: '',
      collectionId: $collectionId,
      collectionName: $collectionName,
      nom: nom,
      image: image,
      created: created,
      updated: updated,
    ).toJson();
    final Map<String, dynamic> result = {};
    if (nom != null) {
      result.addAll({
        ImagesRecordFieldsEnum.nom.nameInSchema: jsonMap[ImagesRecordFieldsEnum.nom.nameInSchema],
      });
    }
    if (image != null) {
      result.addAll({
        ImagesRecordFieldsEnum.image.nameInSchema: jsonMap[ImagesRecordFieldsEnum.image.nameInSchema],
      });
    }
    if (created != null) {
      result.addAll({
        ImagesRecordFieldsEnum.created.nameInSchema: jsonMap[ImagesRecordFieldsEnum.created.nameInSchema],
      });
    }
    if (updated != null) {
      result.addAll({
        ImagesRecordFieldsEnum.updated.nameInSchema: jsonMap[ImagesRecordFieldsEnum.updated.nameInSchema],
      });
    }
    return result;
  }
}
