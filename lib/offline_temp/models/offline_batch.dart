class OfflineBatch {
  const OfflineBatch({
    this.id,
    required this.name,
    required this.createdAt,
    this.commuterCount = 0,
  });

  final int? id;
  final String name;
  final DateTime createdAt;
  final int commuterCount;

  OfflineBatch copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    int? commuterCount,
  }) {
    return OfflineBatch(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      commuterCount: commuterCount ?? this.commuterCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory OfflineBatch.fromMap(Map<String, dynamic> map) {
    return OfflineBatch(
      id: map['id'] as int?,
      name: map['name'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      commuterCount: map['commuter_count'] as int? ?? 0,
    );
  }
}
