class OfflineCommuterFilter {
  const OfflineCommuterFilter({
    this.searchQuery = '',
    this.batchId,
    this.routeId,
    this.popId,
    this.cab,
    this.isComing,
    this.hasPop,
    this.hasMobile,
  });

  final String searchQuery;
  final int? batchId;
  final int? routeId;
  final int? popId;
  final String? cab;
  final bool? isComing;
  /// `true` = assigned POP, `false` = no POP, `null` = all.
  final bool? hasPop;
  /// `true` = has mobile, `false` = missing mobile, `null` = all.
  final bool? hasMobile;

  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      batchId != null ||
      routeId != null ||
      popId != null ||
      (cab != null && cab!.isNotEmpty) ||
      isComing != null ||
      hasPop != null ||
      hasMobile != null;

  int get activeFilterCount {
    var count = 0;
    if (searchQuery.isNotEmpty) count++;
    if (batchId != null) count++;
    if (routeId != null) count++;
    if (popId != null) count++;
    if (cab != null && cab!.isNotEmpty) count++;
    if (isComing != null) count++;
    if (hasPop != null) count++;
    if (hasMobile != null) count++;
    return count;
  }

  OfflineCommuterFilter copyWith({
    String? searchQuery,
    int? batchId,
    int? routeId,
    int? popId,
    String? cab,
    bool? isComing,
    bool? hasPop,
    bool? hasMobile,
    bool clearBatchId = false,
    bool clearRouteId = false,
    bool clearPopId = false,
    bool clearCab = false,
    bool clearIsComing = false,
    bool clearHasPop = false,
    bool clearHasMobile = false,
  }) {
    return OfflineCommuterFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      batchId: clearBatchId ? null : (batchId ?? this.batchId),
      routeId: clearRouteId ? null : (routeId ?? this.routeId),
      popId: clearPopId ? null : (popId ?? this.popId),
      cab: clearCab ? null : (cab ?? this.cab),
      isComing: clearIsComing ? null : (isComing ?? this.isComing),
      hasPop: clearHasPop ? null : (hasPop ?? this.hasPop),
      hasMobile: clearHasMobile ? null : (hasMobile ?? this.hasMobile),
    );
  }

  static const empty = OfflineCommuterFilter();
}
