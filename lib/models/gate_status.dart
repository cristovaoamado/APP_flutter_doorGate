import 'package:json_annotation/json_annotation.dart';

part 'gate_status.g.dart';

@JsonSerializable()
class GateStatus {
  final String state;
  final DateTime? lastOpenedAt;
  final DateTime? lastClosedAt;
  final DateTime lastUpdated;
  final String? lastActionByUserName;
  final String? notes;

  GateStatus({
    required this.state,
    this.lastOpenedAt,
    this.lastClosedAt,
    required this.lastUpdated,
    this.lastActionByUserName,
    this.notes,
  });

  // Getters com comparação case-insensitive
  bool get isOpen => state.toLowerCase() == 'open';
  bool get isClosed => state.toLowerCase() == 'closed';
  bool get isUnknown => !isOpen && !isClosed;

  factory GateStatus.fromJson(Map<String, dynamic> json) =>
      _$GateStatusFromJson(json);

  Map<String, dynamic> toJson() => _$GateStatusToJson(this);
}