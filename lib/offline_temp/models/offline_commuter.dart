class OfflineCommuter {
  const OfflineCommuter({
    this.id,
    required this.batchId,
    this.popId,
    required this.name,
    required this.cab,
    required this.isComing,
    required this.mobile,
    required this.createdAt,
    this.batchName,
    this.routeName,
    this.popName,
  });

  /// SQLite row id — used as the offline reference until server IDs exist.
  final int? id;
  final int batchId;
  final int? popId;
  final String name;
  final String cab;
  final bool isComing;
  final String mobile;
  final DateTime createdAt;
  final String? batchName;
  final String? routeName;
  final String? popName;

  String get displayId => id?.toString() ?? '—';

  OfflineCommuter copyWith({
    int? id,
    int? batchId,
    int? popId,
    String? name,
    String? cab,
    bool? isComing,
    String? mobile,
    DateTime? createdAt,
    String? batchName,
    String? routeName,
    String? popName,
    bool clearPopId = false,
  }) {
    return OfflineCommuter(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      popId: clearPopId ? null : (popId ?? this.popId),
      name: name ?? this.name,
      cab: cab ?? this.cab,
      isComing: isComing ?? this.isComing,
      mobile: mobile ?? this.mobile,
      createdAt: createdAt ?? this.createdAt,
      batchName: batchName ?? this.batchName,
      routeName: routeName ?? this.routeName,
      popName: popName ?? this.popName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'batch_id': batchId,
      'pop_id': popId,
      'name': name,
      'cab': cab,
      'is_coming': isComing ? 1 : 0,
      'mobile': mobile,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory OfflineCommuter.fromMap(Map<String, dynamic> map) {
    return OfflineCommuter(
      id: map['id'] as int?,
      batchId: map['batch_id'] as int,
      popId: map['pop_id'] as int?,
      name: map['name'] as String,
      cab: map['cab'] as String? ?? '',
      isComing: (map['is_coming'] as int? ?? 1) == 1,
      mobile: map['mobile'] as String? ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      batchName: map['batch_name'] as String?,
      routeName: map['route_name'] as String?,
      popName: map['pop_name'] as String?,
    );
  }
}
