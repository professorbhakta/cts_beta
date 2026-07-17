/// Universal sorting utility for A-Z sorting across all modules
///
/// This utility provides generic sorting functions that work with any model
/// by using a field extractor function to determine sortable values.
library;

import 'package:cts/models/cab_model.dart';
import 'package:cts/models/pop_model.dart';
import 'package:cts/utils/cab_sort_options.dart';
import 'package:cts/utils/pop_sort_options.dart';

export 'package:cts/features/commuters/domain/utils/commuter_sort_utils.dart';
export 'package:cts/features/drivers/domain/utils/driver_sort_utils.dart';

/// Sorts a list of items in A-Z order based on a string field
///
/// [list] - The list to sort
/// [getField] - Function to extract the string value to sort by
/// [reverse] - If true, sorts Z-A instead of A-Z (default: false)
///
/// Example:
/// ```dart
/// sortedList = sortListAZ(
///   commuters,
///   (commuter) => commuter.userId?.username ?? '',
/// );
/// ```
List<T> sortListAZ<T>(
  List<T> list,
  String? Function(T) getField, {
  bool reverse = false,
}) {
  final sortedList = List<T>.from(list);
  sortedList.sort((a, b) {
    final aValue = (getField(a) ?? '').toLowerCase();
    final bValue = (getField(b) ?? '').toLowerCase();

    if (aValue.isEmpty && bValue.isEmpty) return 0;
    if (aValue.isEmpty) return 1; // Empty values go to end
    if (bValue.isEmpty) return -1; // Empty values go to end

    final comparison = aValue.compareTo(bValue);
    return reverse ? -comparison : comparison;
  });

  return sortedList;
}

/// Sorts a list of items in A-Z order with multiple fallback fields
///
/// This is useful when you want to sort by primary field, but if values are equal,
/// sort by a secondary field, and so on.
///
/// [list] - The list to sort
/// [getFields] - List of field extractor functions (in priority order)
/// [reverse] - If true, sorts Z-A instead of A-Z (default: false)
///
/// Example:
/// ```dart
/// sortedList = sortListAZMultiple(
///   commuters,
///   [
///     (c) => c.userId?.username ?? '',
///     (c) => c.userId?.mobileNumber ?? '',
///   ],
/// );
/// ```
List<T> sortListAZMultiple<T>(
  List<T> list,
  List<String? Function(T)> getFields, {
  bool reverse = false,
}) {
  final sortedList = List<T>.from(list);
  sortedList.sort((a, b) {
    for (final getField in getFields) {
      final aValue = (getField(a) ?? '').toLowerCase();
      final bValue = (getField(b) ?? '').toLowerCase();

      if (aValue.isEmpty && bValue.isEmpty) continue;
      if (aValue.isEmpty) return 1;
      if (bValue.isEmpty) return -1;

      final comparison = aValue.compareTo(bValue);
      if (comparison != 0) {
        return reverse ? -comparison : comparison;
      }
    }
    return 0;
  });

  return sortedList;
}

/// Sorts a list numerically (for numeric fields)
///
/// [list] - The list to sort
/// [getField] - Function to extract the numeric value to sort by
/// [reverse] - If true, sorts descending instead of ascending (default: false)
List<T> sortListNumeric<T>(
  List<T> list,
  num? Function(T) getField, {
  bool reverse = false,
}) {
  final sortedList = List<T>.from(list);
  sortedList.sort((a, b) {
    final aValue = getField(a);
    final bValue = getField(b);

    if (aValue == null && bValue == null) return 0;
    if (aValue == null) return 1;
    if (bValue == null) return -1;

    final comparison = aValue.compareTo(bValue);
    return reverse ? -comparison : comparison;
  });

  return sortedList;
}

/// Sorts a list of PickUpPointModel based on the selected sort option
List<PickUpPointModel> sortPopList(
  List<PickUpPointModel> list,
  PopSortOption sortOption,
) {
  switch (sortOption) {
    case PopSortOption.nameAZ:
      return sortListAZ(list, (pop) => pop.pickUpPointName ?? '');
    case PopSortOption.nameZA:
      return sortListAZ(
        list,
        (pop) => pop.pickUpPointName ?? '',
        reverse: true,
      );
    case PopSortOption.routeAZ:
      return sortListAZMultiple(list, [
        (pop) => pop.routeId?.routeName ?? '',
        (pop) => pop.pickUpPointName ?? '',
      ]);
    case PopSortOption.routeZA:
      return sortListAZMultiple(list, [
        (pop) => pop.routeId?.routeName ?? '',
        (pop) => pop.pickUpPointName ?? '',
      ], reverse: true);
    case PopSortOption.inlineAsc:
      return sortListNumeric(list, (pop) => pop.inLine ?? 0);
    case PopSortOption.inlineDesc:
      return sortListNumeric(list, (pop) => pop.inLine ?? 0, reverse: true);
  }
}

/// Sorts a list of CabModel based on the selected sort option
List<CabModel> sortCabList(List<CabModel> list, CabSortOption sortOption) {
  switch (sortOption) {
    case CabSortOption.regNumberAZ:
      return sortListAZ(list, (cab) => cab.regNumber ?? '');
    case CabSortOption.regNumberZA:
      return sortListAZ(list, (cab) => cab.regNumber ?? '', reverse: true);
    case CabSortOption.routeAZ:
      return sortListAZMultiple(list, [
        (cab) => cab.routeId?.routeName ?? '',
        (cab) => cab.regNumber ?? '',
      ]);
    case CabSortOption.routeZA:
      return sortListAZMultiple(list, [
        (cab) => cab.routeId?.routeName ?? '',
        (cab) => cab.regNumber ?? '',
      ], reverse: true);
    case CabSortOption.capacityAsc:
      return sortListNumeric(list, (cab) => cab.capacity ?? 0);
    case CabSortOption.capacityDesc:
      return sortListNumeric(list, (cab) => cab.capacity ?? 0, reverse: true);
    case CabSortOption.kmAsc:
      return sortListNumeric(list, (cab) => cab.km ?? 0);
    case CabSortOption.kmDesc:
      return sortListNumeric(list, (cab) => cab.km ?? 0, reverse: true);
  }
}

/// Convenience extension methods for common sorting scenarios
extension SortUtilsExtension<T> on List<T> {
  /// Sort this list in A-Z order by a string field
  List<T> sortAZ(String? Function(T) getField, {bool reverse = false}) {
    return sortListAZ(this, getField, reverse: reverse);
  }

  /// Sort this list in A-Z order by multiple fields (priority order)
  List<T> sortAZMultiple(
    List<String? Function(T)> getFields, {
    bool reverse = false,
  }) {
    return sortListAZMultiple(this, getFields, reverse: reverse);
  }

  /// Sort this list numerically
  List<T> sortNumeric(num? Function(T) getField, {bool reverse = false}) {
    return sortListNumeric(this, getField, reverse: reverse);
  }
}
