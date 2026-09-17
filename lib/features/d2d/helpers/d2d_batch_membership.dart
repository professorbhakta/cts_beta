/// Resolve whether a live rider's home batch differs from the open trip batch.
///
/// Live WS [D2dCommuterModel] has no batch_id — FE joins against org luggage
/// (`userId → homeBatchId`) from admin-bootstrap / [CommuterRepository].
class D2dBatchMembership {
  const D2dBatchMembership(this._userIdToBatchId);

  final Map<int, String> _userIdToBatchId;

  factory D2dBatchMembership.fromUserBatchMap(Map<int, String> map) =>
      D2dBatchMembership(Map<int, String>.unmodifiable(map));

  /// Empty map — every rider treated as unknown (not other-batch).
  factory D2dBatchMembership.empty() => const D2dBatchMembership({});

  /// Build from commuter luggage rows that expose `userId.id` + `batchId.id`.
  factory D2dBatchMembership.fromCommuterRows(
    Iterable<({int? userId, String? batchId})> rows,
  ) {
    final map = <int, String>{};
    for (final row in rows) {
      final uid = row.userId;
      final bid = row.batchId?.trim();
      if (uid == null || uid <= 0 || bid == null || bid.isEmpty) continue;
      map[uid] = bid;
    }
    return D2dBatchMembership.fromUserBatchMap(map);
  }

  String? homeBatchIdFor(int? userId) {
    if (userId == null) return null;
    return _userIdToBatchId[userId];
  }

  /// True when home batch is known and differs from [tripBatchId].
  ///
  /// Prefer [knownHomeBatchId] (e.g. from WS `batchId`) when present; else
  /// look up [userId] in the luggage map.
  bool isOtherBatch(
    int? userId,
    String tripBatchId, {
    String? knownHomeBatchId,
  }) {
    final home = (knownHomeBatchId != null && knownHomeBatchId.trim().isNotEmpty)
        ? knownHomeBatchId.trim()
        : homeBatchIdFor(userId);
    if (home == null) return false;
    final trip = tripBatchId.trim();
    if (trip.isEmpty) return false;
    return home != trip;
  }

  int get size => _userIdToBatchId.length;
}

/// Pure helper for board-beep selection (same batch → short, other → long).
enum D2dBoardBeepKind { sameBatch, otherBatch }

D2dBoardBeepKind d2dBoardBeepKind({
  required bool isOtherBatch,
}) =>
    isOtherBatch ? D2dBoardBeepKind.otherBatch : D2dBoardBeepKind.sameBatch;

/// New Already-IN user ids since the previous snapshot (for driver/admin beeps).
Set<int> d2dNewAlreadyInIds({
  required Set<int> previous,
  required Set<int> current,
  required bool skipBecauseInitialHydrate,
}) {
  if (skipBecauseInitialHydrate) return const {};
  return current.difference(previous);
}

/// One board tone per snapshot delta. Other-batch (long) wins if any newcomer
/// is other — avoids racing concurrent [AudioPlayer.play] calls.
D2dBoardBeepKind? d2dBoardBeepForNewcomers({
  required Set<int> newcomers,
  required bool Function(int userId) isOtherBatch,
}) {
  if (newcomers.isEmpty) return null;
  for (final id in newcomers) {
    if (isOtherBatch(id)) return D2dBoardBeepKind.otherBatch;
  }
  return D2dBoardBeepKind.sameBatch;
}
