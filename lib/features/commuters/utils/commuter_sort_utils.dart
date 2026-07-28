import 'package:cts/features/commuters/models/commuter_model.dart';
import 'package:cts/features/commuters/utils/commuter_sort_options.dart';
import 'package:cts/utils/sort_utils.dart' show sortListAZMultiple;

/// Sorts commuters for admin list screens.
List<CommuterModel> sortCommuterList(
  List<CommuterModel> list,
  CommuterSortOption sortOption,
) {
  switch (sortOption) {
    case CommuterSortOption.nameAZ:
      return sortListAZMultiple(list, [
        (commuter) => commuter.userId?.username ?? '',
        (commuter) => commuter.userId?.mobileNumber ?? '',
      ]);
    case CommuterSortOption.nameZA:
      return sortListAZMultiple(list, [
        (commuter) => commuter.userId?.username ?? '',
        (commuter) => commuter.userId?.mobileNumber ?? '',
      ], reverse: true);
    case CommuterSortOption.mobileAZ:
      return sortListAZMultiple(list, [
        (commuter) => commuter.userId?.mobileNumber ?? '',
        (commuter) => commuter.userId?.username ?? '',
      ]);
    case CommuterSortOption.mobileZA:
      return sortListAZMultiple(list, [
        (commuter) => commuter.userId?.mobileNumber ?? '',
        (commuter) => commuter.userId?.username ?? '',
      ], reverse: true);
    case CommuterSortOption.batchAZ:
      return sortListAZMultiple(list, [
        (commuter) => commuter.batchId?.batchName ?? '',
        (commuter) => commuter.userId?.username ?? '',
      ]);
    case CommuterSortOption.batchZA:
      return sortListAZMultiple(list, [
        (commuter) => commuter.batchId?.batchName ?? '',
        (commuter) => commuter.userId?.username ?? '',
      ], reverse: true);
    case CommuterSortOption.cabRegAZ:
      return sortListAZMultiple(list, [
        (commuter) => commuter.cabId?.regNumber ?? '',
        (commuter) => commuter.userId?.username ?? '',
      ]);
    case CommuterSortOption.cabRegZA:
      return sortListAZMultiple(list, [
        (commuter) => commuter.cabId?.regNumber ?? '',
        (commuter) => commuter.userId?.username ?? '',
      ], reverse: true);
    case CommuterSortOption.collegeAZ:
      return sortListAZMultiple(list, [
        (commuter) => commuter.collegeName ?? '',
        (commuter) => commuter.userId?.username ?? '',
      ]);
    case CommuterSortOption.collegeZA:
      return sortListAZMultiple(list, [
        (commuter) => commuter.collegeName ?? '',
        (commuter) => commuter.userId?.username ?? '',
      ], reverse: true);
    case CommuterSortOption.popAZ:
      return sortListAZMultiple(list, [
        (commuter) => commuter.popId?.pickUpPointName ?? '',
        (commuter) => commuter.userId?.username ?? '',
      ]);
    case CommuterSortOption.popZA:
      return sortListAZMultiple(list, [
        (commuter) => commuter.popId?.pickUpPointName ?? '',
        (commuter) => commuter.userId?.username ?? '',
      ], reverse: true);
    case CommuterSortOption.routeAZ:
      return sortListAZMultiple(list, [
        (commuter) => commuter.popId?.routeId?.routeName ?? '',
        (commuter) => commuter.userId?.username ?? '',
      ]);
    case CommuterSortOption.routeZA:
      return sortListAZMultiple(list, [
        (commuter) => commuter.popId?.routeId?.routeName ?? '',
        (commuter) => commuter.userId?.username ?? '',
      ], reverse: true);
  }
}
