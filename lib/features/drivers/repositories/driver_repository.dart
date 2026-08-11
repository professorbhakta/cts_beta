import 'package:cts/api/api_result.dart';
import 'package:cts/features/drivers/models/driver_model.dart';


abstract class DriverRepository {

  Future<ApiResult<List<DriverModel>>> getDrivers();

  Future<ApiResult<DriverModel>> getDriverProfile();

  Future<ApiResult<DriverModel>> getDriverByBatch(String batchId);

  Future<ApiResult<void>> createDriver(Map<String, dynamic> data);

  Future<ApiResult<void>> updateDriver(int id, Map<String, dynamic> userData, Map<String, dynamic> driverData);

  Future<ApiResult<void>> deleteDriver(int id);

}

