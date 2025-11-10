import 'package:json_annotation/json_annotation.dart';

part 'gate_log.g.dart';

@JsonSerializable()
class GateLog {
  final int id;
  final String userName;
  final String action;
  final String stateAfter;
  final DateTime timestamp;
  final bool success;

  GateLog({
    required this.id,
    required this.userName,
    required this.action,
    required this.stateAfter,
    required this.timestamp,
    required this.success,
  });

  factory GateLog.fromJson(Map<String, dynamic> json) => _$GateLogFromJson(json);
  Map<String, dynamic> toJson() => _$GateLogToJson(this);
}
