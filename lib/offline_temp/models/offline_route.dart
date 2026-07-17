class OfflineRoute {
  const OfflineRoute({
    this.id,
    required this.name,
    required this.createdAt,
    this.popCount = 0,
  });

  final int? id;
  final String name;
  final DateTime createdAt;
  final int popCount;

  OfflineRoute copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    int? popCount,
  }) {
    return OfflineRoute(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      popCount: popCount ?? this.popCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory OfflineRoute.fromMap(Map<String, dynamic> map) {
    return OfflineRoute(
      id: map['id'] as int?,
      name: map['name'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      popCount: map['pop_count'] as int? ?? 0,
    );
  }
}
