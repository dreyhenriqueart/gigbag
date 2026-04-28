class ChecklistState {
  ChecklistState({
    required this.eventId,
    required this.checkedEquipmentIds,
    this.completedAt,
    required this.updatedAt,
  });

  final String eventId;
  final Set<String> checkedEquipmentIds;
  final DateTime? completedAt;
  final DateTime updatedAt;

  ChecklistState copyWith({
    Set<String>? checkedEquipmentIds,
    DateTime? completedAt,
    DateTime? updatedAt,
  }) {
    return ChecklistState(
      eventId: eventId,
      checkedEquipmentIds: checkedEquipmentIds ?? this.checkedEquipmentIds,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() => {
        'eventId': eventId,
        'checkedEquipmentIds': checkedEquipmentIds.toList(),
        'completedAt': completedAt?.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  static ChecklistState fromJson(Map<String, Object?> json) {
    return ChecklistState(
      eventId: json['eventId'] as String,
      checkedEquipmentIds:
          (json['checkedEquipmentIds'] as List<dynamic>).cast<String>().toSet(),
      completedAt: (json['completedAt'] as String?) == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  static String storageKey({required String eventId}) => eventId;
}

