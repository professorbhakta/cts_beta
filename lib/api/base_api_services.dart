abstract class BaseApiServices {
  Future<dynamic> getApi(String url);
  Future<dynamic> postApi(dynamic data, String url);
  Future<dynamic> patchApi(int id, dynamic data, String url);
  /// PATCH a full relative path (no id appended).
  Future<dynamic> patchUrl(String url, dynamic data);
  Future<dynamic> deleteApi(int id, String url);
}
