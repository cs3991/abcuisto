// GENERATED CODE - DO NOT MODIFY BY HAND
// *****************************************************
// POCKETBASE_UTILS
// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint

// ignore_for_file: unused_import

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:equatable/equatable.dart' as _i1;
import 'package:json_annotation/json_annotation.dart';

import 'date_time_json_methods.dart';

abstract base class BaseRecord extends _i1.Equatable {
  BaseRecord({
    required this.id,
    required this.collectionId,
    required this.collectionName,
  });

  final String id;

  final String collectionId;

  final String collectionName;

  @override
  List<Object?> get props =>
      [
        id,
        collectionId,
        collectionName,
      ];
}
