import 'package:cts/utils/validators.dart';

/// Validation helpers for the offline temp module.
class OfflineValidators {
  OfflineValidators._();

  static String? commuterName(String? value) =>
      Validators.name(value, fieldName: 'Name');

  static String? optionalMobile(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return Validators.mobileNumber(value);
  }

  static String? optionalCab(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return Validators.numeric(value, fieldName: 'Cab number', isRequired: false);
  }

  static String? routeName(String? value) => Validators.routeName(value);

  static String? batchName(String? value) => Validators.batchName(value);

  static String? popName(String? value) => Validators.pickupPointName(value);
}
