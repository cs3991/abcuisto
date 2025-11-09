// GENERATED CODE - DO NOT MODIFY BY HAND
// *****************************************************
// POCKETBASE_UTILS
// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:equatable/equatable.dart' as _i2;
import 'package:json_annotation/json_annotation.dart' as _i1;

part 'geo_point_class.g.dart';

@_i1.JsonSerializable()
class GeoPoint extends _i2.Equatable {
  GeoPoint(this.lon, this.lat);

  factory GeoPoint.fromJson(Map<String, dynamic> json) => _$GeoPointFromJson(json);

  final double lon;

  final double lat;

  Map<String, dynamic> toJson() => _$GeoPointToJson(this);

  @override
  List<Object?> get props => [lat, lon];
}
