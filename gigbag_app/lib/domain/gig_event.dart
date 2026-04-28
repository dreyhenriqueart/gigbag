class GigEvent {
  GigEvent({
    required this.id,
    required this.title,
    required this.startsAt,
    this.location,
    required this.equipmentIds,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final DateTime startsAt;
  final String? location;
  final List<String> equipmentIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  GigEvent copyWith({
    String? title,
    DateTime? startsAt,
    String? location,
    List<String>? equipmentIds,
    DateTime? updatedAt,
  }) {
    return GigEvent(
      id: id,
      title: title ?? this.title,
      startsAt: startsAt ?? this.startsAt,
      location: location ?? this.location,
      equipmentIds: equipmentIds ?? this.equipmentIds,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'startsAt': startsAt.toIso8601String(),
        'location': location,
        'equipmentIds': equipmentIds,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  static GigEvent fromJson(Map<String, Object?> json) {
    return GigEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      startsAt: DateTime.parse(json['startsAt'] as String),
      location: json['location'] as String?,
      equipmentIds: (json['equipmentIds'] as List<dynamic>).cast<String>(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

