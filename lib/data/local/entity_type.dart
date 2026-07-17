/// Identifiers for cached entities and sync queue entries.
enum EntityType {
  batch('batch'),
  cab('cab'),
  driver('driver'),
  commuter('commuter'),
  route('route'),
  pop('pop'),
  runningBatch('running_batch'),
  returnBatch('return_batch');

  const EntityType(this.storageKey);

  final String storageKey;

  static EntityType? fromKey(String key) {
    for (final type in EntityType.values) {
      if (type.storageKey == key) {
        return type;
      }
    }
    return null;
  }
}
