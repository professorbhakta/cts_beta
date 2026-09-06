/// CamelCase login envelope from `POST /user/login` (Phase A JWT).
///
/// Wire keys are camelCase only. Empty [organizations] / [supervisorOrgs]
/// and a null/stub [profile] are valid Phase A responses.
class LoginResponse {
  const LoginResponse({
    required this.access,
    required this.refresh,
    required this.user,
    this.adminCode,
    this.organizations = const [],
    this.supervisorOrgs = const [],
    this.profile,
  });

  final String access;
  final String refresh;
  final AuthUser user;

  /// Opaque admin code when present (string, number, or nested map).
  final dynamic adminCode;

  final List<dynamic> organizations;
  final List<dynamic> supervisorOrgs;

  /// Optional role profile stub — may be null or an empty map in Phase A.
  final Map<String, dynamic>? profile;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final access = json['access']?.toString().trim() ?? '';
    final refresh = json['refresh']?.toString().trim() ?? '';
    final userRaw = json['user'];

    if (access.isEmpty || refresh.isEmpty) {
      throw const FormatException(
        'Invalid login response: missing access or refresh token.',
      );
    }
    if (userRaw is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid login response: missing user object.',
      );
    }

    final user = AuthUser.fromJson(userRaw);
    if (user.id.isEmpty || user.userType.isEmpty) {
      throw const FormatException(
        'Invalid login response: user.id or user.userType missing.',
      );
    }

    return LoginResponse(
      access: access,
      refresh: refresh,
      user: user,
      adminCode: json['adminCode'],
      organizations: _asList(json['organizations']),
      supervisorOrgs: _asList(json['supervisorOrgs']),
      profile: _asNullableMap(json['profile']),
    );
  }

  static List<dynamic> _asList(dynamic value) {
    if (value == null) return const [];
    if (value is List) return value;
    return const [];
  }

  static Map<String, dynamic>? _asNullableMap(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return null;
  }
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.username,
    required this.mobileNumber,
    required this.userType,
    this.email,
    this.hasPaid = false,
    this.deviceId,
  });

  final String id;
  final String username;
  final String mobileNumber;
  final String? email;
  final String userType;
  final bool hasPaid;
  final String? deviceId;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      mobileNumber: json['mobileNumber']?.toString() ?? '',
      email: json['email']?.toString(),
      userType: json['userType']?.toString().trim() ?? '',
      hasPaid: json['hasPaid'] == true,
      deviceId: json['deviceId']?.toString(),
    );
  }
}
