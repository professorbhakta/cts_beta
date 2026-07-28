abstract class BaseApiServices {
  Future<dynamic> getApi(String url);
  Future<dynamic> postApi(dynamic data, String url);
  Future<dynamic> patchApi(int id, dynamic data, String url);
  Future<dynamic> deleteApi(int id, String url);
}
