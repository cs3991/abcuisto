// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geo_point_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeoPoint _$GeoPointFromJson(Map<String, dynamic> json) =>
    GeoPoint((json['lon'] as num).toDouble(), (json['lat'] as num).toDouble());

Map<String, dynamic> _$GeoPointToJson(GeoPoint instance) => <String, dynamic>{
  'lon': instance.lon,
  'lat': instance.lat,
};
