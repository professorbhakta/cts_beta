import 'package:cts/features/batches/models/batch_model.dart';
import 'package:cts/models/cab_model.dart';
import 'package:cts/models/pop_model.dart';
import 'package:cts/models/user_model.dart';
import 'package:flutter/foundation.dart';

class CommuterModel {
  BatchModel? batchId;
  String? collegeName;
  int? id;
  UserModel? userId;
  PickUpPointModel? popId;
  CabModel? cabId;
  bool? isComing;
  AdminCode? adminCode;

  CommuterModel(
      {this.batchId,
        this.collegeName,
        this.id,
        this.userId,
        this.popId,
        this.cabId,
        this.isComing,
        this.adminCode});

  CommuterModel.fromJson(Map<String, dynamic> json) {
    batchId =
    json['batchId'] != null ? BatchModel.fromJson(json['batchId']) : null;
    collegeName = json['collegeName'];
    id = json['id'];
    userId =
    json['userId'] != null ? UserModel.fromJson(json['userId']) : null;
    popId = json['popId'] != null ? PickUpPointModel.fromJson(json['popId']) : null;
    cabId = json['cabId'] != null ? CabModel.fromJson(json['cabId']) : null;
    isComing = json['isComing'];
    adminCode = json['adminCode'] != null
        ? AdminCode.fromJson(json['adminCode'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (batchId != null) {
      data['batchId'] = batchId!.toJson();
    }
    data['collegeName'] = collegeName;
    data['id'] = id;
    if (userId != null) {
      data['userId'] = userId!.toJson();
    }
    if (popId != null) {
      data['popId'] = popId!.toJson();
    }
    if (cabId != null) {
      data['cabId'] = cabId!.toJson();
    }
    data['isComing'] = isComing;
    if (adminCode != null) {
      data['adminCode'] = adminCode!.toJson();
    }
    return data;
  }

  static List<CommuterModel> filterCommuters(
      List<CommuterModel> commuterList,
      {String? batchName,
      String? cabRegNumber,
      bool? isComing,
      String? popId}) {
    return commuterList.where((commuter) {
      bool matches = true;

      if (batchName != null &&
          commuter.batchId != null &&
          commuter.batchId!.batchName != batchName) {
        matches = false;
      }

      if (cabRegNumber != null &&
          commuter.cabId != null &&
          commuter.cabId!.regNumber != cabRegNumber) {
        matches = false;
      }

      if (isComing != null && commuter.isComing != isComing) {
        matches = false;
      }
      if (popId != null &&
          commuter.popId != null &&
          commuter.popId!.pickUpPointName != popId) {
        matches = false;
      }
      return matches;
    }).toList();
  }

  static List<CommuterModel> searchCommuters(
      List<CommuterModel> commuterList,
      {String? userName, String? routeName}) {
    return commuterList.where((commuter) {
      if (kDebugMode) {
        debugPrint("commuterList.length: ${commuterList.length}");
      }

      bool matches = true;

      if (routeName != null &&
          commuter.popId != null &&
          commuter.popId!.routeId != null &&
          !commuter.popId!.routeId!.routeName!
              .toLowerCase()
              .contains(routeName.toLowerCase())) {
        matches = false;
      }

      if (userName != null &&
          commuter.userId != null &&
          commuter.userId!.username != null &&
          !commuter.userId!.username!
              .toLowerCase()
              .contains(userName.toLowerCase())) {
        matches = false;
      }

      if (kDebugMode) {
        debugPrint("matches: $matches");
      }
      return matches;
    }).toList();
  }
}

class ReturnCommuter {
  UserId? userId;
  PopId? popId;

  ReturnCommuter({this.userId, this.popId});

  ReturnCommuter.fromJson(Map<String, dynamic> json) {
    userId =
    json['userId'] != null ? UserId.fromJson(json['userId']) : null;
    popId = json['popId'] != null ? PopId.fromJson(json['popId']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (userId != null) {
      data['userId'] = userId!.toJson();
    }
    if (popId != null) {
      data['popId'] = popId!.toJson();
    }
    return data;
  }
}
class UserId {
  int? id;
  String? mobileNumber;
  String? username;

  UserId({this.id,this.mobileNumber, this.username});

  UserId.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    mobileNumber = json['mobileNumber'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['mobileNumber'] = mobileNumber;
    data['username'] = username;
    return data;
  }
}

class PopId {
  int? inLine;
  String? pickUpPointName;
  RouteId? routeId;

  PopId({this.inLine, this.pickUpPointName, this.routeId});

  PopId.fromJson(Map<String, dynamic> json) {
    inLine = json['inLine'];
    pickUpPointName = json['pickUpPointName'];
    routeId =
    json['routeId'] != null ? RouteId.fromJson(json['routeId']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['inLine'] = inLine;
    data['pickUpPointName'] = pickUpPointName;
    if (routeId != null) {
      data['routeId'] = routeId!.toJson();
    }
    return data;
  }
}

class RouteId {
  String? routeName;

  RouteId({this.routeName});

  RouteId.fromJson(Map<String, dynamic> json) {
    routeName = json['routeName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['routeName'] = routeName;
    return data;
  }
}

