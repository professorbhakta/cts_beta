enum ReturnIntentKind { home, skip, earlier }

class ReturnIntentModel {
  const ReturnIntentModel({
    required this.intent,
    this.targetBatchId,
    this.tripDate,
    this.userId,
  });

  final ReturnIntentKind intent;
  final String? targetBatchId;
  final String? tripDate;
  final String? userId;

  factory ReturnIntentModel.fromJson(Map<String, dynamic> json) {
    final raw = (json['intent']?.toString() ?? 'home').toLowerCase();
    final kind = switch (raw) {
      'skip' => ReturnIntentKind.skip,
      'earlier' => ReturnIntentKind.earlier,
      _ => ReturnIntentKind.home,
    };
    final target = json['target_batch_id']?.toString();
    return ReturnIntentModel(
      intent: kind,
      targetBatchId: (target == null || target.isEmpty) ? null : target,
      tripDate: json['trip_date']?.toString(),
      userId: json['user_id']?.toString(),
    );
  }

  Map<String, dynamic> toPostBody() {
    return {
      'intent': switch (intent) {
        ReturnIntentKind.home => 'home',
        ReturnIntentKind.skip => 'skip',
        ReturnIntentKind.earlier => 'earlier',
      },
      if (intent == ReturnIntentKind.earlier &&
          targetBatchId != null &&
          targetBatchId!.isNotEmpty)
        'target_batch_id': targetBatchId,
    };
  }
}

class ReturnIntentOptionModel {
  const ReturnIntentOptionModel({
    required this.id,
    required this.batchName,
    this.endTime,
  });

  final String id;
  final String batchName;
  final String? endTime;

  factory ReturnIntentOptionModel.fromJson(Map<String, dynamic> json) {
    return ReturnIntentOptionModel(
      id: json['id']?.toString() ?? '',
      batchName: json['batchName']?.toString() ?? 'Batch',
      endTime: json['end_time']?.toString(),
    );
  }

  String get label {
    if (endTime == null || endTime!.isEmpty) return batchName;
    return '$batchName ($endTime)';
  }
}
