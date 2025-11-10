// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gate_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GateStatus _$GateStatusFromJson(Map<String, dynamic> json) => GateStatus(
      state: json['state'] as String,
      lastOpenedAt: json['lastOpenedAt'] == null
          ? null
          : DateTime.parse(json['lastOpenedAt'] as String),
      lastClosedAt: json['lastClosedAt'] == null
          ? null
          : DateTime.parse(json['lastClosedAt'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      lastActionByUserName: json['lastActionByUserName'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$GateStatusToJson(GateStatus instance) =>
    <String, dynamic>{
      'state': instance.state,
      'lastOpenedAt': instance.lastOpenedAt?.toIso8601String(),
      'lastClosedAt': instance.lastClosedAt?.toIso8601String(),
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'lastActionByUserName': instance.lastActionByUserName,
      'notes': instance.notes,
    };
