class Equipment {
  Equipment({
    required this.id,
    required this.name,
    this.category,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? category;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Equipment copyWith({
    String? name,
    String? category,
    String? notes,
    DateTime? updatedAt,
  }) {
    return Equipment(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  static Equipment fromJson(Map<String, Object?> json) {
    return Equipment(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

