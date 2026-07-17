import 'package:cts/features/drivers/domain/models/driver_model.dart';
import 'package:cts/features/drivers/domain/utils/driver_sort_options.dart';
import 'package:cts/utils/sort_utils.dart' show sortListAZMultiple;

/// Sorts drivers for admin list screens.
List<DriverModel> sortDriverList(
  List<DriverModel> list,
  DriverSortOption sortOption,
) {
  switch (sortOption) {
    case DriverSortOption.nameAZ:
      return sortListAZMultiple(list, [
        (driver) => driver.userId?.username ?? '',
        (driver) => driver.userId?.mobileNumber ?? '',
      ]);
    case DriverSortOption.nameZA:
      return sortListAZMultiple(list, [
        (driver) => driver.userId?.username ?? '',
        (driver) => driver.userId?.mobileNumber ?? '',
      ], reverse: true);
    case DriverSortOption.mobileAZ:
      return sortListAZMultiple(list, [
        (driver) => driver.userId?.mobileNumber ?? '',
        (driver) => driver.userId?.username ?? '',
      ]);
    case DriverSortOption.mobileZA:
      return sortListAZMultiple(list, [
        (driver) => driver.userId?.mobileNumber ?? '',
        (driver) => driver.userId?.username ?? '',
      ], reverse: true);
    case DriverSortOption.batchAZ:
      return sortListAZMultiple(list, [
        (driver) => driver.batchId?.batchName ?? '',
        (driver) => driver.userId?.username ?? '',
      ]);
    case DriverSortOption.batchZA:
      return sortListAZMultiple(list, [
        (driver) => driver.batchId?.batchName ?? '',
        (driver) => driver.userId?.username ?? '',
      ], reverse: true);
    case DriverSortOption.cabRegAZ:
      return sortListAZMultiple(list, [
        (driver) => driver.cabId?.regNumber ?? '',
        (driver) => driver.userId?.username ?? '',
      ]);
    case DriverSortOption.cabRegZA:
      return sortListAZMultiple(list, [
        (driver) => driver.cabId?.regNumber ?? '',
        (driver) => driver.userId?.username ?? '',
      ], reverse: true);
  }
}
