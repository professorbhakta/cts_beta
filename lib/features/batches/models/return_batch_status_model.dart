int parseReturnBatchInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

/// Null when the key is omitted (fail closed). Real `0` stays `0`.
int? parseOptionalReturnBatchInt(Map<String, dynamic> json, String key) {
  if (!json.containsKey(key) || json[key] == null) return null;
  return parseReturnBatchInt(json[key]);
}

class ReturnBatchStatusModel {
  const ReturnBatchStatusModel({
    required this.batchId,
    required this.tripDate,
    required this.isActive,
    required this.availableCount,
    required this.confirmedCount,
    required this.totalCapacity,
    required this.remainingCapacity,
    this.homeHold,
    this.overflowConfirmed,
    this.overflowRemaining,
  });

  final String batchId;
  final String tripDate;
  final bool isActive;
  final int availableCount;
  final int confirmedCount;
  final int totalCapacity;
  final int remainingCapacity;

  /// Pool extras from GET status. All three set, or all null (fail closed).
  final int? homeHold;
  final int? overflowConfirmed;
  final int? overflowRemaining;

  bool get hasPoolExtras =>
      homeHold != null &&
      overflowConfirmed != null &&
      overflowRemaining != null;

  factory ReturnBatchStatusModel.fromJson(Map<String, dynamic> json) {
    final homeHold = parseOptionalReturnBatchInt(json, 'home_hold');
    final overflowConfirmed = parseOptionalReturnBatchInt(
      json,
      'overflow_confirmed',
    );
    final overflowRemaining = parseOptionalReturnBatchInt(
      json,
      'overflow_remaining',
    );
    final extrasComplete =
        homeHold != null &&
        overflowConfirmed != null &&
        overflowRemaining != null;

    return ReturnBatchStatusModel(
      batchId: json['batch_id']?.toString() ?? '',
      tripDate: json['trip_date']?.toString() ?? '',
      isActive: json['is_active'] == true,
      availableCount: parseReturnBatchInt(json['available_count']),
      confirmedCount: parseReturnBatchInt(json['confirmed_count']),
      totalCapacity: parseReturnBatchInt(json['total_capacity']),
      remainingCapacity: parseReturnBatchInt(json['remaining_capacity']),
      homeHold: extrasComplete ? homeHold : null,
      overflowConfirmed: extrasComplete ? overflowConfirmed : null,
      overflowRemaining: extrasComplete ? overflowRemaining : null,
    );
  }
}

class ReturnBatchCapacityModel {
  const ReturnBatchCapacityModel({
    required this.totalCapacity,
    required this.remainingCapacity,
    required this.confirmedCount,
    required this.isActive,
  });

  final int totalCapacity;
  final int remainingCapacity;
  final int confirmedCount;
  final bool isActive;

  factory ReturnBatchCapacityModel.fromConfirmedResponse(
    Map<String, dynamic> json,
  ) {
    return ReturnBatchCapacityModel(
      totalCapacity: parseReturnBatchInt(json['total_capacity']),
      remainingCapacity: parseReturnBatchInt(
        json['remaining_capacity'] ?? json['current_capacity'],
      ),
      confirmedCount: parseReturnBatchInt(json['confirmed_count']),
      isActive: json['is_active'] == true,
    );
  }
}
