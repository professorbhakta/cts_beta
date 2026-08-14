import 'package:cts/features/commuters/models/commuter_model.dart';
import 'package:cts/models/user_model.dart';
import 'package:flutter/material.dart';

class CommuterFormProvider with ChangeNotifier {
  static const placeholderEmail = 'mail@email.com';
  static const placeholderAddress = 'address';
  static const addressMaxLength = 100;

  final commName = TextEditingController();
  final commMob = TextEditingController();
  final commEmail = TextEditingController();
  final commPass = TextEditingController();
  final commAddr = TextEditingController();
  final commClg = TextEditingController();

  int? selectedCabId;
  int? selectedPopId;
  int? selectedBatchId;

  bool forUpdate = false;
  int updateId = 0;

  /// Raw address last stored on the user. Null until a fetch or list value exists.
  String? lastSavedAddress;
  bool lastSavedAddressKnown = false;

  static bool isPlaceholderEmail(String? value) {
    final v = value?.trim() ?? '';
    return v.isEmpty || v.toLowerCase() == placeholderEmail;
  }

  static bool isMissingAddress(String? value) {
    final v = value?.trim() ?? '';
    return v.isEmpty || v.toLowerCase() == placeholderAddress;
  }

  static String displayEmail(String? stored) {
    return isPlaceholderEmail(stored) ? '' : stored!.trim();
  }

  static String displayAddress(String? stored) {
    return isMissingAddress(stored) ? '' : stored!.trim();
  }

  static String _truncateAddress(String value) {
    final trimmed = value.trim();
    if (trimmed.length <= addressMaxLength) return trimmed;
    return trimmed.substring(0, addressMaxLength);
  }

  void fillFromCommuter(CommuterModel commuter) {
    forUpdate = true;
    updateId = commuter.userId?.id ?? 0;
    commName.text = commuter.userId?.username ?? '';
    commMob.text = commuter.userId?.mobileNumber ?? '';
    commEmail.text = displayEmail(commuter.userId?.email);
    commAddr.text = displayAddress(commuter.userId?.address);
    commClg.text = commuter.collegeName ?? '';
    selectedBatchId = commuter.batchId?.id;
    selectedCabId = commuter.cabId?.id;
    selectedPopId = commuter.popId?.id;
    lastSavedAddress = commuter.userId?.address?.trim();
    lastSavedAddressKnown = commuter.userId?.address != null;
    notifyListeners();
  }

  void applyFetchedUser(UserModel user) {
    commEmail.text = displayEmail(user.email);
    commAddr.text = displayAddress(user.address);
    lastSavedAddress = user.address?.trim();
    lastSavedAddressKnown = true;
    notifyListeners();
  }

  /// Create: empty address → email. Update: empty address → last saved, else email.
  /// Returns null on update when the last saved address is unknown (omit from PATCH).
  String? addressForPayload() {
    final typed = commAddr.text.trim();
    if (!isMissingAddress(typed)) {
      return _truncateAddress(typed);
    }
    if (lastSavedAddressKnown) {
      if (!isMissingAddress(lastSavedAddress)) {
        return _truncateAddress(lastSavedAddress!);
      }
      return _truncateAddress(commEmail.text);
    }
    if (forUpdate) return null;
    return _truncateAddress(commEmail.text);
  }

  void clearAll() {
    commName.clear();
    commMob.clear();
    commEmail.clear();
    commPass.clear();
    commAddr.clear();
    commClg.clear();
    selectedCabId = null;
    selectedPopId = null;
    selectedBatchId = null;
    forUpdate = false;
    updateId = 0;
    lastSavedAddress = null;
    lastSavedAddressKnown = false;
    notifyListeners();
  }

  @override
  void dispose() {
    commName.dispose();
    commMob.dispose();
    commEmail.dispose();
    commPass.dispose();
    commAddr.dispose();
    commClg.dispose();
    super.dispose();
  }
}
