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

part 'notations_record.g.dart';

enum NotationsRecordFieldsEnum {
  id('id'),
  collectionId('collectionId'),
  collectionName('collectionName'),
  note('note'),
  nbNotes('nbNotes'),
  created('created'),
  updated('updated');

  const NotationsRecordFieldsEnum(this.nameInSchema);

  final String nameInSchema;
}

@_i1.JsonSerializable()
final class NotationsRecord extends _i2.BaseRecord {
  NotationsRecord({
    required super.id,
    required super.collectionId,
    required super.collectionName,
    this.note,
    this.nbNotes,
    this.created,
    this.updated,
  }) : super();

  factory NotationsRecord.fromJson(Map<String, dynamic> json) => _$NotationsRecordFromJson(json);

  factory NotationsRecord.fromRecordModel(_i3.RecordModel recordModel) {
    final extendedJsonMap = {
      ...recordModel.data,
      NotationsRecordFieldsEnum.id.nameInSchema: recordModel.id,
      NotationsRecordFieldsEnum.collectionId.nameInSchema: recordModel.collectionId,
      NotationsRecordFieldsEnum.collectionName.nameInSchema: recordModel.collectionName,
    };
    return NotationsRecord.fromJson(extendedJsonMap);
  }

  final double? note;

  final double? nbNotes;

  final DateTime? created;

  final DateTime? updated;

  static const $collectionId = 'pbc_4282525412';

  static const $collectionName = 'notations';

  Map<String, dynamic> toJson() => _$NotationsRecordToJson(this);

  NotationsRecord copyWith({double? note, double? nbNotes, DateTime? created, DateTime? updated}) {
    return NotationsRecord(
      id: id,
      collectionId: collectionId,
      collectionName: collectionName,
      note: note ?? this.note,
      nbNotes: nbNotes ?? this.nbNotes,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  Map<String, dynamic> takeDiff(NotationsRecord other) {
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
  List<Object?> get props => [...super.props, note, nbNotes, created, updated];

  static Map<String, dynamic> forCreateRequest({
    double? note,
    double? nbNotes,
    DateTime? created,
    DateTime? updated,
  }) {
    final jsonMap = NotationsRecord(
      id: '',
      collectionId: $collectionId,
      collectionName: $collectionName,
      note: note,
      nbNotes: nbNotes,
      created: created,
      updated: updated,
    ).toJson();
    final Map<String, dynamic> result = {};
    if (note != null) {
      result.addAll({
        NotationsRecordFieldsEnum.note.nameInSchema: jsonMap[NotationsRecordFieldsEnum.note.nameInSchema],
      });
    }
    if (nbNotes != null) {
      result.addAll({
        NotationsRecordFieldsEnum.nbNotes.nameInSchema:
            jsonMap[NotationsRecordFieldsEnum.nbNotes.nameInSchema],
      });
    }
    if (created != null) {
      result.addAll({
        NotationsRecordFieldsEnum.created.nameInSchema:
            jsonMap[NotationsRecordFieldsEnum.created.nameInSchema],
      });
    }
    if (updated != null) {
      result.addAll({
        NotationsRecordFieldsEnum.updated.nameInSchema:
            jsonMap[NotationsRecordFieldsEnum.updated.nameInSchema],
      });
    }
    return result;
  }
}
