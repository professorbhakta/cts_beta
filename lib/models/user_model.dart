class UserModel {
  int? id;
  String? password;
  String? firstName;
  String? lastName;
  String? email;
  String? userType;
  String? username;
  String? mobileNumber;
  String? address;
  String? deviceId;
  bool? hasPaid;

  UserModel(
      {this.id,
        this.password,
        this.firstName,
        this.lastName,
        this.email,
        this.userType,
        this.username,
        this.mobileNumber,
        this.address,
        this.deviceId,
        this.hasPaid});

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    password = json['password'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    userType = json['userType'];
    username = json['username'];
    mobileNumber = json['mobileNumber'];
    address = json['address'];
    deviceId = json['deviceId'];
    hasPaid = json['hasPaid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['password'] = password;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['email'] = email;
    data['userType'] = userType;
    data['username'] = username;
    data['mobileNumber'] = mobileNumber;
    data['address'] = address;
    data['deviceId'] = deviceId;
    data['hasPaid'] = hasPaid;
    return data;
  }
}

class AdminCode {
  AdminData? userId;

  AdminCode({this.userId});

  AdminCode.fromJson(Map<String, dynamic> json) {
    userId =
    json['userId'] != null ? AdminData.fromJson(json['userId']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (userId != null) {
      data['userId'] = userId!.toJson();
    }
    return data;
  }
}

class AdminData {
  String? mobileNumber;
  String? username;

  AdminData({this.mobileNumber, this.username});

  AdminData.fromJson(Map<String, dynamic> json) {
    mobileNumber = json['mobileNumber'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mobileNumber'] = mobileNumber;
    data['username'] = username;
    return data;
  }
}
