import 'package:cts/models/commuter_model.dart';
import 'package:cts/models/pop_model.dart';

class D2dCommuterModel {
  final UserId? userId;
  final PickUpPointModel? popId;
  final int? inLine;

  D2dCommuterModel({this.userId, this.popId, this.inLine});

  factory D2dCommuterModel.fromJson(Map<String, dynamic> json) {
    return D2dCommuterModel(
      userId: json['userId'] != null ? UserId.fromJson(json['userId']) : null,
      popId: json['pickUpPoint'] != null ? PickUpPointModel.fromJson(json['pickUpPoint']) : null,
      inLine: json['inLine'] as int?,
    );
  }
}

