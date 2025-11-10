// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gate_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GateLog _$GateLogFromJson(Map<String, dynamic> json) => GateLog(
      id: (json['id'] as num).toInt(),
      userName: json['userName'] as String,
      action: json['action'] as String,
      stateAfter: json['stateAfter'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      success: json['success'] as bool,
    );

Map<String, dynamic> _$GateLogToJson(GateLog instance) => <String, dynamic>{
      'id': instance.id,
      'userName': instance.userName,
      'action': instance.action,
      'stateAfter': instance.stateAfter,
      'timestamp': instance.timestamp.toIso8601String(),
      'success': instance.success,
    };
