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

part 'groups_record.g.dart';

enum GroupsRecordFieldsEnum {
  id('id'),
  collectionId('collectionId'),
  collectionName('collectionName'),
  owner('owner'),
  name('name'),
  link('link'),
  canEdit('canEdit'),
  created('created'),
  updated('updated');

  const GroupsRecordFieldsEnum(this.nameInSchema);

  final String nameInSchema;
}

@_i1.JsonSerializable()
final class GroupsRecord extends _i2.BaseRecord {
  GroupsRecord({
    required super.id,
    required super.collectionId,
    required super.collectionName,
    this.owner,
    this.name,
    this.link,
    required this.canEdit,
    this.created,
    this.updated,
  }) : super();

  factory GroupsRecord.fromJson(Map<String, dynamic> json) => _$GroupsRecordFromJson(json);

  factory GroupsRecord.fromRecordModel(_i3.RecordModel recordModel) {
    final extendedJsonMap = {
      ...recordModel.data,
      GroupsRecordFieldsEnum.id.nameInSchema: recordModel.id,
      GroupsRecordFieldsEnum.collectionId.nameInSchema: recordModel.collectionId,
      GroupsRecordFieldsEnum.collectionName.nameInSchema: recordModel.collectionName,
    };
    return GroupsRecord.fromJson(extendedJsonMap);
  }

  final String? owner;

  final String? name;

  static const nameMinValue = 0;

  static const nameMaxValue = 0;

  final String? link;

  static const linkMinValue = 0;

  static const linkMaxValue = 0;

  final bool canEdit;

  final DateTime? created;

  final DateTime? updated;

  static const $collectionId = 'pbc_3346940990';

  static const $collectionName = 'groups';

  Map<String, dynamic> toJson() => _$GroupsRecordToJson(this);

  GroupsRecord copyWith({
    String? owner,
    String? name,
    String? link,
    bool? canEdit,
    DateTime? created,
    DateTime? updated,
  }) {
    return GroupsRecord(
      id: id,
      collectionId: collectionId,
      collectionName: collectionName,
      owner: owner ?? this.owner,
      name: name ?? this.name,
      link: link ?? this.link,
      canEdit: canEdit ?? this.canEdit,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  Map<String, dynamic> takeDiff(GroupsRecord other) {
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
  List<Object?> get props => [...super.props, owner, name, link, canEdit, created, updated];

  static Map<String, dynamic> forCreateRequest({
    String? owner,
    String? name,
    String? link,
    required bool canEdit,
    DateTime? created,
    DateTime? updated,
  }) {
    final jsonMap = GroupsRecord(
      id: '',
      collectionId: $collectionId,
      collectionName: $collectionName,
      owner: owner,
      name: name,
      link: link,
      canEdit: canEdit,
      created: created,
      updated: updated,
    ).toJson();
    final Map<String, dynamic> result = {};
    if (owner != null) {
      result.addAll({
        GroupsRecordFieldsEnum.owner.nameInSchema: jsonMap[GroupsRecordFieldsEnum.owner.nameInSchema],
      });
    }
    if (name != null) {
      result.addAll({
        GroupsRecordFieldsEnum.name.nameInSchema: jsonMap[GroupsRecordFieldsEnum.name.nameInSchema],
      });
    }
    if (link != null) {
      result.addAll({
        GroupsRecordFieldsEnum.link.nameInSchema: jsonMap[GroupsRecordFieldsEnum.link.nameInSchema],
      });
    }
    result.addAll({
      GroupsRecordFieldsEnum.canEdit.nameInSchema: jsonMap[GroupsRecordFieldsEnum.canEdit.nameInSchema],
    });
    if (created != null) {
      result.addAll({
        GroupsRecordFieldsEnum.created.nameInSchema: jsonMap[GroupsRecordFieldsEnum.created.nameInSchema],
      });
    }
    if (updated != null) {
      result.addAll({
        GroupsRecordFieldsEnum.updated.nameInSchema: jsonMap[GroupsRecordFieldsEnum.updated.nameInSchema],
      });
    }
    return result;
  }
}
