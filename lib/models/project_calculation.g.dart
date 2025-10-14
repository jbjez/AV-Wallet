// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_calculation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProjectCalculationImpl _$$ProjectCalculationImplFromJson(
        Map<String, dynamic> json) =>
    _$ProjectCalculationImpl(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      name: json['name'] as String,
      totalPower: (json['totalPower'] as num).toDouble(),
      totalWeight: (json['totalWeight'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      comment: json['comment'] as String?,
      filePath: json['filePath'] as String?,
      type: json['type'] as String?,
      data: json['data'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$ProjectCalculationImplToJson(
        _$ProjectCalculationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'name': instance.name,
      'totalPower': instance.totalPower,
      'totalWeight': instance.totalWeight,
      'createdAt': instance.createdAt.toIso8601String(),
      'comment': instance.comment,
      'filePath': instance.filePath,
      'type': instance.type,
      'data': instance.data,
    };
