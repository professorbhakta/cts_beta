int parseReturnBatchInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
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
  });

  final String batchId;
  final String tripDate;
  final bool isActive;
  final int availableCount;
  final int confirmedCount;
  final int totalCapacity;
  final int remainingCapacity;

  factory ReturnBatchStatusModel.fromJson(Map<String, dynamic> json) {
    return ReturnBatchStatusModel(
      batchId: json['batch_id']?.toString() ?? '',
      tripDate: json['trip_date']?.toString() ?? '',
      isActive: json['is_active'] == true,
      availableCount: parseReturnBatchInt(json['available_count']),
      confirmedCount: parseReturnBatchInt(json['confirmed_count']),
      totalCapacity: parseReturnBatchInt(json['total_capacity']),
      remainingCapacity: parseReturnBatchInt(json['remaining_capacity']),
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
