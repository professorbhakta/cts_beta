import 'dart:convert';

import 'package:cts/data/local/entity_type.dart';

enum SyncAction {
  create('create'),
  update('update'),
  delete('delete');

  const SyncAction(this.storageKey);

  final String storageKey;

  static SyncAction? fromKey(String key) {
    for (final action in SyncAction.values) {
      if (action.storageKey == key) {
        return action;
      }
    }
    return null;
  }
}

class SyncQueueRecord {
  const SyncQueueRecord({
    this.id,
    required this.entityType,
    this.entityId,
    required this.action,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
    this.lastError,
  });

  final int? id;
  final EntityType entityType;
  final int? entityId;
  final SyncAction action;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int retryCount;
  final String? lastError;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'entity_type': entityType.storageKey,
      'entity_id': entityId,
      'action': action.storageKey,
      'payload': jsonEncode(payload),
      'created_at': createdAt.millisecondsSinceEpoch,
      'retry_count': retryCount,
      'last_error': lastError,
    };
  }

  factory SyncQueueRecord.fromMap(Map<String, dynamic> map) {
    final entityType = EntityType.fromKey(map['entity_type'] as String);
    final action = SyncAction.fromKey(map['action'] as String);

    if (entityType == null || action == null) {
      throw FormatException(
        'Invalid sync queue record: entity_type=${map['entity_type']}, action=${map['action']}',
      );
    }

    return SyncQueueRecord(
      id: map['id'] as int?,
      entityType: entityType,
      entityId: map['entity_id'] as int?,
      action: action,
      payload: jsonDecode(map['payload'] as String) as Map<String, dynamic>,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      retryCount: map['retry_count'] as int? ?? 0,
      lastError: map['last_error'] as String?,
    );
  }

  SyncQueueRecord copyWith({
    int? retryCount,
    String? lastError,
  }) {
    return SyncQueueRecord(
      id: id,
      entityType: entityType,
      entityId: entityId,
      action: action,
      payload: payload,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
    );
  }
}
