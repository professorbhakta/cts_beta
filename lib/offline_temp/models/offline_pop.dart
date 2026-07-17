class OfflinePop {
  const OfflinePop({
    this.id,
    required this.routeId,
    required this.name,
    required this.createdAt,
    this.routeName,
    this.commuterCount = 0,
  });

  final int? id;
  final int routeId;
  final String name;
  final DateTime createdAt;
  final String? routeName;
  final int commuterCount;

  OfflinePop copyWith({
    int? id,
    int? routeId,
    String? name,
    DateTime? createdAt,
    String? routeName,
    int? commuterCount,
  }) {
    return OfflinePop(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      routeName: routeName ?? this.routeName,
      commuterCount: commuterCount ?? this.commuterCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'route_id': routeId,
      'name': name,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory OfflinePop.fromMap(Map<String, dynamic> map) {
    return OfflinePop(
      id: map['id'] as int?,
      routeId: map['route_id'] as int,
      name: map['name'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      routeName: map['route_name'] as String?,
      commuterCount: map['commuter_count'] as int? ?? 0,
    );
  }
}
