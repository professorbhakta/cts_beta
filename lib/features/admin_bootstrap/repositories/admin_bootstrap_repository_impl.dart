import 'package:cts/api/api_exceptions_handler.dart';
import 'package:cts/api/api_list.dart';
import 'package:cts/api/api_result.dart';
import 'package:cts/api/base_api_services.dart';
import 'package:cts/appManager/app_class.dart';
import 'package:cts/data/local/dao/admin_bootstrap_dao.dart';
import 'package:cts/features/admin_bootstrap/models/admin_bootstrap_response.dart';
import 'package:cts/features/admin_bootstrap/repositories/admin_bootstrap_repository.dart';

class AdminBootstrapRepositoryImpl implements AdminBootstrapRepository {
  AdminBootstrapRepositoryImpl({
    required BaseApiServices apiService,
    AdminBootstrapDao? dao,
  })  : _apiService = apiService,
        _dao = dao ?? AdminBootstrapDao();

  final BaseApiServices _apiService;
  final AdminBootstrapDao _dao;

  @override
  Future<ApiResult<AdminBootstrapResponse>> sync() async {
    try {
      final userType = AppManager.instance.getString(ManagerKey.userType);
      if (userType != 'ADMIN' && userType != 'SUPERVISOR') {
        return ApiResult.failure(
          ApiFailure(
            type: ApiFailureType.invalidRequest,
            message:
                'Admin bootstrap is only available for ADMIN or SUPERVISOR.',
          ),
        );
      }

      final response = await _apiService.getApi(ApiUrl.adminBootstrapUrl);

      if (response is! Map) {
        return ApiResult.failure(
          ApiFailure(
            type: ApiFailureType.parsing,
            message: 'Invalid admin-bootstrap response format from server.',
          ),
        );
      }

      final parsed = AdminBootstrapResponse.fromJson(
        Map<String, dynamic>.from(response),
      );

      final adminCode = parsed.adminCode?.trim().isNotEmpty == true
          ? parsed.adminCode!.trim()
          : AppManager.instance.getString(ManagerKey.adminCode);

      if (adminCode.isNotEmpty) {
        AppManager.instance.setString(ManagerKey.adminCode, adminCode);
      }

      await _dao.replaceAll(parsed, adminCode: adminCode);

      return ApiResult.success(parsed);
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<AdminBootstrapResponse?> readCachedMeta() {
    return _dao.readMetaAsResponse();
  }

  @override
  Future<void> clearLocal() => _dao.clearAll();
}
