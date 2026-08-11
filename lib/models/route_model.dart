class RouteModel {
  int? id;
  String? routeName;

  RouteModel({this.id, this.routeName});

  RouteModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    if (rawId is int) {
      id = rawId;
    } else if (rawId != null) {
      id = int.tryParse(rawId.toString());
    }
    routeName = json['routeName']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['routeName'] = routeName;
    return data;
  }
}
