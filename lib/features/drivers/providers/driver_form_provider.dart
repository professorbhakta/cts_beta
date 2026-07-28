import 'package:flutter/material.dart';

class DriverFormProvider with ChangeNotifier {
  final driverNameCtrl = TextEditingController();
  final driverMobileCtrl = TextEditingController();
  final driverPasswordCtrl = TextEditingController();
  final driverAddressCtrl = TextEditingController();
  int? selectedCabId;
  int? selectedBatchId;

  int updateId = 0;
  bool forUpdate = false;

  void clearAll() {
    driverNameCtrl.clear();
    driverMobileCtrl.clear();
    driverPasswordCtrl.clear();
    driverAddressCtrl.clear();
    selectedCabId = null;
    selectedBatchId = null;
    forUpdate = false;
    updateId = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    driverNameCtrl.dispose();
    driverMobileCtrl.dispose();
    driverPasswordCtrl.dispose();
    driverAddressCtrl.dispose();
    super.dispose();
  }
}
