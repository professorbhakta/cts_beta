import 'package:cts/features/commuters/domain/models/commuter_model.dart';
import 'package:cts/features/drivers/domain/models/driver_model.dart';

class BatchModel {
  int? id;
  String? batchName;
  String? batchTime;
  String? returnTime;
  String? startDate;
  String? endDate;
  List<CommuterModel>? commuters;
  DriverModel? driver;

  BatchModel({
    this.id,
    this.batchName,
    this.returnTime,
    this.batchTime,
    this.startDate,
    this.endDate,
    this.commuters,
    this.driver,
  });

  BatchModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    batchName = json['batchName'];
    batchTime = json['batchTime'];
    returnTime = json['end_time'];
    startDate = json['startDate'];
    endDate = json['endDate'];
    commuters = json['commuters'] != null
        ? (json['commuters'] as List)
            .map((e) => CommuterModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : [];
    driver = json['driver'] != null
        ? DriverModel.fromJson(json['driver'] as Map<String, dynamic>)
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['batchName'] = batchName;
    data['batchTime'] = batchTime;
    data['end_time'] = returnTime;
    data['startDate'] = startDate;
    data['endDate'] = endDate;
    data['commuters'] = commuters;
    data['driver'] = driver;
    return data;
  }
}

class RunningBatches {
  int? id;
  BatchId? batchId;
  DriverModel? driver;

  RunningBatches({this.id, this.batchId, this.driver});

  RunningBatches.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    batchId =
        json['batchId'] != null ? BatchId.fromJson(json['batchId']) : null;
    driver = json['driver'] != null
        ? DriverModel.fromJson(json['driver'] as Map<String, dynamic>)
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (batchId != null) {
      data['batchId'] = batchId!.toJson();
    }
    if (driver != null) {
      data['driver'] = driver!.toJson();
    }
    return data;
  }
}

class BatchId {
  int? id;
  String? batchName;

  BatchId({this.id, this.batchName});

  BatchId.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    batchName = json['batchName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['batchName'] = batchName;
    return data;
  }
}
