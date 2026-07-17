class RouteModel {
  int? id;
  String? routeName;

  RouteModel({this.id, this.routeName});

  RouteModel.fromJson(Map<String, dynamic> json) {
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
