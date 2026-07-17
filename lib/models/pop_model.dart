class PickUpPointModel {
  int? id;
  String? pickUpPointName;
  RouteId? routeId;
  int? inLine;

  PickUpPointModel({this.id, this.pickUpPointName, this.routeId, this.inLine});

  PickUpPointModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    pickUpPointName = json['pickUpPointName'];
    routeId =
    json['routeId'] != null ? RouteId.fromJson(json['routeId']) : null;
    inLine = json['inLine'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['pickUpPointName'] = pickUpPointName;
    if (routeId != null) {
      data['routeId'] = routeId!.toJson();
    }
    data['inLine'] = inLine;
    return data;
  }
}

class RouteId {
  int? id;
  String? routeName;

  RouteId({this.id, this.routeName});

  RouteId.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    routeName = json['routeName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['routeName'] = routeName;
    return data;
  }
}