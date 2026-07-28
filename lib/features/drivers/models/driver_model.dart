import 'package:cts/features/batches/models/batch_model.dart';
import 'package:cts/models/cab_model.dart';
import 'package:cts/models/user_model.dart';

class DriverModel {
  BatchModel? batchId;
  CabModel? cabId;
  UserModel? userId;
  int? id;
  AdminCode? adminCode;

  DriverModel({this.batchId, this.cabId, this.userId, this.id, this.adminCode});

  DriverModel.fromJson(Map<String, dynamic> json) {
    batchId =
    json['batchId'] != null ? BatchModel.fromJson(json['batchId']) : null;
    cabId = json['cabId'] != null ? CabModel.fromJson(json['cabId']) : null;
    userId =
    json['userId'] != null ? UserModel.fromJson(json['userId']) : null;
    id = json['id'];
    adminCode = json['adminCode'] != null
        ? AdminCode.fromJson(json['adminCode'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (batchId != null) {
      data['batchId'] = batchId!.toJson();
    }
    if (cabId != null) {
      data['cabId'] = cabId!.toJson();
    }
    if (userId != null) {
      data['userId'] = userId!.toJson();
    }
    data['id'] = id;
    if (adminCode != null) {
      data['adminCode'] = adminCode!.toJson();
    }
    return data;
  }
}

